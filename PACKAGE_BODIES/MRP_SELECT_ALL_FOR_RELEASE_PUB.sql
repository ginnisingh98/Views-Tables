--------------------------------------------------------
--  DDL for Package Body MRP_SELECT_ALL_FOR_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SELECT_ALL_FOR_RELEASE_PUB" AS
    /* $Header: MRPSARPB.pls 120.3.12000000.2 2007/02/20 09:13:38 arrsubra ship $ */

MRP_CALENDAR_RET_DATES    NUMBER := 0;
mrp_calendar_cal_code     VARCHAR2(10) := '17438gdjh';
mrp_calendar_excep_set    NUMBER := -23453;
var_calendar_code      VARCHAR2(10);
var_exception_set_id   NUMBER;
max_date                  DATE;
var_return_date        DATE;
min_date                  DATE;
min_period_date           DATE;
min_week_date             DATE;
max_week_date             DATE;
min_seq_num               NUMBER;
max_period_date           DATE;
max_seq_num               NUMBER;
min_week_seq_num          NUMBER;
max_week_seq_num          NUMBER;
var_prev_seq_num   NUMBER;
var_prev_seq_num2      NUMBER;
var_prev_work_day      DATE;
var_return_number      NUMBER;
var_prev_work_day2     DATE;

TYPE_DAILY_BUCKET      CONSTANT NUMBER := 1;
TYPE_WEEKLY_BUCKET     CONSTANT NUMBER := 2;
TYPE_MONTHLY_BUCKET    CONSTANT NUMBER := 3;

PROCEDURE Update_Implement_Attrib(p_where_clause IN VARCHAR2,
								  p_employee_id IN NUMBER,
								  p_demand_class IN VARCHAR2,
								  p_def_job_class IN VARCHAR2,
								  p_def_firm_jobs IN VARCHAR2,
								  p_total_rows OUT NOCOPY NUMBER,
								  p_succ_rows OUT NOCOPY NUMBER,
								  p_error_rows OUT NOCOPY NUMBER
								  ) IS
l_where_clause VARCHAR2(32767) := NULL;
l_demand_class VARCHAR2(30) := NULL;
l_def_job_class VARCHAR2(10) :=  NULL;
l_def_firm_jobs VARCHAR2(1) := 'N';


l_employee_id NUMBER;
l_no_rec_rows NUMBER;
l_no_rep_rows NUMBER;
l_error_rows NUMBER;
l_total_rows NUMBER;
l_succ_rows NUMBER;

BEGIN

	l_where_clause := p_where_clause;
	l_employee_id := p_employee_id;
	l_demand_class := p_demand_class;
	l_def_job_class := p_def_job_class;
	l_def_firm_jobs := p_def_firm_jobs;
	l_total_rows := 0;
	l_error_rows := 0;
	l_succ_rows := 0;

	/* --------------------------------------------------+
	| Call function to select rows which will be included|
	| for update in mrp_recommendations and 			 |
	| mrp_sugg_rep_schedules.						     |
	+----------------------------------------------------*/

	l_no_rec_rows :=  select_rec_rows(l_where_clause);
	l_no_rep_rows :=  select_rep_rows(l_where_clause);

	/*----------------------------------------------------+
	| First call function to update error messages for   |
	| all records.                                       |
    +----------------------------------------------------*/


    update_pre_process_errors(l_no_rec_rows,
							  l_no_rep_rows);

	/*---------------------------------------------------+
	| Process rows in mrp_recommendations.				 |
	+----------------------------------------------------*/


	if(l_no_rec_rows > 0) then


		/*---------------------------------------------------+
		| Update Attributes in MRP_RECOMMENDATIONS	   		 |
		+----------------------------------------------------*/

		update_recom_attrib(
						l_employee_id,
						l_demand_class,
						l_def_job_class,
						l_def_firm_jobs);



	end if;

	/*---------------------------------------------------+
	| Process rows in mrp_sugg_rep_schedules		     |
	+----------------------------------------------------*/

	if(l_no_rep_rows > 0) then

		  /*---------------------------------------------------+
		  | First call function to update error messages for   |
		  | all records.                                       |
		  +----------------------------------------------------*/




		  /*---------------------------------------------------+
		  | Update Attributes in MRP_SUGG_REP_SCHEDULES		   |
		  +----------------------------------------------------*/

		  update_rep_attrib(l_demand_class);

	end if;

	/*----------------------------------------------------------+
	|  Get the total number of error rows in the rows processed |
	|  and update row counts.									|
	+-----------------------------------------------------------*/

	l_error_rows := Count_Row_Errors;

	p_total_rows := l_no_rep_rows + l_no_rec_rows;
	p_error_rows := l_error_rows;
	p_succ_rows := p_total_rows - p_error_rows;

 	/*---------------------------------------------------+
	|   Delete rows from mrp_form_query.                 |
	+----------------------------------------------------*/

	delete mrp_form_query
	where query_id = g_rec_query_id;

	delete mrp_form_query
	where query_id = g_rep_query_id;


 EXCEPTION
    WHEN OTHERS THEN
        p_total_rows := 0;
        p_error_rows := 0;
        p_succ_rows := 0;
END;

/************************************************************
| This procedure sets release errors to valid error messages |
| based on checking the values of certain attributes.		 |
**************************************************************/

Procedure  Update_Pre_Process_Errors(p_no_rec_rows IN NUMBER,
									p_no_rep_rows IN NUMBER) IS
