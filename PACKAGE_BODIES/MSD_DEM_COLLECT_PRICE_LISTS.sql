--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_PRICE_LISTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_PRICE_LISTS" AS
/* $Header: msddemprlclb.pls 120.5.12010000.10 2009/11/27 08:51:47 sjagathe ship $ */

v_list varchar2(5000);

function get_lookup_value(p_lookup_type IN VARCHAR2,
													p_lookup_code IN VARCHAR2)
return VARCHAR2

as

cursor get_lookup_value is
select meaning
from fnd_lookup_values
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code
and language = 'US';

cursor get_schema_name is
select fnd_profile.value('MSD_DEM_SCHEMA')
from dual;

l_lookup_value varchar2(200);
l_schema_name varchar2(200);

begin

		open get_lookup_value;
		fetch get_lookup_value into l_lookup_value;
		close get_lookup_value;

		if p_lookup_type = 'MSD_DEM_TABLES' then

			open get_schema_name;
			fetch get_schema_name into l_schema_name;
			close get_schema_name;

			if l_schema_name is not null then
				l_lookup_value := l_schema_name || '.' || l_lookup_value;
			end if;

		end if;

		return l_lookup_value;

end;

procedure populate_prl(retcode      out nocopy number
											 ,p_prl_code  in  varchar2
                       ,p_instance_id   number
                       ,p_start_date    date
                       ,p_end_date      date)

as

cursor get_prl_metadata is
select table_name, column_name
from msd_dem_entities_inuse
where ebs_entity = 'PRL'
and demantra_entity = 'DISPLAY_UNIT'
and internal_name = p_prl_code;

type c_get_series_id is ref cursor;
get_series_id c_get_series_id;
l_stmt_get_series_id varchar2(2000);

l_stmt varchar2(7000);

l_series_id number;

l_table_name varchar2(100);
l_column_name varchar2(100);

