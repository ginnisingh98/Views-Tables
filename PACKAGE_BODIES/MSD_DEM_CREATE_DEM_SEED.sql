--------------------------------------------------------
--  DDL for Package Body MSD_DEM_CREATE_DEM_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_CREATE_DEM_SEED" AS
/* $Header: msddemcrdemseedb.pls 120.1.12010000.2 2008/11/04 10:20:20 sjagathe ship $ */

procedure create_dem_seed_data(errbuf	OUT NOCOPY VARCHAR2,
			       retcode	OUT NOCOPY VARCHAR2,
          		       p_start_no           in  number,
          		       p_num_entities       in  number,
          		       P_entity_type        in  number default 0)
as
l_index NUMBER;
l_ebs_entity_name VARCHAR2(15);
l_dem_entity_name VARCHAR2(100);
l_stmt VARCHAR2(2000);

REAL_VALUES_SEQ varchar2(100) := 'real_values_seq';
COMPUTED_FIELDS_SEQ varchar2(100) := 'computed_fields_seq';

DM_COMPONENT varchar2(500);

type c_get_component is ref cursor;
get_component c_get_component;
l_stmt_get_component varchar2(1000);

l_component_id number;

type c_series_id is ref cursor;
get_series_id c_series_id;
l_stmt_series_id varchar2(1000);

l_series_id number;

type c_get_code is ref cursor;
get_code c_get_code;
l_stmt_get_code varchar2(1000);

l_stmt_comp varchar2(4000);

type c_user_id is ref cursor;
get_user_id c_user_id;
l_stmt_user_id varchar2(1000);

l_user_id number;

type c_query_id is ref cursor;
get_query_id c_query_id;
l_stmt_query_id varchar2(1000);

l_query_id number;

type c_display_unit_id is ref cursor;
get_display_unit_id c_display_unit_id;
l_stmt_display_unit_id varchar2(1000);

l_display_unit_id number;

type c_disp_order_id is ref cursor;
get_disp_order_id c_query_id;
l_stmt_disp_order_id varchar2(1000);

l_disp_order_id number;


begin

DEMANTRA_SCHEMA := fnd_profile.value('MSD_DEM_SCHEMA');
/*DEMANTRA_SCHEMA := 'dmtra_template';*/

if  DEMANTRA_SCHEMA is null then
	dbms_output.put_line('Demantra Schema is not set');
	return;
end if;

if p_start_no is null or p_start_no < 0 then
 	dbms_output.put_line('Please enter a valid Starting Number');
 	return;
end if;

if p_num_entities <= 0 then
 	dbms_output.put_line('Please enter a valid number for Number of entities');
 	return;
end if;

if p_num_entities > 100 then
 	dbms_output.put_line('Please enter number of entities < 100');
 	return;
end if;

if P_entity_type <> 0 and P_entity_type <> 1 and P_entity_type <> 2 and P_entity_type <> 3 then
 	dbms_output.put_line('Please enter Entity Type as 1 (UOM), 2 (CURRENCY), 3 (PRICE LIST) , 0 (ALL) ');
 	return;
end if;


dbms_output.put_line('Start Number = ' || p_start_no || ', Number of entities = ' || p_num_entities);