l_no_rec_rows NUMBER;
l_no_rep_rows NUMBER;
l_mesg_str VARCHAR2(2000) := NULL;
l_user_id NUMBER;
release_configs VARCHAR2(1) := 'N';
BEGIN

	l_no_rep_rows := p_no_rep_rows;
	l_no_rec_rows := p_no_rec_rows;
	l_user_id := FND_PROFILE.VALUE('USER_ID');
        begin
          select nvl(ORDERS_RELEASE_CONFIGS,'N')
          into release_configs
          from mrp_workbench_display_options
          where user_id = l_user_id;
        exception
          when others then
           release_configs  := 'N';
        end;
	if(l_no_rec_rows > 0) then

		/*-----------------------------------------------------+
		| Set All Old Error messages to Null.	 			   |
		+------------------------------------------------------*/

		update mrp_recommendations
		set release_errors = NULL
		where transaction_id IN
		(SELECT number1 from mrp_form_query
		 where
		 query_id = g_rec_query_id)
		AND release_errors is NOT NULL;

		/*-----------------------------------------------------+
		| Update Error Message that Models/Option Classes      |
		| cannot be released.								   |
		+--------------------------------------------------- --*/

		l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_MODEL');

		update mrp_recommendations mr
		set release_errors = l_mesg_str
		where transaction_id IN
			(SELECT number1 from mrp_form_query
		 	 where
		 	 query_id = g_rec_query_id)
		and (inventory_item_id, organization_id) IN
			(select inventory_item_id,
					organization_id
			 from mrp_system_items msi
			 where msi.compile_designator = mr.compile_designator
			 AND   msi.bom_item_type in (1, 2, 3, 5));
               --Bug3294041 Do not let user release Action=none records.
               l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ACTION_NONE');
		update mrp_recommendations mr
		set release_errors = l_mesg_str
		where transaction_id IN
			(SELECT number1 from mrp_form_query
		 	 where
		 	 query_id = g_rec_query_id)
		and (((inventory_item_id, organization_id) IN
			(select inventory_item_id,
					organization_id
			 from mrp_system_items msi
			 where msi.compile_designator = mr.compile_designator
			 AND   msi.base_item_id is not null
                         and   release_configs = 'N')) OR
                 ( mr.rescheduled_flag =1) OR
                 ( mr.firm_planned_type =1 and mr.order_type <> 5) OR
                 ( mr.order_type =5 and
                   nvl(mr.implemented_quantity,0)+nvl(mr.quantity_in_process,0)
---Bug 4372937 New PO line is not released
---                       >= mr.new_order_quantity) OR
                       >= nvl(mr.firm_quantity,mr.new_order_quantity) and
		       nvl(mr.release_status,0) <> 1) OR      		--bug 4655229
                   (mr.old_schedule_date = mr.new_schedule_date and
                   DISPOSITION_STATUS_TYPE <> 2 and
                   mr.order_type IN (2,3)));

	   /*-------------------------------------------------------+
	   | Add Error Message that Kanban Items Cannot be Released.|
	   +--------------------------------------------------------*/

	   l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_KANBAN');

		update mrp_recommendations mr
		set release_errors = release_errors||l_mesg_str
		where transaction_id IN
			(SELECT number1 from mrp_form_query
			 where
		  	 query_id = g_rec_query_id)
	    and (inventory_item_id, organization_id) IN
			  (select flex.inventory_item_id,
			   flex.organization_id
			   from mrp_system_items msi,
					mtl_item_flexfields flex
			   where msi.compile_designator = mr.compile_designator
			   and	 flex.inventory_item_id = msi.inventory_item_id
			   and	 flex.organization_id = msi.organization_id
			   and   flex.release_time_fence_code = 6);

	/*--------------------------------------------------------------+
	| Add Error Message that Items in Orgs modelled as Customer or  |
	| Supplier cannot be released.                                  |
	+---------------------------------------------------------------*/

	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_CUST_SUPP');

	update mrp_recommendations mr
	set release_errors = release_errors||l_mesg_str
	where transaction_id IN
		(SELECT number1 from mrp_form_query
		 where
		 query_id = g_rec_query_id)
	AND	organization_id IN (select organization_id
							from mrp_cust_sup_org_v);

	/*---------------------------------------------------------------+
	| Add Error Message that Record was generated as part of some    |
	| other plan/schedule.											 |
	+----------------------------------------------------------------*/

	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_IN_SOURCE_PLAN');

	update mrp_recommendations mr
	set release_errors = release_errors||l_mesg_str
	where transaction_id IN
		(SELECT number1 from mrp_form_query
		 where
	  	 query_id = g_rec_query_id)
	and (inventory_item_id, organization_id) IN
		(select inventory_item_id, organization_id
		 from mrp_system_items msi
		 where msi.compile_designator = mr.compile_designator
		 and  msi.inventory_item_id = mr.inventory_item_id
		 and  msi.organization_id = mr.organization_id
		 and  msi.in_source_plan = 1);

    l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_NO_FLOW_ROUTING');
    -- bug 5462184: added check of source_vendor_id and organization_id in where clause
    --              This will not allow release of recommendations whose source type is Make-At

    update mrp_recommendations mr
    set release_errors = release_errors||l_mesg_str
        where transaction_id IN
            (SELECT number1 from mrp_form_query
             where query_id = g_rec_query_id)
        and mr.order_type =5
        and mr.source_vendor_id is null
        and mr.organization_id = nvl(mr.source_organization_id,mr.organization_id)
        and exists ( select 1 from bom_operational_routings
                     where assembly_item_id = mr.inventory_item_id
                     and   organization_id = mr.organization_id
                     and   nvl(alternate_routing_designator,'-23453') =
                               nvl(mr.alternate_routing_designator,'-23453')
                     and   cfm_routing_flag = 1);

	end if;

    if(l_no_rep_rows > 0) then

		/*-----------------------------------------------------+
		| Set All Old Error messages to Null.	 			   |
		+------------------------------------------------------*/

		update mrp_sugg_rep_schedules
		set release_errors = NULL
		where rowid IN
		(SELECT char1 from mrp_form_query
		 where
		 query_id = g_rep_query_id)
		AND release_errors is NOT NULL;

		/*-----------------------------------------------------+
		| Update Error Message that Models/Option Classes      |
		| cannot be released.								   |
		+--------------------------------------------------- --*/

		l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_MODEL');

		update mrp_sugg_rep_schedules msrs
		set release_errors = l_mesg_str
		where rowid IN
			(SELECT char1 from mrp_form_query
		 	 where
		 	 query_id = g_rep_query_id)
		and (inventory_item_id, organization_id) IN
			(select inventory_item_id,
					organization_id
			 from mrp_system_items msi
			 where msi.compile_designator = msrs.compile_designator
			 AND   msi.bom_item_type in (1, 2, 3, 5));


		/*--------------------------------------------------------------+
		| Add Error Message that Items in Orgs modelled as Customer or  |
		| Supplier cannot be released.                                  |
		+---------------------------------------------------------------*/

		l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_CUST_SUPP');

		update mrp_sugg_rep_schedules msrs
		set release_errors = release_errors||l_mesg_str
		where rowid IN
			(SELECT char1 from mrp_form_query
		 	 where
		 	query_id = g_rep_query_id)
		 AND	organization_id IN (select organization_id
				from mrp_cust_sup_org_v);


		/*---------------------------------------------------------------+
		| Add Error Message that Record was generated as part of some    |
		| other plan/schedule.                                           |
		+----------------------------------------------------------------*/

		l_mesg_str := FND_MESSAGE.GET_STRING('MRP',
							'MRP_REL_ALL_IN_SOURCE_PLAN');

	  	update mrp_sugg_rep_schedules msrs
		set release_errors = release_errors||l_mesg_str
		where rowid IN
					  (SELECT char1 from mrp_form_query
					   where
					   query_id = g_rep_query_id)
		and (inventory_item_id, organization_id) IN
					(select inventory_item_id, organization_id
					 from mrp_system_items msi
					 where msi.compile_designator = msrs.compile_designator
					 and  msi.inventory_item_id = msrs.inventory_item_id
					 and  msi.organization_id = msrs.organization_id
		and  msi.in_source_plan = 1);



	end if;

END;

/******************************************************************
* This function  inserts rows in mrp_form_query for all the       *
* transaction id of the records which need to be selected for 	  *
* release. This is done for records in table mrp_recommendations. *
******************************************************************/

FUNCTION Select_Rec_Rows(p_where_clause IN VARCHAR2) return NUMBER
IS
l_where_clause VARCHAR2(32767) := NULL;
l_sql_stmt  VARCHAR2(32767) := NULL;