begin

		open get_prl_metadata;
		fetch get_prl_metadata into l_table_name, l_column_name;

		if get_prl_metadata%notfound then
			close get_prl_metadata;
			msd_dem_common_utilities.log_message('Price List deleted. Please recreate the Price List');
			msd_dem_common_utilities.log_debug('Price List deleted. Please recreate the Price List');
			retcode := 1;
			return;
		end if;

		close get_prl_metadata;

		msd_dem_query_utilities.get_query(retcode, l_stmt, 'MSD_DEM_PRICE_LIST_INTO_DEMANTRA', p_instance_id);


		if fnd_profile.value('MSD_DEM_SCHEMA') is not null then
			l_stmt := replace(l_stmt, 'TABLENAME', fnd_profile.value('MSD_DEM_SCHEMA') || '.' || l_table_name);
			l_stmt := replace(l_stmt, 'SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));
		else
			l_stmt := replace(l_stmt, 'TABLENAME', l_table_name);
		end if;

		l_stmt := replace(l_stmt, 'COLUMNNAME', l_column_name);


		msd_dem_common_utilities.log_debug('Bind variables: ');
		msd_dem_common_utilities.log_debug('p_instance_id: ' || p_instance_id);
		msd_dem_common_utilities.log_debug('p_start_date: ' || p_start_date);
		msd_dem_common_utilities.log_debug('p_end_date: ' || p_end_date);
		msd_dem_common_utilities.log_debug('p_prl_code: ' || p_prl_code);

		msd_dem_common_utilities.log_debug('Executed Statement: ');
		msd_dem_common_utilities.log_debug(l_stmt);

		msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		execute immediate l_stmt using  p_start_date, p_end_date, p_prl_code ;
		msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

		l_stmt_get_series_id := 'select forecast_type_id from ' || get_lookup_value('MSD_DEM_TABLES', 'COMPUTED_FIELDS') ||
														' where computed_name = ''' || l_column_name || '''';

    open get_series_id for l_stmt_get_series_id;
    fetch get_series_id into l_series_id;
    if get_series_id%NOTFOUND then
    	retcode := 1;
    	goto continue;
    end if;
    close get_series_id;

    -- Bug#7199587    syenamar
    -- use integration interface id (for 'EBS Price List' integration interface) obtained from lookup
    /* Bug# 8224935 - APP ID */
    l_stmt := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_QUERY_SERIES')  || ' tqs set tqs.load_option = 0, tqs.purge_option = 0 '
				          || ' where tqs.id = (select tq.id from '
                                    || get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_QUERY')  || ' tq '
									|| ' where tq.transfer_id = ' || msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'INTG_INF_EBS_PRICE_LIST', 1, 'id')
                                    || ') and tqs.series_id = ' || l_series_id;

		msd_dem_common_utilities.log_debug(l_stmt);

		execute immediate l_stmt;
        -- syenamar

<<continue>>

		null;

		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := 1;

end;

procedure process_prl(retcode out nocopy number, p_prl_code in varchar2)

as

cursor verify_entities_inuse is
select 1 from
msd_dem_entities_inuse
where internal_name = p_prl_code
and ebs_entity = 'PRL';

type c_get_new_prl_display_unit is ref cursor;
get_new_prl_display_unit c_get_new_prl_display_unit;
l_stmt_new_prl_display_unit varchar2(2000);

type c_get_component is ref cursor;
get_component c_get_component;
l_stmt_get_component varchar2(2000);

type c_get_component_sop is ref cursor;
get_component_sop c_get_component_sop;
l_stmt_get_component_sop varchar2(2000);

type c_get_profile_table is ref cursor;
get_profile_table c_get_profile_table;
l_stmt_get_profile_table varchar2(2000);

type c_get_seeded_unit is ref cursor;
get_seeded_unit c_get_seeded_unit;
l_stmt_get_seeded_unit varchar2(2000);

l_get_seeded_unit varchar2(250);

l_profile_table_name varchar2(1000);

l_verify_entities_inuse number;

type new_prl_rectype is record(
display_units varchar2(500)
,display_units_id number
,data_table varchar2(500)
,data_field varchar2(500)
);

new_prl new_prl_rectype;

l_component_id number;
l_component_id_sop number;

l_stmt varchar2(2000);

begin

		l_stmt_get_seeded_unit := 'select display_units from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
		                                   ' where display_units = ''' || p_prl_code || '''';

		open get_seeded_unit for l_stmt_get_seeded_unit;
		fetch get_seeded_unit into l_get_seeded_unit;
		close get_seeded_unit;

		open verify_entities_inuse;
		fetch verify_entities_inuse into l_verify_entities_inuse;
		close verify_entities_inuse;

		if l_verify_entities_inuse is null then

		     if l_get_seeded_unit is not null then
		     			msd_dem_common_utilities.log_message('Seeded Display Unit with name ' || p_prl_code || ' exist in Demantra. This Price List will not created');
		     			msd_dem_common_utilities.log_debug('Seeded Display Unit with name ' || p_prl_code || ' exist in Demantra. This Price List will not created');
		     			retcode := 1;
		     			return;
		     end if;

                -- Bug#7199587    syenamar
                -- Use 'data_field' field to look for empty dummy pricelists, 'display_units' field may contain values in any supported language other than english
				l_stmt_new_prl_display_unit := 'select display_units ,display_units_id ,data_table ,data_field ' ||
                                                 ' from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' ' ||
                                                 ' where display_units_id in ' ||
                                                 '  (select distinct display_units_id from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
                                                 '   minus ' ||
                                                 '   select distinct display_units_id from ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') || ')' ||
                                                 ' and data_field in ' ||
                                                 '  (select data_field from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' where data_field like ''EBSPRICELIST%'' ' ||
                                                 '   minus ' ||
                                                 '   select column_name from msd_dem_entities_inuse  where ebs_entity = ''PRL'' )' ||
                                                 ' and rownum < 2';

				msd_dem_common_utilities.log_debug(l_stmt_new_prl_display_unit);
				-- syenamar

				open get_new_prl_display_unit for l_stmt_new_prl_display_unit;
				fetch get_new_prl_display_unit into new_prl;
				if get_new_prl_display_unit%notfound then
					msd_dem_common_utilities.log_message('Seeded Display Units for Price List not Available');
					msd_dem_common_utilities.log_debug('Seeded Display Units for Price List not Available');
					close get_new_prl_display_unit;
					retcode := 1;
					return;
				end if;
				close get_new_prl_display_unit;


                                /* Bug# 8224935 - APP ID */
				l_stmt_get_profile_table := 'select tq.table_name from '
                                             --|| get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_LIST')  || ' tl ' || ' ,'
                                             || get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_QUERY')  || ' tq '
                                             || ' where tq.transfer_id = ' || msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'INTG_INF_EBS_PRICE_LIST', 1, 'id');


				open get_profile_table for l_stmt_get_profile_table;
				fetch  get_profile_table into l_profile_table_name;
				close get_profile_table;



				l_stmt := 'insert into msd_dem_entities_inuse(
									 ebs_entity
                   ,demantra_entity
                   ,internal_name
                   ,table_name
                   ,column_name
                   ,last_update_date
	                 ,last_updated_by
	                 ,creation_date
	                 ,created_by
	                 ,last_update_login
                   ) values
                   (
                   ''PRL''
                   ,''DISPLAY_UNIT''
                   ,:1
                   ,:2
                   ,:3
                   ,:4
                   ,:5
                   ,:6
                   ,:7
                   ,:8
                   )';

        msd_dem_common_utilities.log_debug(l_stmt);


				execute immediate l_stmt using p_prl_code, l_profile_table_name, new_prl.data_field, sysdate, nvl(fnd_global.user_id,-1), sysdate, nvl(fnd_global.user_id,-1), fnd_global.user_id;

				l_stmt := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
									' set display_units = :1 ' ||
									' where display_units_id = :2';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using p_prl_code, new_prl.display_units_id;

                                -- syenamar
                                -- bug#8323116: avoid inserting records already present in avail_units else collection will fail
				l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'AVAIL_UNITS') ||
				          ' (group_table_id ,display_units_id )' ||
				          ' (select group_table_id, :1 ' ||
				          ' from ' || get_lookup_value('MSD_DEM_TABLES', 'GROUP_TABLES') ||
				          ' where group_type = 1 ' ||
                                          ' minus ' ||
                                          ' select group_table_id, display_units_id ' ||
                                          ' from ' || get_lookup_value('MSD_DEM_TABLES', 'AVAIL_UNITS') ||
                                          ' where display_units_id = :2 ' ||
				          ' )';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using new_prl.display_units_id, new_prl.display_units_id;
				-- syenamar

                /*l_stmt_get_component := 'select dcm_product_id from ' ||get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS') || ' where product_name = ''' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'DEMAND_MANAGEMENT') || '''';

				msd_dem_common_utilities.log_debug(l_stmt_get_component);

				open get_component for l_stmt_get_component;
				fetch get_component into l_component_id;
				close get_component;*/

                                /* Bug# 8224935 - APP ID */
                                l_component_id := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_DM', 1, 'dcm_product_id'));
				l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') ||
									' (dcm_product_id ,display_units_id) ' ||
									' (select :1, :2 from dual)';

				msd_dem_common_utilities.log_debug(l_stmt);
				execute immediate l_stmt using l_component_id,new_prl.display_units_id;

				l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'INDEXES_FOR_UNITS') ||
				          ' (display_units_id, real_value_id) ' ||
				          ' (select :1, real_value_id from ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_INDEX') || ' dpi ' ||
				          ' where dpi.dcm_product_id = ' || l_component_id ||
				          ')';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using new_prl.display_units_id;



				/*l_stmt_get_component_sop := 'select dcm_product_id from ' ||get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS') || ' where product_name = ''' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'SOP') || '''';

				msd_dem_common_utilities.log_debug(l_stmt_get_component_sop);

				open get_component_sop for l_stmt_get_component_sop;
				fetch get_component_sop into l_component_id_sop;
				close get_component_sop;*/

                                /* Bug# 8224935 - APP ID */
                                l_component_id_sop := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'COMP_SOP', 1, 'dcm_product_id'));
				l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') ||
									' (dcm_product_id ,display_units_id) ' ||
									' (select :1, :2 from dual)';

				msd_dem_common_utilities.log_debug(l_stmt);
				execute immediate l_stmt using l_component_id_sop,new_prl.display_units_id;
				--syenamar

				l_stmt := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'COMPUTED_FIELDS')
									|| ' set computed_title = :1 '
									|| ' where computed_name = :2 ';

				execute immediate l_stmt using substr(p_prl_code, 1 , 50), new_prl.data_field;


		/*else
				l_stmt := null;
				l_stmt := 'update msd_dem_entities_inuse set table_name = ''biio_ebs_price_list''' ||
				          ', column_name =  (select data_field from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' where display_units = :1)' ||
				          'where ebs_entity = ''PRL'' and demantra_entity = ''DISPLAY_UNIT'' and internal_name = :2';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using p_prl_code, p_prl_code; */

		end if;



		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := 1;