if p_entity_type = 0 or p_entity_type = 1 then

	dbms_output.put_line('Starting Creation of Display Units for UOMs');
	l_index := 0;
	while l_index < p_num_entities
	loop
	    l_ebs_entity_name := UOM_NAME || (p_start_no + l_index);
	    dbms_output.put_line('Creating Display Unit for UOM, ' || l_ebs_entity_name);
	    l_stmt_get_code := ' select display_units from ' || DEMANTRA_SCHEMA || '.display_units ' ||
	                       ' where display_units = ''' || l_ebs_entity_name || '''' ;
	    l_dem_entity_name := '';

	    dbms_output.put_line(l_stmt_get_code);
	    open get_code for l_stmt_get_code;
	    fetch get_code into l_dem_entity_name;
	    close get_code;

	    if l_dem_entity_name = l_ebs_entity_name then
	        dbms_output.put_line('Display Unit ' || l_ebs_entity_name || ' exists. Skipping....');
	    else

    		l_stmt := ' alter table ' || DEMANTRA_SCHEMA || '.t_ep_item ' ||
	                  ' add ( ' || l_ebs_entity_name || ' NUMBER default null) ';
	        dbms_output.put_line(l_stmt);

	        begin
	        	execute immediate l_stmt;
	        	exception
	        		when others then
	        			dbms_output.put_line('Display Unit ' || l_ebs_entity_name || ' failed in alter statement');
	        			dbms_output.put_line(substr(SQLERRM,1,250));
	        			goto continue;
	        end;

 	        l_stmt_display_unit_id := ' select max(display_units_id)+1 from ' || DEMANTRA_SCHEMA || '.display_units ';

	        dbms_output.put_line(l_stmt_display_unit_id);
	        open get_display_unit_id for l_stmt_display_unit_id;
	        fetch get_display_unit_id into l_display_unit_id;
	        close get_display_unit_id;
	        dbms_output.put_line(l_display_unit_id);

	        l_stmt := ' insert into ' || DEMANTRA_SCHEMA || '.display_units ' ||
	                  ' (DISPLAY_UNITS_ID, DISPLAY_UNITS, DATA_TABLE, DATA_FIELD, DATA_EXPRESSION) ' ||
	                  ' values (:1,:2,''t_ep_item'',:3,NULL) ';
	        dbms_output.put_line(l_stmt);
	        execute immediate l_stmt using l_display_unit_id, l_ebs_entity_name, l_ebs_entity_name;

	        dbms_output.put_line('Display Unit ' || l_ebs_entity_name || ' created');
<<continue>>
		null;
	    end if;
	    l_index := l_index + 1;
	end loop;
	commit;
	dbms_output.put_line('Completed Creation of Display Units for UOMs');

end if;

if p_entity_type = 0 or p_entity_type = 2 then

	dbms_output.put_line('Starting Creation of Indexes for Currency');
	l_index := 0;
	while l_index < p_num_entities
	loop
	    l_ebs_entity_name := CURRENCY_NAME || (p_start_no + l_index);

	    dbms_output.put_line('Creating Index for Currency, ' || l_ebs_entity_name);
	    l_stmt_get_code := ' select real_value from ' || DEMANTRA_SCHEMA || '.real_values ' ||
         	               ' where real_value = ''' || l_ebs_entity_name || '''' ;

	    l_dem_entity_name := '';

	    dbms_output.put_line(l_stmt_get_code);

	    open get_code for l_stmt_get_code;
	    fetch get_code into l_dem_entity_name;
	    close get_code;

	    if l_dem_entity_name = l_ebs_entity_name then
	        dbms_output.put_line('Index ' || l_ebs_entity_name || ' exists. Skipping....');
	    else

	    		begin
	    			l_stmt := ' create table ' || DEMANTRA_SCHEMA || '.' || l_ebs_entity_name ||
	        	          ' (INDEX_DATE DATE, INDEX_VALUE NUMBER(10,5)) ';
	        	dbms_output.put_line(l_stmt);
	        	execute immediate l_stmt;
	        	exception
	        		when others then
	        			dbms_output.put_line('Real Value ' || l_ebs_entity_name || ' failed in create statement');
	        			dbms_output.put_line(substr(SQLERRM,1,250));
        			goto continue1;
	       	end;

	        l_stmt := ' insert into ' || DEMANTRA_SCHEMA || '.real_values ' ||
	                  ' (REAL_VALUE_ID, REAL_VALUE, REAL_TABLE, CALCULATION_TYPE, IS_DEFAULT) ' ||
	                  ' values (' || DEMANTRA_SCHEMA || '.' || REAL_VALUES_SEQ || '.nextval,:1,:2,2,NULL) ';
	        dbms_output.put_line(l_stmt);
	        execute immediate l_stmt using l_ebs_entity_name, l_ebs_entity_name;


	        dbms_output.put_line('Index ' || l_ebs_entity_name || ' created');

<<continue1>>
	        null;
	    end if;
	    l_index := l_index + 1;
	end loop;
	commit;
	dbms_output.put_line('Completed Creation of Indexes for Currency');

end if;

if p_entity_type = 0 or p_entity_type = 3 then

    -- Bug#7199587    syenamar
    -- replacing code using hard coded english names with ids for demantra objects

    /*DM_COMPONENT := msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'DEMAND_MANAGEMENT');

	DM_COMPONENT := 'Demand Management';

	if DM_COMPONENT is null then
		dbms_output.put_line('Demand Management component is null');
		return;
	end if;

	l_stmt_get_component := 'select dcm_product_id from ' || DEMANTRA_SCHEMA || '.dcm_products where product_name = ''' || DM_COMPONENT || '''';
    dbms_output.put_line(l_stmt_get_component);

	open get_component for l_stmt_get_component;
	fetch get_component into l_component_id;
	close get_component;*/

	l_component_id := to_number(msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'DEMAND_MANAGEMENT'));
	dbms_output.put_line(l_component_id);

	l_stmt_user_id := 'select user_id from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS') || ' where dcm_product_id = ' || l_component_id;
	dbms_output.put_line(l_stmt_user_id);

	open get_user_id for l_stmt_user_id;
	fetch get_user_id into l_user_id;
	close get_user_id;
	dbms_output.put_line(l_user_id);

	l_stmt_query_id := 'select tq.id from ' ||
	       		    -- DEMANTRA_SCHEMA || '.transfer_list tl, ' || --> removing this as integration interface id is obtained from lookup
			        DEMANTRA_SCHEMA || '.transfer_query tq ' ||
			        'where tq.transfer_id = ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_DEMANTRA_OBJECT_ID', 'INTG_INF_EBS_PRICE_LIST');
	dbms_output.put_line(l_stmt_query_id);

	open get_query_id for l_stmt_query_id;
	fetch get_query_id into l_query_id;
	close get_query_id;
	dbms_output.put_line(l_query_id);
	-- syenamar

	dbms_output.put_line('Starting Creation of Display Units for Price Lists');
	l_index := 0;
	while l_index < p_num_entities
	loop
	    l_ebs_entity_name := PRICELIST_NAME || (p_start_no + l_index);
	    dbms_output.put_line('Creating Display Unit for Price List, ' || l_ebs_entity_name);
	    l_stmt_get_code := ' select display_units from ' || DEMANTRA_SCHEMA || '.display_units ' ||
	              ' where display_units = ''' || l_ebs_entity_name || '''' ;

	    l_dem_entity_name := '';

	    dbms_output.put_line(l_stmt_get_code);
	    open get_code for l_stmt_get_code;
	    fetch get_code into l_dem_entity_name;
	    close get_code;

	    if l_dem_entity_name = l_ebs_entity_name then
	        dbms_output.put_line('Display Unit ' || l_ebs_entity_name || ' exists. Skipping....');
	    else

	    		begin
	    		l_stmt := ' alter table ' || DEMANTRA_SCHEMA || '.sales_data ' ||
	        	          ' add (' || l_ebs_entity_name || ' NUMBER default null) ';
	        	dbms_output.put_line(l_stmt);
	        	execute immediate l_stmt;

	        	l_stmt := ' alter table ' || DEMANTRA_SCHEMA || '.' || INTG_TABLE ||
	                  ' add (' || l_ebs_entity_name || ' NUMBER default null) ';
	        	dbms_output.put_line(l_stmt);
	        	execute immediate l_stmt;

	        	exception
	        		when others then
	        			dbms_output.put_line('Display Unit for Price List ' || l_ebs_entity_name || ' failed in alter statement');
	        			dbms_output.put_line(substr(SQLERRM,1,250));
	        			goto continue2;
	        end;

	        l_stmt_display_unit_id := ' select max(display_units_id)+1 from ' || DEMANTRA_SCHEMA || '.display_units ';

		dbms_output.put_line(l_stmt_display_unit_id);
		open get_display_unit_id for l_stmt_display_unit_id;
		fetch get_display_unit_id into l_display_unit_id;
		close get_display_unit_id;
		dbms_output.put_line(l_display_unit_id);

		l_stmt := ' insert into ' || DEMANTRA_SCHEMA || '.display_units ' ||
		          ' (DISPLAY_UNITS_ID, DISPLAY_UNITS, DATA_TABLE, DATA_FIELD, DATA_EXPRESSION) ' ||
		          ' values (:1,:2,''sales_data'',:3,NULL) ';
		dbms_output.put_line(l_stmt);
		execute immediate l_stmt using l_display_unit_id, l_ebs_entity_name, l_ebs_entity_name;

	        l_stmt_series_id := 'select ' || DEMANTRA_SCHEMA || '.' || COMPUTED_FIELDS_SEQ || '.nextval from dual';

	        dbms_output.put_line(l_stmt_series_id);
	        open get_series_id for l_stmt_series_id;
	        fetch get_series_id into l_series_id;
	        close get_series_id;
	        dbms_output.put_line(l_series_id);

	        l_stmt_disp_order_id := ' select max(disp_order)+1 from ' || DEMANTRA_SCHEMA || '.computed_fields ';

		dbms_output.put_line(l_stmt_disp_order_id);
		open get_disp_order_id for l_stmt_disp_order_id;
		fetch get_disp_order_id into l_disp_order_id;
		close get_disp_order_id;
		dbms_output.put_line(l_disp_order_id);


	        l_stmt_comp := 'INSERT INTO ' || DEMANTRA_SCHEMA || '.COMPUTED_FIELDS("FORECAST_TYPE_ID",   "COMPUTED_NAME",   "EXP_TEMPLATE",   "DISP_COLOR",   "DISP_LSTYLE",   "DISP_LSYMBOL",   ' ||
                     ' "PRINT_COLOR",   "PRINT_LSTYLE",   "PRINT_LSYMBOL",   "DISP_ORDER",   "INFO_TYPE",   "TABLE_FORMAT",   ' ||
                     ' "DO_HAVING",   "COMPUTED_TITLE",   "FIELD_TYPE",   "SUM_FUNC",   "MODE_1",   "MODE_COLOR",   "SCALEBLE",   ' ||
                     ' "TIME_AVG",   "MODULE_TYPE",   "DEPENDANTS",   "EDITABLE",   "IS_PROPORTION",   "NULL_AS_ZERO",   "DBNAME",   ' ||
                     ' "IS_DDLB",   "IS_CHECK",   "SERIES_WIDTH",   "DROPDOWN_TABLE_NAME",   "WEB_FORMULA",   "IS_DEFAULT",   ' ||
                     ' "HINT_MESSAGE",   "COMPUTEDFIELD_EXPRESSION",   "CLIENT_EXP_DISP",   "HIST_PRED_TYPE",   "ITEMCHANGE",   ' ||
                     ' "LOCK_EXP",   "DATA_TABLE_NAME",   "COMP_DEPEND_ORDER",   "DEPEND_ON_EXP_SERVER",   "BACKGROUND_COLOR_EXP",   ' ||
                     ' "SYNCRO_FIELD",   "LOCK_EXP_DISP",   "BACKGROUND_EXP_DISP",   "WEB_LOCK_EXPRESSION",   "ATTRIBUTES_DEPENDENTS",   ' ||
                     ' "CALCULATION_METHOD",   "LOOP_NUMBER",   "MOVE_UPD_BET_FORE",   "MOVE_FROM_SALES_TO_FOR",   "LOOKUP_TYPE",   ' ||
                     ' "LOOKUP_TABLE",   "LOOKUP_DISPLAY_FIELD",   "LOOKUP_DATA_FIELD",   "LOOKUP_EXTRA_FROM",   "LOOKUP_EXTRA_WHERE",   ' ||
                     ' "COL_SERIES_WIDTH",   "IS_RANKING",   "PROP_CALC_SERIES",   "UNLINKED_LEVEL_ID",   "UPDATE_BY_SERIES_ID",   ' ||
                     ' "EXTRA_FROM",   "EXTRA_WHERE",   "BASE_LEVEL",   "COLOR_DEPENDANTS",   "LOCK_EXP_DEPENDANTS",   "EXPRESSION_TYPE",   ' ||
                     ' "INT_AGGR_FUNC",   "WAVG_BY_SERIES",   "AGGR_BY",   "SUMMARY_LINE_EXP",   "SUMMARY_LINE_EXP_DISP",   ' ||
                     ' "SUMMARY_LINE_DEPENDENTS",   "PRESERVATION_TYPE",   "FILTER_EXP",   "FILTER_EXP_DISP",   "FILTER_EXP_DEPENDANTS",   ' ||
                     ' "FILTER_EXP_COL_DEPENDANTS",   "IS_EDITABLE_SUMMARY",   "MOVE_PRESERVATION_TYPE",   "TABLE_ID",   "DATA_TYPE",   ' ||
                     ' "SAME_VAL_UPDATE") VALUES(' || l_series_id ||
                     ',   :1,   ''avg(branch_data.' || lower(l_ebs_entity_name) || ')'',   255,   1,   1,   255,   1,   1,   :2,   1,   NULL,   0,   :3,   ' ||
                     '  ''1'',   ''avg'',   NULL,   NULL,   0,   NULL,   0,   NULL,   0,   0,   0,   :4,   0,   0,   250,   NULL,   NULL,   0,   NULL, ' ||
                     ' NULL,   NULL,   3,   NULL,   NULL,   ''branch_data'',   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,' ||
                     ' NULL,   0,   NULL,   NULL,   NULL,   NULL,   NULL,   10,   NULL,   NULL,   NULL,   NULL,   NULL,   NULL,   0,   NULL,   NULL,   1,   ''Avg'',   ' ||
                     ' NULL,   0,   NULL,   NULL,   NULL,   3,   NULL,   NULL,   NULL,   NULL,   0,   3,   NULL,   1,   0)';

	        dbms_output.put_line('Inserting into computed_fields');
	        execute immediate l_stmt_comp using l_ebs_entity_name, l_disp_order_id, l_ebs_entity_name, lower(l_ebs_entity_name) ;


		l_stmt := 'insert into ' || DEMANTRA_SCHEMA || '.dcm_products_series' ||
							' (dcm_product_id ,series_id) ' ||
							' (select :1, :2 from dual)';

		execute immediate l_stmt using l_component_id, l_series_id;

		l_stmt := 'insert into ' || DEMANTRA_SCHEMA || '.user_security_series '  ||
							' (user_id, series_id ) ' ||
							' values (:1, :2)';

		dbms_output.put_line(l_stmt);

		execute immediate l_stmt using 	l_user_id, l_series_id;


		l_stmt := 'insert into ' || DEMANTRA_SCHEMA || '.transfer_query_series '
		          || '(id, series_id, load_option, purge_option)'
		          || ' values '
		          || ' (:1,:2,2,0)';

		dbms_output.put_line(l_stmt);
		execute immediate l_stmt using l_query_id, l_series_id;

	        dbms_output.put_line('Display Unit for Price List' || l_ebs_entity_name || ' created');

<<continue2>>
		null;
	    end if;
	    l_index := l_index + 1;
	end loop;
	commit;
	dbms_output.put_line('Completed Creation of Display Units for Price Lists');

end if;

exception
	when others then
	dbms_output.put_line(substr(SQLERRM,1,150));
 	retcode := 1;

 retcode := 0;

end;

end MSD_DEM_CREATE_DEM_SEED;


/