l_rows_processed INTEGER;
l_cursor INTEGER;

CURSOR GET_QUERY_ID IS
SELECT MRP_FORM_QUERY_S.NEXTVAL
FROM DUAL;
BEGIN

	l_where_clause := p_where_clause;


	OPEN GET_QUERY_ID;
	FETCH GET_QUERY_ID INTO g_rec_query_id;
	CLOSE GET_QUERY_ID;


	l_sql_stmt :=
		'INSERT INTO mrp_form_query ( '||
			'query_id, last_update_date, last_updated_by, '||
			'creation_date, created_by, number1)' ||
		 'SELECT ' ||
		 g_rec_query_id || ',' ||
		 'TRUNC(SYSDATE), '||
		 '-1, '||
		 'TRUNC(SYSDATE), '||
		 '-1, ' ||
		 'mr.transaction_id ' ||
		 ' from mrp_recommendations mr' ||
      	 ' where transaction_id IN ' ||
		 '(SELECT transaction_id from mrp_orders_sc_v  ' ||
	 	 ' where ' ||
	 	 l_where_clause ||
		 ' and order_type IN (2, 3, 5))';

	-- get a cursor handle
	l_cursor := dbms_sql.open_cursor;


	-- parse the sql statement that we just built
		dbms_sql.parse (l_cursor, l_sql_stmt, dbms_sql.native);

	-- now execute the sql stmt
		l_rows_processed := dbms_sql.execute(l_cursor);

	 -- close the cursor
	 	dbms_sql.close_cursor (l_cursor);

	return l_rows_processed;

END;

/******************************************************************
* This function  inserts rows in mrp_form_query for all the       *
* transaction id of the records which need to be selected for     *
* release. This is done for records in table 					  *
* mrp_sugg_rep_schedules.										  *
******************************************************************/

FUNCTION Select_Rep_Rows(p_where_clause IN VARCHAR2) return NUMBER
IS
l_where_clause VARCHAR2(32767) := NULL;
l_sql_stmt  VARCHAR2(32767) := NULL;

l_rows_processed INTEGER;
l_cursor INTEGER;

CURSOR GET_QUERY_ID IS
SELECT MRP_FORM_QUERY_S.NEXTVAL
FROM DUAL;
BEGIN

	l_where_clause := p_where_clause;


	OPEN GET_QUERY_ID;
	FETCH GET_QUERY_ID INTO g_rep_query_id;
	CLOSE GET_QUERY_ID;


	l_sql_stmt :=
		'INSERT INTO mrp_form_query ( '||
			'query_id, last_update_date, last_updated_by, '||
			'creation_date, created_by, number1,char1)' ||
		 'SELECT ' ||
		 g_rep_query_id || ',' ||
		 'TRUNC(SYSDATE), '||
		 '-1, '||
		 'TRUNC(SYSDATE), '||
		 '-1, ' ||
		 'mr.transaction_id ,'||
                 'mr.rowid ' ||
		 ' from mrp_sugg_rep_schedules mr' ||
      	 ' where rowid IN ' ||
		 '(SELECT row_id from mrp_orders_sc_v  ' ||
	 	 ' where ' ||
	 	 l_where_clause ||
		 ' and order_type =13)'||
         ' AND nvl(status,0) <> 3' ; --bug2797945

	-- get a cursor handle
	l_cursor := dbms_sql.open_cursor;


	-- parse the sql statement that we just built
		dbms_sql.parse (l_cursor, l_sql_stmt, dbms_sql.native);

	-- now execute the sql stmt
		l_rows_processed := dbms_sql.execute(l_cursor);

	 -- close the cursor
	 	dbms_sql.close_cursor (l_cursor);

	return l_rows_processed;

END;

/***********************************************************************
*  This procedure performs 2 sets of functions:

   --- Updates Attributes in mrp_recommendations for records to be selected
   	   for release.

   --- Updated post processing errors to the release errors column
	   in mrp_recommendations. The errors are updated
       in between attribut update statements. The order of these
       SQL statements is of great significance, otherwise client side
       field properties such (as REQUIRED/UPDATABLE are affected).
       Indiscriminately changing the order will create Client Side
       Bugs.
***********************************************************************/


PROCEDURE Update_Recom_Attrib(
							  p_employee_id IN NUMBER,
							  p_demand_class IN VARCHAR2,
							  p_def_job_class IN VARCHAR2,
							  p_def_firm_jobs IN VARCHAR2) IS


l_sql_stmt	VARCHAR2(32767) := NULL;
l_rows_processed INTEGER;
l_wip_job_prefix VARCHAR2(240) := NULL;
l_wip_seq VARCHAR2(200) := NULL;
l_def_job_class VARCHAR2(10) := NULL;
l_def_firm_jobs VARCHAR2(1) := 'N';
l_demand_class VARCHAR2(30) := NULL;
l_err_mesg1 VARCHAR2(200);
l_err_class1 VARCHAR2(200);
l_err_mesg2 VARCHAR2(200);
l_err_class2 VARCHAR2(200);
l_mesg_str VARCHAR2(2000) := NULL;

l_cursor INTEGER;

l_employee_id NUMBER;
l_user_id NUMBER;
l_session_id NUMBER;