end;

procedure populate_demantra_prl_table(errbuf                 out nocopy varchar2,
																		  retcode                out nocopy number,
																			p_instance_id          in  number,
																			p_include_prl_list     in varchar2,
																			p_exclude_prl_list     in varchar2,
																			p_start_date           in     date,
																			p_end_date             in     date)

as

type c_prl_code is ref cursor;

get_prl_code c_prl_code;

l_stmt varchar2(500);
l_list2 varchar2(500);

l_prl_code varchar2(250);

was_retcode_1 number := 0;

begin

        /* Bug# 8224935 - APP ID */
    	l_stmt := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_QUERY_SERIES')  || ' tqs set tqs.load_option = 2, tqs.purge_option = 0 '
				          || ' where tqs.id = (select tq.id from '
                                    || get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_QUERY')  || ' tq '
									|| ' where tq.transfer_id = ' || msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'INTG_INF_EBS_PRICE_LIST', 1, 'id')
                                    || ')';

		msd_dem_common_utilities.log_debug(l_stmt);

		execute immediate l_stmt;-- using fnd_profile.value('MSD_DEM_PRICE_LIST_PROFILE');
		-- syenamar

		l_stmt := null;
		l_stmt := 'select distinct price_list_name price_list_name
							 from msd_dem_price_lists_gtt';


		/*l_list2 := null;

		if p_include_prl_list is not null then

			l_list2 := p_include_prl_list;

		end if;

		l_list2 := l_list2 || ',';*/

		l_list2 := v_list;
		l_list2 := replace(l_list2, '''', '');
		l_list2 := l_list2 || ',';

		if v_list is not null then

			l_stmt := 'select price_list_name from (' || l_stmt;
			l_stmt := l_stmt || ')' || 'where price_list_name ';

			if p_exclude_prl_list is not null then
				l_stmt := l_stmt || ' not ';
			end if;

			l_stmt := l_stmt || ' in ' || '(' || v_list || ')';

		end if;



		open get_prl_code for l_stmt;

		loop

		fetch get_prl_code into l_prl_code;
		exit when get_prl_code%notfound;

		msd_dem_common_utilities.log_message('Populating Price List: ' || l_prl_code);
		msd_dem_common_utilities.log_debug('Populating Price List: ' || l_prl_code);

		l_list2 := replace(l_list2, l_prl_code||',' , '');

		process_prl(retcode, l_prl_code);

		if retcode = -1 or retcode = 1 then
			msd_dem_common_utilities.log_message('Failed processing Price List: ' || l_prl_code);
			msd_dem_common_utilities.log_debug('Failed Processing Price List: ' || l_prl_code);
			was_retcode_1 := retcode;
			goto continue;
		end if;

		populate_prl(retcode, l_prl_code, p_instance_id, p_start_date, p_end_date);

		if retcode = -1 or retcode = 1 then
			was_retcode_1 := retcode;
		end if;

<<continue>>
		null;

		end loop;

		close get_prl_code;

		retcode := was_retcode_1;

		l_list2 := rtrim(l_list2, ',');

		if l_list2 is not null then
			retcode := 1;
			msd_dem_common_utilities.log_message('Following Price Lists dont exist in source: ' || l_list2);
			msd_dem_common_utilities.log_debug('Following Price Lists dont exist in source: ' || l_list2);
		end if;


		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := 1;

end;

procedure filter_from_list(errbuf        out nocopy varchar2,
											     retcode       out nocopy number,
											     p_instance_id in  number,
											     p_include_prl_list   in varchar2,
													 p_exclude_prl_list   in varchar2)
as

cursor count_price_lists is
select count(*)
from msd_dem_price_lists;

l_count_price_lists number;

cursor price_list_cur is
select price_list_name
from msd_dem_price_lists;

acc_list varchar2(5000);
unacc_list varchar2(5000);

begin

	open count_price_lists;
	fetch count_price_lists into l_count_price_lists;
	close count_price_lists;

	if l_count_price_lists = 0 then
			retcode := -1;
			return;
	end if;

	unacc_list := v_list || ',';
	acc_list := null;

	for price_list_cur_rec in price_list_cur loop

		if (instr(v_list, price_list_cur_rec.price_list_name) > 0 and p_include_prl_list is not null)  or v_list is null then

			acc_list := acc_list || '''' || price_list_cur_rec.price_list_name || ''',';
			unacc_list := replace(unacc_list,'''' || price_list_cur_rec.price_list_name || ''',','');

		elsif (instr(v_list, price_list_cur_rec.price_list_name) = 0 and p_exclude_prl_list is not null) then
			acc_list := acc_list || '''' || price_list_cur_rec.price_list_name || ''',';
			unacc_list := replace(unacc_list,'''' || price_list_cur_rec.price_list_name || ''',','');

		end if;
	end loop;

	if acc_list is not null then
		acc_list := rtrim(acc_list, ',');
	end if;

	unacc_list := rtrim(unacc_list, ',');
	unacc_list := replace(unacc_list, '''', '');

	if unacc_list is not null then
		msd_dem_common_utilities.log_message('The following price list names are not collected as they dont exist in the price list form or excluded by the user: ' || unacc_list);
		msd_dem_common_utilities.log_debug('The following price list names are not collected as they dont exist in the price list form or excluded by the user: ' || unacc_list);

		if acc_list is not null then
			retcode := 1;
		else
			retcode := 0 ;
		     	return;
		end if;
	end if;

	v_list := acc_list;

	if retcode <> -1 and retcode <> 1 then
		retcode := 0;
	end if;

	exception
		when others then
			msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
			msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
			retcode := -1;

end;

procedure collect_from_source(errbuf        out nocopy varchar2,
											        retcode       out nocopy number,
											        p_instance_id in  number,
											        p_include_prl_list   in varchar2,
															p_exclude_prl_list   in varchar2)

as

l_add_where_clause varchar2(5000);
l_stmt varchar2(6000);
l_key_values varchar2(4000);

l_retcode number;

begin

		v_list := null;
		if p_include_prl_list is not null then

			v_list := '''' || replace(p_include_prl_list, ',', ''',''') || '''';

		elsif p_exclude_prl_list is not null then

			v_list := '''' || replace(p_exclude_prl_list, ',', ''',''') || '''';

		end if;

		filter_from_list(errbuf, retcode, p_instance_id, p_include_prl_list, p_exclude_prl_list);


		if retcode = -1 then
			msd_dem_common_utilities.log_message('Price list collection cannot continue as no price lists are selected in the price list form');
			msd_dem_common_utilities.log_debug('Price list collection cannot continue as no price lists are selected in the price list form');
			retcode := -1;
			return;
		end if;

		if retcode = 0 then
			msd_dem_common_utilities.log_message('Include Price List does not contain any price list among the price lists, which are selected in the price list form.');
			msd_dem_common_utilities.log_debug('Include Price List does not contain any price list among the price lists, which are selected in the price list form.');
			retcode := 0;
			return;
		end if;

		l_add_where_clause := null;

		if v_list is not null then

			l_add_where_clause := 'AND qplh.name ';

			--if p_exclude_prl_list is not null then
			--	l_add_where_clause :=  l_add_where_clause || ' not ';
			--end if;

			l_add_where_clause := l_add_where_clause || ' in ' || '(' || v_list || ') ';

		end if;

		l_stmt := null;

		if l_add_where_clause is null then
				l_add_where_clause := ' and 1=1 ';
 		end if;

		/*msd_dem_query_utilities.get_query(retcode, l_stmt, 'MSD_DEM_PRICE_LIST_FROM_SOURCE', p_instance_id, null, l_add_where_clause );				*/

		l_key_values := '$C_INSTANCE#' || p_instance_id ||
										'$C_ADD_WHERE_CLAUSE#' || l_add_where_clause || '$';

	  msd_dem_query_utilities.get_query2 (
             			l_retcode,
             			l_stmt,
             			'MSD_DEM_PRL_FROM_SOURCE',
             			p_instance_id,
             			l_key_values,
             			0,
             			null);

		msd_dem_common_utilities.log_debug('Bind variables: ');
		msd_dem_common_utilities.log_debug('p_instance_id: ' || p_instance_id);
		msd_dem_common_utilities.log_debug('p_instance_id: ' || p_instance_id);

		msd_dem_common_utilities.log_debug('Executed Statement: ');
		msd_dem_common_utilities.log_debug(l_stmt);

		msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
		execute immediate l_stmt;
		msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := -1;

end;

procedure collect_price_lists(errbuf              out nocopy varchar2,
														  retcode             out nocopy number,
                              p_instance_id        in   number,
                              p_start_date  			 in varchar2,
                              p_end_date           in varchar2,
                              p_include_all        in   number,
                              p_include_prl_list   in varchar2,
                              p_exclude_prl_list   in varchar2)

as

retcode_store number;

/* Bug# 6459467 - Refresh the price list data profile */
   x_profile_id    NUMBER	  := NULL;
   x_stmt          VARCHAR2(4000) := NULL;

   /* CTO */
   x_schema		VARCHAR2(100)	:= NULL;
   x_price_list_col	VARCHAR2(30)	:= NULL;
   x_errbuf		VARCHAR2(200)	:= NULL;
   x_retcode		VARCHAR2(100)	:= NULL;
   x_num_rows		NUMBER		:= NULL;

  cursor c_get_instance_type is
  select instance_type
  from msc_apps_instances
  where instance_id = p_instance_id;

  l_instance_type number;

begin


-- bug#8367471 nallkuma
	open c_get_instance_type ;
	fetch c_get_instance_type into l_instance_type ;
	close c_get_instance_type ;

if l_instance_type in (1,2,4) then
	msd_dem_push_setup_parameters.push_setup_parameters(ERRBUF, RETCODE, p_instance_id, '-999');
	if retcode = -1 then
			msd_dem_common_utilities.log_message('Push Setup Parameters Failed');
			msd_dem_common_utilities.log_debug('Push Setup Parameters Failed');
			return;
	end if;
else
    /* Calling push_legacy_setup_parameters() procedure in case of pure legacy instance */
    msd_dem_push_setup_parameters.push_legacy_setup_parameters(ERRBUF, RETCODE, p_instance_id);
	if retcode = -1 then
			msd_dem_common_utilities.log_message('Push Legacy Setup Parameters Failed');
			msd_dem_common_utilities.log_debug('Push Legacy Setup Parameters Failed');
			return;
	end if;
end if;


		if p_include_all = 1 and (p_include_prl_list is not null or p_exclude_prl_list is not null) then
			msd_dem_common_utilities.log_message('Cannot specify both collect all and include or exclude list');
			msd_dem_common_utilities.log_debug('Cannot specify both collect all and include or exclude list');
			retcode := -1;
			return;
		end if;

		if p_include_all = 2 and p_include_prl_list is null and p_exclude_prl_list is null then

			msd_dem_common_utilities.log_message('Exactly one of the parameters Include Price Lists or Exclude Price Lists must be specified, when Collect All Price Lists is No');
			msd_dem_common_utilities.log_debug('Exactly one of the parameters Include Price Lists or Exclude Price Lists must be specified, when Collect All Price Lists is No');
			retcode := -1;
			return;

		end if;

		if p_include_all = 2 and p_include_prl_list is not null and p_exclude_prl_list is not null then

			msd_dem_common_utilities.log_message('Should not specify both include and exclude list');
			msd_dem_common_utilities.log_debug('Should not specify both include and exclude list');
			retcode := -1;
			return;

		end if;

		if nvl(fnd_date.canonical_to_date(p_start_date), to_date('01-01-1900', 'DD-MM-YYYY')) > nvl(fnd_date.canonical_to_date(p_end_date), to_date('01-01-4000', 'DD-MM-YYYY')) then
			msd_dem_common_utilities.log_message('From Date should not be greater than To Date');
			msd_dem_common_utilities.log_debug('From Date should not be greater than To Date');
			retcode := -1;
			return;
		end if;

		msd_dem_common_utilities.log_message('Collecting Price Lists');
		msd_dem_common_utilities.log_debug('Collecting Price Lists');

		msd_dem_common_utilities.log_message('Collecting Price Lists from source');
		msd_dem_common_utilities.log_debug('Collecting Price Lists from source');
		collect_from_source(errbuf, retcode, p_instance_id, p_include_prl_list, p_exclude_prl_list);

		if retcode = -1 then
				return;
		end if;

		retcode_store := retcode;

		msd_dem_common_utilities.log_message('Populating Price Lists in Demand Planning components');
		msd_dem_common_utilities.log_debug('Populating Price Lists in Demand Planning components');
		populate_demantra_prl_table(errbuf, retcode, p_instance_id, p_include_prl_list, p_exclude_prl_list, nvl(fnd_date.canonical_to_date(p_start_date),
		                            to_date('01-01-1900', 'DD-MM-YYYY')), nvl(fnd_date.canonical_to_date(p_end_date), to_date('01-01-4000', 'DD-MM-YYYY')));

                commit;


                /* Bug# 6459467 - Refresh the price list data profile */
                BEGIN

                   /* Bug# 8224935 - APP ID */
                   x_stmt:=  'SELECT tq.id FROM '
                                || get_lookup_value('MSD_DEM_TABLES', 'TRANSFER_QUERY')  || ' tq '
								|| ' WHERE tq.transfer_id = ' || msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'INTG_INF_EBS_PRICE_LIST', 1, 'id');

		   msd_dem_common_utilities.log_debug ('Get data profile id stmt : ' || x_stmt);
		   EXECUTE IMMEDIATE x_stmt INTO x_profile_id;
           -- syenamar

		   x_stmt := 'BEGIN '
		                     || fnd_profile.value('MSD_DEM_SCHEMA') || '.'
		                     || 'API_NOTIFY_APS_INTEGRATION('
		                     || x_profile_id
		                     ||'); end;';

		   msd_dem_common_utilities.log_debug ('Refresh data profile stmt : ' || x_stmt);
		   EXECUTE IMMEDIATE x_stmt;

		EXCEPTION
		   WHEN OTHERS THEN
		      msd_dem_common_utilities.log_message('WARNING: Failed to update the price list data profile');
		END;

		commit;

		if retcode <> -1 and retcode <> 1 then
			retcode := 0;
		end if;

		if retcode = 0 then
			retcode := retcode_store;
		end if;

<<final>>

		null;

		IF (nvl(retcode, 0) = -1)
		THEN
		   RETURN;
		END IF;

		/* CTO - One of the EBS Price List should also be loaded into CTO Data */
		IF (fnd_profile.value('MSD_DEM_INCLUDE_DEPENDENT_DEMAND') = 1)
		THEN

		   msd_dem_common_utilities.log_debug('Begin - CTO Price');

		   /* Get the price list column that should be used to copy from MSD_DEM_PRICE_LIST */

		   x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
		   IF (x_schema IS NULL)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Unable to get Demantra schema name ');
		      retcode := -1;
		      RETURN;
		   END IF;

		   /* Bug# 8224935 - APP ID */
		   x_stmt := 'SELECT dbname FROM ' || x_schema || '.computed_fields '
		             || ' WHERE ' || msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'SERIES_UNIT_PRICE', 2, null);
		   msd_dem_common_utilities.log_debug (x_stmt);

		   EXECUTE IMMEDIATE x_stmt INTO x_price_list_col;

		   IF (x_price_list_col IS NULL)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Price List Column name is null ');
		      retcode := -1;
		      RETURN;
		   END IF;

		   msd_dem_common_utilities.log_debug('Truncate staging table for cto price - BIIO_CTO_OPTION_PRICE ');
		   msd_dem_query_utilities.truncate_table (
		   				x_errbuf,
		   				x_retcode,
		   				'BIIO_CTO_OPTION_PRICE',
		   				1,
		   				1);
		   IF (x_retcode = -1)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Failed to truncate  BIIO_CTO_OPTION_PRICE');
		      retcode := -1;
		      errbuf := x_errbuf;
		      RETURN;
		   END IF;

		   msd_dem_common_utilities.log_debug('Truncate staging table for cto price - BIIO_CTO_OPTION_PRICE_ERR ');
		   msd_dem_query_utilities.truncate_table (
		   				x_errbuf,
		   				x_retcode,
		   				'BIIO_CTO_OPTION_PRICE_ERR',
		   				1,
		   				1);
		   IF (x_retcode = -1)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Failed to truncate  BIIO_CTO_OPTION_PRICE_ERR');
		      retcode := -1;
		      errbuf := x_errbuf;
		      RETURN;
		   END IF;

		   /* Build insert statement for biio_cto_option_price */
		   x_stmt := 'INSERT /*+ APPEND NOLOGGING */ INTO ' || x_schema || '.BIIO_CTO_OPTION_PRICE '
		             || ' ( SDATE, LEVEL1, OPTION_PRICE ) '
		             || ' SELECT '
		             || '    SDATE, '
		             || '    LEVEL1, '
		             || x_price_list_col || ' '
		             || ' FROM ' || x_schema || '.MSD_DEM_PRICE_LIST '
		             || ' WHERE ' || x_price_list_col || ' IS NOT NULL ';

		   msd_dem_common_utilities.log_debug (x_stmt);
		   msd_dem_common_utilities.log_debug ('Query start time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
		   EXECUTE IMMEDIATE x_stmt;
		   x_num_rows := SQL%ROWCOUNT;
		   COMMIT;
		   msd_dem_common_utilities.log_debug ('Query end time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
		   msd_dem_common_utilities.log_debug ('Number of rows inserted - ' || to_char(x_num_rows));

		   msd_dem_common_utilities.log_debug('End - CTO Price');

		ELSE
		   msd_dem_common_utilities.log_debug ('msd_dem_collect_price_lists.collect_price_lists - INFO - '
		                                       || 'Include Dependent Demand is set to No. Hence no action taken for CTO Price');
		END IF;


		/* Populate Scenario Price Staging Table if present */

		x_num_rows := NULL;
		x_price_list_col := NULL;
		x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
		IF (x_schema IS NULL)
		THEN
		   msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR(2) - '
		                                         || ' Unable to get Demantra schema name ');
		   retcode := -1;
		   RETURN;
		END IF;

		x_stmt := 'SELECT count(1) FROM dba_objects WHERE owner = upper(''' || x_schema || ''') AND object_type = ''TABLE'' '
		          || ' AND object_name IN (''BIIO_SCENARIO_PRICE'', ''BIIO_SCENARIO_PRICE_ERR'') ';
		msd_dem_common_utilities.log_debug (x_stmt);
		EXECUTE IMMEDIATE x_stmt INTO x_num_rows;

		IF (x_num_rows = 2)
		THEN

		   msd_dem_common_utilities.log_debug('Begin - Scenario Price');

		   /* Get the price list column that should be used to copy from MSD_DEM_PRICE_LIST */
		   x_stmt := 'SELECT dbname FROM ' || x_schema || '.computed_fields '
		             || ' WHERE ' || msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID', 'SERIES_UNIT_PRICE', 2, null);
		   msd_dem_common_utilities.log_debug (x_stmt);

		   EXECUTE IMMEDIATE x_stmt INTO x_price_list_col;

		   IF (x_price_list_col IS NULL)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Price List Column name is null ');
		      retcode := -1;
		      RETURN;
		   END IF;

		   msd_dem_common_utilities.log_debug('Truncate staging table for cto price - BIIO_SCENARIO_PRICE ');
		   msd_dem_query_utilities.truncate_table (
		   				x_errbuf,
		   				x_retcode,
		   				'BIIO_SCENARIO_PRICE',
		   				1,
		   				1);
		   IF (x_retcode = -1)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Failed to truncate  BIIO_SCENARIO_PRICE');
		      retcode := -1;
		      errbuf := x_errbuf;
		      RETURN;
		   END IF;

		   msd_dem_common_utilities.log_debug('Truncate staging table for cto price - BIIO_SCENARIO_PRICE_ERR ');
		   msd_dem_query_utilities.truncate_table (
		   				x_errbuf,
		   				x_retcode,
		   				'BIIO_SCENARIO_PRICE_ERR',
		   				1,
		   				1);
		   IF (x_retcode = -1)
		   THEN
		      msd_dem_common_utilities.log_message ('msd_dem_collect_price_lists.collect_price_lists - ERROR - '
		                                            || ' Failed to truncate  BIIO_SCENARIO_PRICE_ERR');
		      retcode := -1;
		      errbuf := x_errbuf;
		      RETURN;
		   END IF;

		   /* Build insert statement for biio_scenario_price */
		   x_stmt := 'INSERT /*+ APPEND NOLOGGING */ INTO ' || x_schema || '.BIIO_SCENARIO_PRICE '
		             || ' ( SDATE, LEVEL1, SCENARIO_PRICE ) '
		             || ' SELECT '
		             || '    SDATE, '
		             || '    LEVEL1, '
		             || x_price_list_col || ' '
		             || ' FROM ' || x_schema || '.MSD_DEM_PRICE_LIST '
		             || ' WHERE ' || x_price_list_col || ' IS NOT NULL ';

		   msd_dem_common_utilities.log_debug (x_stmt);
		   msd_dem_common_utilities.log_debug ('Query start time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
		   EXECUTE IMMEDIATE x_stmt;
		   x_num_rows := SQL%ROWCOUNT;
		   COMMIT;
		   msd_dem_common_utilities.log_debug ('Query end time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
		   msd_dem_common_utilities.log_debug ('Number of rows inserted - ' || to_char(x_num_rows));

		   msd_dem_common_utilities.log_debug('End - Scenario Price');

		ELSE
		   msd_dem_common_utilities.log_debug ('msd_dem_collect_price_lists.collect_price_lists - INFO - '
		                                       || 'Staging tables for Scenario Price not found. Hence no action taken for Scenario Price');

		END IF;


		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := -1;

end;

procedure delete_price_lists(errbuf              out nocopy varchar2,
														 retcode             out nocopy number,
														 p_list              in  varchar2)
as

cursor entities_inuse_cur(p_price_list_name varchar2) is
select internal_name, column_name
from msd_dem_entities_inuse
where internal_name = p_price_list_name
and ebs_entity = 'PRL';

l_internal_name varchar2(240);
l_column_name   varchar2(240);

l_list varchar2(2000);

type c_get_prl_display_unit_id is ref cursor;
get_prl_display_unit_id c_get_prl_display_unit_id;
l_stmt_prl_display_unit_id varchar2(2000);

l_display_unit_id number;

l_stmt_deletes varchar2(1000);

l_stmt_updates varchar2(1000);

next_str_pos number;

cur_str varchar2(300);

begin

		if p_list is null then
			return;
		end if;

		/*l_list := p_list || ',';*/

		msd_dem_common_utilities.log_message('Deleting Price Lists');
		msd_dem_common_utilities.log_debug('Deleting Price Lists');

		l_list := p_list;

		while length(l_list) > 0 loop
			next_str_pos := instr(l_list, ',');
			cur_str := substr(l_list, 1, next_str_pos-1);
			l_list := replace(l_list, cur_str || ',');

			l_internal_name := null;

			open entities_inuse_cur(cur_str);
			fetch entities_inuse_cur into l_internal_name,l_column_name;
			close entities_inuse_cur;

			if l_internal_name is null then
				msd_dem_common_utilities.log_message('Price List ' || cur_str || ' does not exist in Demantra');
				msd_dem_common_utilities.log_debug('Price List ' || cur_str || ' does not exist in Demantra');
				goto continue;
			end if;

			begin

					l_stmt_prl_display_unit_id := 'select display_units_id ' ||
																				' from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
																				' where display_units = ''' || l_internal_name || '''';

					msd_dem_common_utilities.log_message(l_stmt_prl_display_unit_id);
					msd_dem_common_utilities.log_debug(l_stmt_prl_display_unit_id);

					open get_prl_display_unit_id for l_stmt_prl_display_unit_id;
					fetch get_prl_display_unit_id into l_display_unit_id;
					close get_prl_display_unit_id;

					l_stmt_deletes := 'delete from ' || get_lookup_value('MSD_DEM_TABLES', 'AVAIL_UNITS') ||
														' where display_units_id = :1';

					msd_dem_common_utilities.log_message(l_stmt_deletes);
					msd_dem_common_utilities.log_debug(l_stmt_deletes);

					execute immediate l_stmt_deletes using l_display_unit_id;

					l_stmt_deletes := 'delete from ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') ||
														' where display_units_id = :1';

					msd_dem_common_utilities.log_message(l_stmt_deletes);
					msd_dem_common_utilities.log_debug(l_stmt_deletes);

					execute immediate l_stmt_deletes using l_display_unit_id;

					l_stmt_deletes := 'delete from ' || get_lookup_value('MSD_DEM_TABLES', 'INDEXES_FOR_UNITS') ||
														' where display_units_id = :1';

					msd_dem_common_utilities.log_message(l_stmt_deletes);
					msd_dem_common_utilities.log_debug(l_stmt_deletes);

					execute immediate l_stmt_deletes using l_display_unit_id;

					l_stmt_updates := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
														' set display_units = :1 where display_units_id = :2';

					msd_dem_common_utilities.log_message(l_stmt_updates);
					msd_dem_common_utilities.log_debug(l_stmt_updates);

					execute immediate l_stmt_updates using l_column_name, l_display_unit_id;

					l_stmt_updates := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'COMPUTED_FIELDS') ||
														' set computed_title = :1 ' ||
														' where computed_name = :2 ';

					msd_dem_common_utilities.log_message(l_stmt_updates);
					msd_dem_common_utilities.log_debug(l_stmt_updates);

					execute immediate l_stmt_updates using l_column_name, l_column_name;

					l_stmt_deletes := 'delete from msd_dem_entities_inuse' ||
														' where internal_name = :1 and ebs_entity = ''PRL''';

					msd_dem_common_utilities.log_message(l_stmt_deletes);
					msd_dem_common_utilities.log_debug(l_stmt_deletes);

					execute immediate l_stmt_deletes using l_internal_name;

					l_stmt_updates := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'SALES_DATA') ||
														' set ' || l_column_name || ' = null';

					msd_dem_common_utilities.log_message(l_stmt_updates);
					msd_dem_common_utilities.log_debug(l_stmt_updates);

					execute immediate l_stmt_updates;

					commit;

					msd_dem_common_utilities.log_message('Deleted price list ' || l_internal_name);
					msd_dem_common_utilities.log_debug('Deleted price list ' || l_internal_name);

					exception
						when others then
							msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
							msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
							msd_dem_common_utilities.log_message('Failed deleting price list ' || l_internal_name);
							msd_dem_common_utilities.log_debug('Failed deleting price list ' || l_internal_name);
							retcode := 1;

			end;

<<continue>>
			null;

		end loop;

		retcode := 0;

		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := -1;

end;

END MSD_DEM_COLLECT_PRICE_LISTS;


/