BEGIN


	l_wip_job_prefix := FND_PROFILE.VALUE('WIP_JOB_PREFIX');
	l_user_id := FND_PROFILE.VALUE('USER_ID');
	--l_wip_seq := 'to_char(wip_job_number_s.nextval)';

	l_employee_id := p_employee_id;
	l_demand_class := p_demand_class;
	l_def_job_class := p_def_job_class;
	l_def_firm_jobs := p_def_firm_jobs;

        select userenv('SESSIONID') into l_session_id from dual;

    /*-------------------------------------------------------------+
	| Update implement as attribute for planned orders.			   |
	+--------------------------------------------------------------*/

	update mrp_recommendations mr
	set implement_as =
			(select
			   mfg.lookup_code
			 from
			 mfg_lookups mfg,
			 mrp_system_items msi
			 where mfg.lookup_code  =
				DECODE(mr.source_organization_id,
  					   mr.organization_id,
		   			   DECODE(msi.build_in_wip_flag, 1, 3, 1),
					   DECODE(msi.purchasing_enabled_flag, 1, 2, 1))
			 and mfg.lookup_type = 'MRP_WORKBENCH_IMPLEMENT_AS'
			 and msi.inventory_item_id = mr.inventory_item_id
			 and msi.organization_id = mr.organization_id
	    	 and msi.compile_designator = mr.compile_designator)
	where transaction_id IN
		(SELECT number1 from mrp_form_query
	 	 where
		 query_id = g_rec_query_id)
	AND mr.release_errors is NULL
	AND mr.order_type = 5
	AND (mr.status <> 0 or nvl(mr.applied, 0) <> 2)
	AND	mr.implement_as IS NULL;
        --
        -- missed out in 115.16, bug 2601516
        --
         update mrp_recommendations mr
    set implement_as =
            (select
                mfg.lookup_code
             from mfg_lookups mfg,
                  mrp_system_items msi
             where mfg.lookup_code =
                DECODE(msi.planning_make_buy_code,
                       1, DECODE(msi.build_in_wip_flag, 1, 3, 1),
                       DECODE(msi.purchasing_enabled_flag, 1, 2, 1))
             and mfg.lookup_type = 'MRP_WORKBENCH_IMPLEMENT_AS'
             and msi.inventory_item_id = mr.inventory_item_id
             and msi.organization_id = mr.organization_id
             and msi.compile_designator = mr.compile_designator)
    where transaction_id IN
            (SELECT number1 from mrp_form_query
             where
             query_id = g_rec_query_id)
    AND mr.order_type = 5
    AND mr.status = 0
    AND nvl(mr.applied, 0) = 2
    AND mr.implement_as IS NULL;
    --
	update mrp_recommendations mr
        set implement_status_code =
            (select
                orders_default_job_status
             from mrp_workbench_display_options
             WHERE user_id = l_user_id),
         mr.created_by = l_user_id
    where transaction_id IN
            (SELECT number1 from mrp_form_query
             where
             query_id = g_rec_query_id)
    AND mr.order_type = 5
    AND mr.implement_as = 3
    AND mr.release_errors is NULL;
        /*--------------------------------------------------------------+
        | default implement unit number for planned orders which are     |
	| unit number control.
	---------------------------------------------------------------*/

 	update mrp_recommendations mr
	set implement_end_item_unit_number =
		nvl(implement_end_item_unit_number,end_item_unit_number)
	where transaction_id in
	      (select number1 from mrp_form_query
	 	where query_id=g_rec_query_id)
	and release_errors is null
        and order_type =5
        and (inventory_item_id, organization_id) in
	       (select inventory_item_id, organization_id
	 	from mrp_system_items msi
		where msi.compile_designator=mr.compile_designator
	    	and msi.effectivity_control=2);
        /*--------------------------------------------------------------+
	| add error message if implement_unit_number is null		|
	| for planned order which is unit number control		|
	---------------------------------------------------------------*/

	l_mesg_str := fnd_message.get_string('MRP', 'MRP_REL_ALL_UNIT_NUMBER');
	update mrp_recommendations mr
        set release_errors = release_errors || l_mesg_str
        where transaction_id in
              (select number1 from mrp_form_query
                where query_id=g_rec_query_id)
        and implement_end_item_unit_number is null
        and (inventory_item_id, organization_id) in
               (select inventory_item_id, organization_id
                from mrp_system_items msi
                where msi.compile_designator=mr.compile_designator
                and msi.effectivity_control=2);

  	/*--------------------------------------------------------------+
	| Update the following attributes  in mrp_recommendations for   |
	| Planned orders being implemented as Purchase Requisitions and |
	| Purchase Requisitions being rescheduled.						|
	|                                                               |
	+---------------------------------------------------------------*/

	update mrp_recommendations mr
	set implement_location_id =
						(select
						   hr.location_id
						 from hr_locations hr,
							  hr_organization_units per
					     where per.organization_id = mr.organization_id
						 and   per.location_id = hr.location_id)
	where  transaction_id IN
			(SELECT number1 from mrp_form_query
	 		 where
	 		query_id = g_rec_query_id)
	 AND ((mr.order_type = 5 AND mr.implement_as = 2) OR
		  mr.order_type = 2)
	 AND mr.implement_location_id is NULL
	 AND mr.release_errors IS NULL;

	/*--------------------------------------------------------------+
	| Set Error Messages and Update release status to no for records|
	| which fail certain criteria.									|
	+---------------------------------------------------------------*/

	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_LOCATION');

	update mrp_recommendations mr
	set release_errors = release_errors || l_mesg_str
	where transaction_id IN
		(SELECT number1 from mrp_form_query
		 where
		 query_id = g_rec_query_id)
	AND ((mr.order_type = 5 AND mr.implement_as = 2) OR
	  mr.order_type = 2)
	AND mr.implement_location_id is NULL;

	if(l_employee_id is NULL) then

		 l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_EMPLOYEE');

	  	 update mrp_recommendations mr
		 set release_errors = release_errors || l_mesg_str,
			 implement_as = NULL,
			 release_status = 2
	  	 where transaction_id IN
			  (SELECT number1 from mrp_form_query
			   where
			   query_id = g_rec_query_id)
		 AND ((mr.order_type = 5 AND mr.implement_as = 2) OR
			  mr.order_type = 2);


																					end if;

	 /*------------------------------------------------------+
	 | Update following attributes  in mrp_recommendations   |
	 | for planned orders, purchase reqs and                 |
	 | discete jobs.                                         |
	 |                                                       |
	 | implement job_name          implement_employee_id     |
	 | implement_vendor_id         implement_vendor_site_id  |
	 | implement_source_org_id     implement_demand_class    |
	 | implement_date              release_status            |
     | implement_quantity          implement_project_id      |
	 | implement_task_id           rescheduled_flag          |
	 | implement_firm                                        |
	 +-------------------------------------------------------*/
--dbms_output.put_line('going ot implement_date');
	update mrp_recommendations mr
	SET
	implement_date = nvl(mr.implement_date,		 relall_next_work_day(
						    mr.organization_id,
							 1,
 				    		 GREATEST(NVL(mr.firm_date,
										  mr.new_schedule_date),
									  TRUNC(SYSDATE)))),
	implement_project_id = nvl(mr.implement_project_id,
				   DECODE(mr.order_type, 2,
			  	  NULL,
			 	  nvl(mr.implement_project_id,
				  mr.project_id))),
	implement_task_id = nvl(mr.implement_task_id,
				DECODE(mr.order_type, 2,
			   	   NULL,
			 	   nvl(mr.implement_task_id,
			   	   mr.task_id)))
	where  transaction_id IN
		(SELECT number1 from mrp_form_query
		 	 where
	  	 	 query_id = g_rec_query_id)
	    AND mr.release_errors IS NULL
	    AND mr.order_type IN (2, 3, 5);



	/*--------------------------------------------------------------+
	| Update Error Message for Records with implement date equals   |
	| to NULL.														|
	+---------------------------------------------------------------*/

	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_IMPL_DATE');

	update mrp_recommendations mr
	set release_errors = release_errors || l_mesg_str
	where transaction_id IN
   (SELECT number1 from mrp_form_query
	where
	query_id = g_rec_query_id)
 	AND mr.implement_date is NULL
	AND mr.release_errors is NULL;


	/*--------------------------------------------------------------+
	| Update Project Control Level Specific Error Messages 		    |
	|																|
	+---------------------------------------------------------------*/

	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_NO_PROJECT');

	update mrp_recommendations mr
	set release_errors = release_errors || l_mesg_str
	where transaction_id IN
		(SELECT number1 from mrp_form_query
		 where
		 query_id = g_rec_query_id)
	and implement_project_id IS NULL
        and order_type <>2
        and mr.project_id is NOT NULL
	and organization_id IN
				(select organization_id from mtl_parameters mp
				 where mp.project_control_level = 1
				 and   mp.project_reference_enabled = 1
				 and   mp.organization_id = mr.organization_id);

	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_NO_TASK');

	update mrp_recommendations mr
	set release_errors = release_errors || l_mesg_str
	where transaction_id IN
		 (SELECT number1 from mrp_form_query
		  where
	   	  query_id = g_rec_query_id)
   	and implement_task_id IS NULL
        and order_type <>2
        and mr.project_id is NOT NULL
        and mr.task_id is NOT NULL
    and organization_id IN
		  (select organization_id from mtl_parameters mp
		   where mp.project_control_level = 2
		   and   mp.project_reference_enabled = 1
		   and	 mp.organization_id = mr.organization_id);

	 /*------------------------------------------------------+
	 | Update following attributes  in mrp_recommendations   |
	 | for planned orders, purchase reqs and                 |
	 | discete jobs.                                         |
	 |                                                       |
	 | implement job_name          implement_employee_id     |
	 | implement_vendor_id         implement_vendor_site_id  |
	 | implement_source_org_id     implement_demand_class    |
	 | implement_date              release_status            |
     | implement_quantity          implement_project_id      |
	 | implement_task_id           rescheduled_flag          |
	 | implement_firm                                        |
	 +-------------------------------------------------------*/

	update mrp_recommendations mr
	SET
	implement_quantity =
		nvl(implement_quantity,
			DECODE(mr.disposition_status_type,
 			   	   2, 0,
			       GREATEST(NVL(mr.firm_quantity, mr.new_order_quantity)
				   - NVL(mr.quantity_in_process, 0)
				   - NVL(mr.implemented_quantity, 0), 0))),
        implement_status_code=DECODE(mr.order_type,3,
                                 nvl(implement_status_code, DECODE(mr.disposition_status_type,2,7,NULL)),
                                     implement_status_code),
	release_status = 1,
	implement_job_name= nvl(mr.implement_job_name,decode(mr.implement_as,3,l_session_id,NULL)),
	implement_employee_id  =
	 		DECODE(mr.implement_as, 2,
	   		   	   l_employee_id,
	   		   	   NULL),
	implement_vendor_id =
			nvl(mr.implement_vendor_id,DECODE(mr.implement_as, 2,
	      	   nvl(mr.implement_vendor_id, mr.source_vendor_id),
	  		       mr.implement_vendor_id)),
    implement_vendor_site_id =
	   		DECODE(mr.implement_as, 2,
	          nvl(mr.implement_vendor_site_id, mr.source_vendor_site_id),
	  		   	  mr.implement_vendor_site_id),
	implement_source_org_id =
	 		DECODE(mr.implement_as, 2,
	   		   	   DECODE(mr.source_organization_id,
	   				  mr.organization_id, NULL,
	   		          mr.source_organization_id),
	  		   	   NULL),
	implement_demand_class =
	    	DECODE(mr.implement_as,
	   			   3,nvl(mr.implement_demand_class, l_demand_class),
	   			   NULL),
	rescheduled_flag = DECODE(mr.order_type, 5,
								  2, 1),
	implement_alternate_routing = nvl(implement_alternate_routing,
										  alternate_routing_designator),
	implement_alternate_bom = nvl(implement_alternate_bom,
									  alternate_bom_designator),
	implement_firm = DECODE(mr.implement_as, 3,
								nvl(mr.implement_firm,
									DECODE(l_def_firm_jobs, 'Y',
										   1, 2)),
							    NULL)
	where  transaction_id IN
		(SELECT number1 from mrp_form_query
		 	 where
	  	 	 query_id = g_rec_query_id)
	    AND mr.release_errors IS NULL
	    AND mr.order_type IN (2, 3, 5);

	/*--------------------------------------------------------------+
	| Update the following attributes  in mrp_recommendations for 	|
	| planned orders:												|
	| Quantity In Process    Implement WIP Class Code				|
	+---------------------------------------------------------------*/

	/* The rel_all_quantity  holds the old implement quantity used in the
	** Select All for Release Session. If rel_all_qty is -9999, it implies that
	** the quantity in process is already updated in the client and we don't
	** need to do it here.
	*/

	update mrp_recommendations mr
	set quantity_in_process =
				DECODE(mr.number1,
					   -9999, mr.quantity_in_process,
				 		GREATEST(0,
							NVL(mr.quantity_in_process, 0) +
							NVL(mr.implement_quantity, 0) -
							NVL(mr.number1,0))),
	implement_wip_class_code =
		nvl(mr.implement_wip_class_code, DECODE(mr.implement_as, 3,
		   	nvl(l_def_job_class,   relall_default_acc_class(
							mr.organization_id,
							mr.inventory_item_id,
							1,
							nvl(mr.implement_project_id,
								mr.project_id))),
							NULL)),
	number1 = DECODE(mr.order_type,
					 	 5, mr.implement_quantity,
						 mr.number1)
	where  transaction_id IN
			(SELECT number1 from mrp_form_query
		 	 where
			 query_id = g_rec_query_id)
	AND mr.release_errors IS NULL
	AND mr.order_type = 5;

   /*-------------------------------------------------------------------+
   | update load_type
   +--------------------------------------------------------------------*/
    update mrp_recommendations mr
    SET
    load_type =decode(order_type, 5, decode(implement_as, 3, 1, 2, 8, null),
                      3, 4, 2, 16, null)
    where transaction_id in
          (select number1 from mrp_form_query
             where query_id = g_rec_query_id)
    AND mr.release_status=1;

	/*--------------------------------------------------------------+
	| Update attributes for Errored Records							|
	+---------------------------------------------------------------*/

	update mrp_recommendations
	SET
	implement_as = NULL,
	implement_quantity = NULL,
	implement_date = NULL,
	release_status = 2
	where transaction_id in
		(select number1 from mrp_form_query
					 where query_id = g_rec_query_id)
	and release_errors is not NULL;
        --
        /*______________________________________________________________+
        | Bug 1826152 Set Status And Applied fields for color change    |
        +_______________________________________________________________*/
        --
        UPDATE mrp_recommendations
        SET status = 0,
            applied = 2
        WHERE order_type IN (2,3,5)
        AND   nvl(release_status,2) = 1
        AND   release_errors is NULL
        AND   transaction_id in
             (select number1 from mrp_form_query
                     where query_id = g_rec_query_id);
        --
        -- End of Change for bug 1826152
        --
END;


PROCEDURE Update_Rep_Attrib(p_demand_class IN VARCHAR2) IS
l_demand_class VARCHAR2(30) := NULL;
l_mesg_str VARCHAR2(2000) := NULL;
BEGIN

	l_demand_class := p_demand_class;


	/*------------------------------------------------------+
	| Update the following attributes in mrp_sugg_rep_      |
	| schedules												|
	|														|
	|														|
	| implement_date				release_status			|
	| implement_daily_rate			implement_demand_class  |
	| implement_line_id										|
	+------------------------------------------------------*/
    update mrp_sugg_rep_schedules msrs
		SET implement_date = nvl(msrs.implement_date,
								msrs.last_unit_completion_date),
			implement_daily_rate =  nvl(msrs.implement_daily_rate,
										msrs.daily_rate),
			implement_demand_class = nvl(msrs.implement_demand_class,
										l_demand_class),
			implement_line_id = nvl(msrs.implement_line_id,
									msrs.repetitive_line),
			implement_processing_days = DECODE(msrs.implement_processing_days,
											   NULL,
											   relall_days_between(
											   msrs.organization_id,
											   1,
											   msrs.last_unit_completion_date,
											   msrs.first_unit_completion_date)
											   +1,
											   msrs.implement_processing_days),
			release_status = 1
	where rowid IN
		(SELECT char1 from mrp_form_query
	 	 where
		 query_id = g_rep_query_id)
	AND msrs.release_errors is NULL;

	/*--------------------------------------------------------------+
	| Update Error Message for Records with implement date equals   |
	| to NULL.                                                      |
	+---------------------------------------------------------------*/


  	l_mesg_str := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_IMPL_DATE');

    update mrp_sugg_rep_schedules msrs
	set release_errors = release_errors || l_mesg_str,
	    release_status = 2
	where rowid IN
			  (SELECT char1 from mrp_form_query
				where
			  query_id = g_rep_query_id)
	 AND msrs.implement_date is NULL
	 AND msrs.release_errors is NULL;

      /*-------------------------------------------------------------+
      | update load_type
      +--------------------------------------------------------------*/

    update mrp_sugg_rep_schedules msrs
    SET
           load_type=2
    where rowid IN
                          (SELECT char1 from mrp_form_query
                                where
                          query_id = g_rep_query_id)
    AND release_status=1;

   -- Not there in 115.16
-- Bug 1783575(--bug2503086)
-- Change color to pink  and action to None after clicking
-- select all for release
-- 2797945
    UPDATE mrp_sugg_rep_schedules
    SET    status = 1
    WHERE rowid IN
                          (SELECT char1 from mrp_form_query
                                where
                          query_id = g_rep_query_id)
    AND    release_status = 1
    AND    status <> 3
    AND    release_errors is NULL;

END;


/******************************************************************
* Function to find number of records with release errors in       *
* mrp_recommendations and mrp_sugg_rep_schedules.				  *
******************************************************************/

FUNCTION Count_Row_Errors return NUMBER IS
l_rep_errors NUMBER;
l_rec_errors NUMBER;
l_tot_errors NUMBER;
BEGIN

	l_rep_errors := 0;
	l_rec_errors := 0;
	l_tot_errors := 0;

	SELECT
		count(1)
	into
		l_rec_errors
	from mrp_recommendations
	where transaction_id IN
		  (SELECT number1 from mrp_form_query
		   where
		   query_id = g_rec_query_id)
	and release_errors is NOT NULL;

	SELECT
		count(1)
	into
		l_rep_errors
	from mrp_sugg_rep_schedules
	where rowid IN
	  (SELECT char1 from mrp_form_query
	   where
	   query_id = g_rep_query_id)
	and release_errors is not NULL;

	l_tot_errors := l_rep_errors + l_rec_errors;

	return(l_tot_errors);


END;

/*------------------------------------------------------------------+
| Calendar Routines copied from mrp_calendar to this Package to     |
| take care of pragma issues.										|
+-------------------------------------------------------------------*/


FUNCTION RELALL_NEXT_WORK_DAY(arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN

--dbms_output.put_line('arg date'||arg_date);
--dbms_output.put_line('bucket'||arg_bucket);
--dbms_output.put_line('org'|| arg_org_id);
   IF arg_date is NULL or arg_org_id is NULL or arg_bucket is NULL THEN
        RETURN NULL;
   END IF;
   relall_select_cal_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);


    RELALL_MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN

        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_date THEN
            var_return_date := max_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.next_date
            INTO    var_return_date
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;

    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MIN(cal.week_start_date)
            INTO    var_return_date
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date >= TRUNC(arg_date);
        END IF;

    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date >= max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date < min_period_date THEN
            var_return_date := min_period_date;
        ELSE
            SELECT  MIN(cal.period_start_date)
            INTO    var_return_date
            FROM    bom_period_start_dates  cal
             WHERE  cal.exception_set_id = var_exception_set_id
               AND  cal.calendar_code = var_calendar_code
               AND  cal.period_start_date >= TRUNC(arg_date);
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
END RELALL_NEXT_WORK_DAY;

PROCEDURE RELALL_SELECT_CAL_DEFAULTS(
		arg_org_id IN NUMBER,
		arg_calendar_code OUT NOCOPY VARCHAR2,
        arg_exception_set_id OUT NOCOPY NUMBER) IS

BEGIN
    SELECT   calendar_code,
             calendar_exception_set_id
    INTO     arg_calendar_code,
             arg_exception_set_id
    FROM     mtl_parameters
    WHERE    organization_id = arg_org_id;

    IF SQL%NOTFOUND THEN
        raise_application_error(-200000, 'Cannot select calendar defaults');
    END IF;

END RELALL_SELECT_CAL_DEFAULTS;

PROCEDURE RELALL_MRP_CAL_INIT_GLOBAL(  arg_calendar_code       VARCHAR,
                                arg_exception_set_id    NUMBER) IS
temp_char   VARCHAR2(30);
BEGIN
    --dbms_output.put_line('In MRP_CAL_INIT_GLOBAL');
    IF arg_calendar_code <> mrp_calendar_cal_code OR
        arg_exception_set_id <> mrp_calendar_excep_set THEN

        SELECT  min(calendar_date), max(calendar_date), min(seq_num),
                    max(seq_num)
        INTO    min_date, max_date, min_seq_num, max_seq_num
        FROM    bom_calendar_dates
        WHERE   calendar_code = arg_calendar_code
        AND     seq_num is not null
        AND     exception_set_id = arg_exception_set_id;

        SELECT  min(period_start_date), max(period_start_date)
        INTO    min_period_date, max_period_date
        FROM    bom_period_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id;

        SELECT  min(week_start_date), max(week_start_date), min(seq_num),
                max(seq_num)
        INTO    min_week_date, max_week_date, min_week_seq_num,
                max_week_seq_num
        FROM    bom_cal_week_start_dates
        WHERE   calendar_code = arg_calendar_code
        AND     exception_set_id = arg_exception_set_id;

        mrp_calendar_cal_code := arg_calendar_code;
        mrp_calendar_excep_set := arg_exception_set_id;
    END IF;

    IF MRP_CALENDAR_RET_DATES = 0 THEN
        --dbms_output.put_line('Getting value of profile');
        temp_Char := FND_PROFILE.VALUE('MRP_RETAIN_DATES_WTIN_CAL_BOUNDARY');
        IF temp_Char = 'Y' THEN
            MRP_CALENDAR_RET_DATES := 1;
        ELSE
            MRP_CALENDAR_RET_DATES := 2;
        END IF;
    END IF;
    --dbms_output.put_line(to_char(MRP_CALENDAR_RET_DATES));
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
END RELALL_MRP_CAL_INIT_GLOBAL;


FUNCTION RELALL_DAYS_BETWEEN( arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date1 IN DATE,
                       arg_date2 IN DATE) RETURN NUMBER IS
BEGIN
    relall_select_cal_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    IF arg_date1 is NULL or arg_bucket is null or arg_org_id is null
        or arg_date2 IS NULL THEN
        RETURN NULL;
    END IF;

    RELALL_MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF (arg_bucket <> TYPE_MONTHLY_BUCKET) THEN
      var_prev_seq_num := RELALL_PREV_WORK_DAY_SEQNUM(arg_org_id, arg_bucket, arg_date1);
      var_prev_seq_num2 := RELALL_PREV_WORK_DAY_SEQNUM(arg_org_id, arg_bucket, arg_date2);
      var_return_number := ABS(var_prev_seq_num2 - var_prev_seq_num);
    ELSE
      var_prev_work_day := RELALL_PREV_WORK_DAY(arg_org_id, arg_bucket, arg_date1);
      var_prev_work_day2 := RELALL_PREV_WORK_DAY(arg_org_id, arg_bucket, arg_date2);
      SELECT count(period_start_date)
      INTO var_return_number
      FROM bom_period_start_dates cal
      WHERE cal.exception_set_id = var_exception_set_id
      AND   cal.calendar_code = var_calendar_code
      AND   cal.period_start_date between var_prev_work_day
        and var_prev_work_day2
      AND   cal.period_start_date <> var_prev_work_day2;

    END IF;

    return var_return_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
END RELALL_DAYS_BETWEEN;

FUNCTION RELALL_PREV_WORK_DAY(arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN DATE IS
BEGIN
   IF arg_date is NULL or arg_org_id is NULL or arg_bucket is NULL THEN
        RETURN NULL;
   END IF;
    relall_select_cal_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    RELALL_MRP_CAL_INIT_GLOBAL(var_calendar_code, var_exception_set_id);
    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_date := max_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_date := min_date;
        ELSE
            SELECT  cal.prior_date
            INTO    var_return_date
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_date := max_week_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_date := min_week_date;
        ELSE
            SELECT  MAX(cal.week_start_date)
            INTO    var_return_date
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_period_date THEN
            var_return_date := max_period_date;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_period_date THEN
            var_return_date := min_period_date;
        ELSE
            SELECT  MAX(cal.period_start_date)
            INTO    var_return_date
            FROM    bom_period_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.period_start_date <= TRUNC(arg_date);
        END IF;
    END IF;

    return var_return_date;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
END RELALL_PREV_WORK_DAY;

FUNCTION RELALL_PREV_WORK_DAY_SEQNUM(arg_org_id IN NUMBER,
                       arg_bucket IN NUMBER,
                       arg_date IN DATE) RETURN NUMBER IS
BEGIN
    relall_select_cal_defaults(arg_org_id,
            var_calendar_code, var_exception_set_id);

    IF arg_bucket = TYPE_DAILY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_date THEN
            var_return_number := max_seq_num;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_date THEN
            var_return_number := min_seq_num;
        ELSE
            SELECT  cal.prior_seq_num
            INTO    var_return_number
            FROM    bom_calendar_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.calendar_date = TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_WEEKLY_BUCKET THEN
        IF MRP_CALENDAR_RET_DATES = 1 AND arg_date > max_week_date THEN
            var_return_number := max_week_seq_num;
        ELSIF MRP_CALENDAR_RET_DATES = 1 AND arg_date <= min_week_date THEN
            var_return_number := min_week_seq_num;
        ELSE
            SELECT  MAX(cal.seq_num)
            INTO    var_return_number
            FROM    bom_cal_week_start_dates  cal
            WHERE   cal.exception_set_id = var_exception_set_id
              AND   cal.calendar_code = var_calendar_code
              AND   cal.week_start_date <= TRUNC(arg_date);
        END IF;
    ELSIF arg_bucket = TYPE_MONTHLY_BUCKET THEN
        raise_application_error(-20000, 'Invalid bucket type');
    END IF;

    return var_return_number;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;
END RELALL_PREV_WORK_DAY_SEQNUM;

/*--------------------------------------------------------------+
| Copy of WIP routines to determine default job class. These are|
| copid here from wip_common to work around Pragma Issus.	|
+--------------------------------------------------------------*/
Function RELALL_DEFAULT_ACC_CLASS
         (X_ORG_ID       IN     NUMBER,
          X_ITEM_ID      IN     NUMBER,
          X_ENTITY_TYPE  IN     NUMBER,
          X_PROJECT_ID   IN     NUMBER
         )
return VARCHAR2 IS
  V_PRODUCT_LINE CONSTANT NUMBER := 8;
  V_COST_METHOD NUMBER(1);
  V_COST_GROUP_ID NUMBER;
  V_DISC_CLASS VARCHAR2(10);
  V_REP_CLASS VARCHAR2(10);
  V_PRJ_DEF_CLASS VARCHAR2(10);
  V_DISABLE_DATE DATE;
  V_RET NUMBER;
  V_RET1 NUMBER;
begin
  select  primary_cost_method
    into  V_COST_METHOD
  from    mtl_parameters
  where
          organization_id = X_ORG_ID;
  if( V_COST_METHOD = 1 ) then
        -- Standard Costing Organization
    begin
    	select  wdcac.std_discrete_class, wdcac.repetitive_assy_class
        	into V_DISC_CLASS, V_REP_CLASS
    	from    mtl_default_category_sets mdcs, mtl_item_categories mic,
       	     	wip_def_cat_acc_classes wdcac
    	where
            	mdcs.functional_area_id = V_PRODUCT_LINE and
            	mdcs.category_set_id = mic.category_set_id and
            	mic.organization_id = X_ORG_ID and
            	mic.inventory_item_id = X_ITEM_ID and
            	wdcac.organization_id = X_ORG_ID and
            	mic.category_id = wdcac.category_id and
            	wdcac.cost_group_id IS NULL;

        if( X_ENTITY_TYPE in (1,4) ) then
    		v_ret := relall_check_disabled
				(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
    	elsif ( X_ENTITY_TYPE = 2) then
        	v_ret := relall_check_disabled
				(V_REP_CLASS, X_ORG_ID, X_ENTITY_TYPE);
	end if;

        if( v_ret = 1 ) then
		if (X_ENTITY_TYPE in (1,4) ) then
			return(V_DISC_CLASS);
		else
			return(V_REP_CLASS);
		end if;
	else
		if( X_ENTITY_TYPE in (1,4) ) then
			V_DISC_CLASS := NULL;
		elsif( X_ENTITY_TYPE = 2) then
			return(NULL);
		end if;
	end if;

    exception
        when NO_DATA_FOUND then
		if( X_ENTITY_TYPE = 2) then
			return(NULL);
		end if;
    end;
    begin
        if X_PROJECT_ID IS NOT NULL then
                        select wip_acct_class_code
                                into V_PRJ_DEF_CLASS
                        from   mrp_project_parameters mpp
                        where
                                mpp.project_id = X_PROJECT_ID and
                                mpp.organization_id = X_ORG_ID;
        end if;
    exception
        when NO_DATA_FOUND then
                   NULL;
    end;
  elsif( V_COST_METHOD = 2) then
        -- Average Costing Organization
      if X_PROJECT_ID IS NOT NULL then
         select NVL(costing_group_id,1), wip_acct_class_code
           into V_COST_GROUP_ID, V_PRJ_DEF_CLASS
         from   mrp_project_parameters mpp
         where
                mpp.project_id = X_PROJECT_ID and
		mpp.organization_id = X_ORG_ID;
      else
         V_COST_GROUP_ID := 1;
      end if;

      begin
      		select wdcac.std_discrete_class
        		into V_DISC_CLASS
      		from   mtl_default_category_sets mdcs, mtl_item_categories mic,
             		wip_def_cat_acc_classes wdcac
      		where
            		mdcs.functional_area_id = V_PRODUCT_LINE and
            		mdcs.category_set_id = mic.category_set_id and
            		mic.organization_id = X_ORG_ID and
            		mic.inventory_item_id = X_ITEM_ID and
            		wdcac.organization_id = X_ORG_ID and
            		mic.category_id = wdcac.category_id and
            		wdcac.cost_group_id = V_COST_GROUP_ID;

    		v_ret := relall_check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
		if( v_ret = 1) then
			return(V_DISC_CLASS);
		else
			V_DISC_CLASS := NULL;
		end if;
      exception
	   when NO_DATA_FOUND then
		NULL;
      end;
  end if;

  if X_PROJECT_ID is null and V_DISC_CLASS is null then
	-- Default from wip_parameters IFF there is no project and no class
        -- defined yet.

	SELECT wp.DEFAULT_DISCRETE_CLASS
       	   into V_DISC_CLASS
       	FROM   WIP_PARAMETERS wp
        WHERE  wp.ORGANIZATION_ID = X_ORG_ID;
    	v_ret :=  relall_check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
	if ( v_ret = 0) then
		return(NULL);
	else
		v_ret1 := relall_check_valid_class(V_DISC_CLASS, X_ORG_ID);
		if( v_ret1 = 1) then
			return(V_DISC_CLASS);
		else
			return(NULL);
		end if;
	end if;
  elsif X_PROJECT_ID is not NULL and V_PRJ_DEF_CLASS is not null then
	-- Default from mrp_project_parameters

	V_DISC_CLASS := V_PRJ_DEF_CLASS;
    	v_ret := relall_check_disabled(V_DISC_CLASS, X_ORG_ID, X_ENTITY_TYPE);
	if( v_ret = 1) then
		return(V_DISC_CLASS);
	else
		return(NULL);
	end if;
  else
	return(NULL);
	-- Project Id is defined but no class defined
	-- in mrp_project_parameters or wip_def_cat_acc_classes
  end if;

exception
	when NO_DATA_FOUND then
		return(NULL);

END;

FUNCTION RELALL_CHECK_DISABLED(
	X_CLASS IN VARCHAR2,
	X_ORG_ID IN NUMBER,
	X_ENTITY_TYPE IN NUMBER)
return number is
  V_DISABLE_DATE DATE;

BEGIN
  select nvl(wac.disable_date, SYSDATE + 1) into V_DISABLE_DATE
  from wip_accounting_classes wac
  where
        wac.organization_id = X_ORG_ID and
        wac.class_type = DECODE(X_ENTITY_TYPE,1,1,2,2,4,1) and
        wac.class_code = X_CLASS;

  if V_DISABLE_DATE <= SYSDATE then
	return(0);
  else
	return(1);
  end if;

END;


FUNCTION RELALL_CHECK_VALID_CLASS(
        X_CLASS IN VARCHAR2,
        X_ORG_ID IN NUMBER)
return number is
	dummy VARCHAR2(40);
	v_primary_cost_method number;
	v_project_reference_enabled number;
BEGIN
   select PRIMARY_COST_METHOD, PROJECT_REFERENCE_ENABLED
	into v_primary_cost_method, v_project_reference_enabled
   from mtl_parameters mp
   where
 	mp.organization_id = X_ORG_ID;

   if v_primary_cost_method = 2 and v_project_reference_enabled = 1 then
      begin
   	select distinct class_code
		into dummy
   	from   cst_cg_wip_acct_classes ccwac
   	where
		  ccwac.organization_id = X_ORG_ID and
		  ccwac.class_code = X_CLASS and
		  nvl(ccwac.disable_date, SYSDATE + 1) > SYSDATE;
	return(1);
      exception
	when NO_DATA_FOUND then
		return(0);
      end ;
   else
	return(1); -- For any other org, we don't care about cost_group
   end if;

END;

/************************************************************
This procedure does a rollback if the user decides to rollback
select all for release changes.
*************************************************************/

Procedure Rollback_Action IS
BEGIN

	rollback;

END;

Procedure Commit_Action IS
BEGIN

	commit;

END;

Procedure Update_Job_Name
( arg_org_id 			IN 	NUMBER
, arg_compile_designator	IN 	VARCHAR2
) IS
l_wip_job_prefix        VARCHAR2(240);
l_session_id            NUMBER;
count1                  NUMBER;
BEGIN

l_wip_job_prefix := FND_PROFILE.VALUE('WIP_JOB_PREFIX');

select userenv('SESSIONID') into l_session_id from dual;

update mrp_recommendations mr set
implement_job_name = l_wip_job_prefix||to_char(wip_job_number_s.nextval)
where implement_job_name=to_char(l_session_id)
and mr.implement_as =3
--and mr.organization_id=arg_org_id  /*5735558*/
and mr.compile_designator=arg_compile_designator;

END;

/***============= Bug 4990499 chg begins ===========
This procedure updates the records with duplicate
job names with the wip job number sequence.
******/
/* Bug 5735558. This procedure will no longer be called. It is replaced
   by call to Update_Job_Name which will take care of the duplicate job name.
*/

Procedure Update_Identical_Job_Name
( arg_org_id 			IN 	NUMBER
, arg_compile_desig 		IN 	VARCHAR2
) IS
WIP_DIS_MASS_LOAD       CONSTANT INTEGER := 1;
l_wip_job_prefix        VARCHAR2(240);

BEGIN

l_wip_job_prefix := FND_PROFILE.VALUE('WIP_JOB_PREFIX');

update mrp_recommendations mru set implement_job_name = l_wip_job_prefix||to_char(wip_job_number_s.nextval)
where 1 < (select count(*)
      FROM  mrp_recommendations     mr
    WHERE   mr.release_errors is NULL
    AND     mr.implement_quantity > 0
--    AND     mr.organization_id = arg_org_id
    AND     mr.compile_designator = arg_compile_desig
    AND     mr.load_type = WIP_DIS_MASS_LOAD
    AND     mr.implement_job_name = mru.implement_job_name)
--AND     mru.organization_id = arg_org_id
AND     mru.compile_designator = arg_compile_desig;

END;
/*========== Bug 4990499 chg ends ======*/

END MRP_SELECT_ALL_FOR_RELEASE_PUB;

/
