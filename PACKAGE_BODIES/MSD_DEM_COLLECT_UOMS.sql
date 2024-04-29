--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_UOMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_UOMS" AS
/* $Header: msddemuomclb.pls 120.3.12010000.6 2009/04/03 13:28:55 nallkuma ship $ */

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

function msd_dem_uom_conversion (from_unit         varchar2,
                                 to_unit           varchar2,
                                 item_id           number) return number is

uom_rate number;

from_class              varchar2(10);
to_class                varchar2(10);

CURSOR standard_conversions IS
SELECT t.conversion_rate std_to_rate,
  t.to_uom_class std_to_class,
  f.conversion_rate std_from_rate,
  f.from_uom_class std_from_class
FROM msd_dem_uom_conversions_gtt t,
  msd_dem_uom_conversions_gtt f
WHERE t.sr_item_pk in (item_id, 0)
 AND t.to_uom_code = to_unit
 AND t.to_uom_class = t.from_uom_class
 AND f.sr_item_pk in (item_id, 0)
 AND f.to_uom_code = from_unit
 AND f.to_uom_class = f.from_uom_class
ORDER BY t.sr_item_pk DESC,
  f.sr_item_pk DESC;


std_rec standard_conversions%rowtype;


CURSOR interclass_conversions(p_from_class VARCHAR2, p_to_class VARCHAR2) IS
select decode(from_uom_class, p_from_class, 1, 2) from_flag,
       decode(to_uom_class, p_to_class, 1, 2) to_flag,
       conversion_rate rate
from   msd_dem_uom_conversions_gtt
where  sr_item_pk = item_id and
       ( (from_uom_class = p_from_class and to_uom_class = p_to_class) or
         (from_uom_class = p_to_class   and to_uom_class = p_from_class) );

class_rec interclass_conversions%rowtype;

invalid_conversion      exception;

type conv_tab is table of number index by binary_integer;
type class_tab is table of varchar2(10) index by binary_integer;

interclass_rate_tab     conv_tab;
from_class_flag_tab     conv_tab;
to_class_flag_tab       conv_tab;
from_rate_tab           conv_tab;
to_rate_tab             conv_tab;
from_class_tab          class_tab;
to_class_tab            class_tab;

std_index               number;
class_index             number;

from_rate               number := 1;
to_rate                 number := 1;
interclass_rate         number := 1;
to_class_rate           number := 1;
from_class_rate         number := 1;
msgbuf                  varchar2(500);

begin

    /*
    ** Conversion between between two UOMS.
    **
    ** 1. The conversion always starts from the conversion defined, if exists,
    **    for an specified item.
    ** 2. If the conversion id not defined for that specific item, then the
    **    standard conversion, which is defined for all items, is used.
    ** 3. When the conversion involves two different classes, then
    **    interclass conversion is activated.
    */

    /* If from and to units are the same, conversion rate is 1.
       Go immediately to the end of the procedure to exit.*/

    if (from_unit = to_unit) then
      uom_rate := 1;
  goto  procedure_end;
    end if;


    /* Get item specific or standard conversions */
    open standard_conversions;
    std_index := 0;
    loop

        std_index := std_index + 1;

        fetch standard_conversions into std_rec;
        exit when standard_conversions%notfound;

        from_rate_tab(std_index) := std_rec.std_from_rate;
        from_class_tab(std_index) := std_rec.std_from_class;
        to_rate_tab(std_index) := std_rec.std_to_rate;
        to_class_tab(std_index) := std_rec.std_to_class;

    end loop;

    close standard_conversions;

    if (std_index = 0) then    /* No conversions defined  */
       msgbuf := msgbuf||'Invalid standard conversion : ';
       msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
       msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
       raise invalid_conversion;

    else
        /* Conversions are ordered.
           Item specific conversions will be returned first. */

        from_class := from_class_tab(1);
        to_class := to_class_tab(1);
        from_rate := from_rate_tab(1);
        to_rate := to_rate_tab(1);

    end if;


    /* Load interclass conversion tables */
    if (from_class <> to_class) then
        class_index := 0;
        open interclass_conversions (from_class, to_class);
        loop

            fetch interclass_conversions into class_rec;
            exit when interclass_conversions%notfound;

            class_index := class_index + 1;

            to_class_flag_tab(class_index) := class_rec.to_flag;
            from_class_flag_tab(class_index) := class_rec.from_flag;
            interclass_rate_tab(class_index) := class_rec.rate;

        end loop;
        close interclass_conversions;

        /* No interclass conversion is defined */
        if (class_index = 0 ) then
            msgbuf := msgbuf||'Invalid Interclass conversion : ';
            msgbuf := msgbuf||'From UOM code: '||from_unit||' ';
            msgbuf := msgbuf||'To UOM code: '||to_unit||' ';
            raise invalid_conversion;
        else
            if ( to_class_flag_tab(1) = 1 and from_class_flag_tab(1) = 1 ) then
               to_class_rate := interclass_rate_tab(1);
               from_class_rate := 1;
            else
               from_class_rate := interclass_rate_tab(1);
               to_class_rate := 1;
            end if;
            interclass_rate := from_class_rate/to_class_rate;
        end if;
    end if;  /* End of from_class <> to_class */

    /*
    ** conversion rates are defaulted to '1' at the start of the procedure
    ** so seperate calculations are not required for standard/interclass
    ** conversions
    */

    if (to_rate <> 0 ) then
       uom_rate := (from_rate * interclass_rate) / to_rate;
    else
       uom_rate := null;
    end if;


    /* Put a label and a null statement over here so that you can
       the goto statements can branch here */
<<procedure_end>>

    return uom_rate;

exception

    when others then
         uom_rate := null;
         return uom_rate;

END msd_dem_uom_conversion;

procedure populate_uom(retcode      out nocopy number
											 ,p_uom_code  in  varchar2
                       ,p_instance_id   number)

as

cursor get_uom_metadata is
select table_name, column_name
from msd_dem_entities_inuse
where ebs_entity = 'UOM'
and demantra_entity = 'DISPLAY_UNIT'
and internal_name = p_uom_code;

l_stmt varchar2(4000);

l_table_name varchar2(100);
l_column_name varchar2(100);

begin

		open get_uom_metadata;
		fetch get_uom_metadata into l_table_name, l_column_name;

		if get_uom_metadata%notfound then
			close get_uom_metadata;
			msd_dem_common_utilities.log_message('UOM deleted. Please recreate the UOM');
			msd_dem_common_utilities.log_debug('UOM deleted. Please recreate the UOM');
			retcode := 1;
			return;
		end if;

		close get_uom_metadata;

		if fnd_profile.value('MSD_DEM_SCHEMA') is not null then
			l_stmt := 'update ' || fnd_profile.value('MSD_DEM_SCHEMA') || '.' || l_table_name || ' tei ';
		else
			l_stmt := 'update ' || l_table_name || ' tei ';
		end if;

		l_stmt := l_stmt || ' set ' || l_column_name  || ' = ( ' ||
								' select msd_dem_collect_uoms.msd_dem_uom_conversion(msc.uom_code, ''' || p_uom_code || ''', msc.sr_inventory_item_id)' ||
								' from  msc_system_items msc' ||
								' where plan_id = -1 ' ||
								' and sr_instance_id = :1 ' ||
								' and tei.ebs_item_dest_key = msc.inventory_item_id ' ||
								' and rownum < 2 ' ||
								')';


		msd_dem_common_utilities.log_debug('p_instance_id ' || p_instance_id);
		msd_dem_common_utilities.log_debug(l_stmt);

		msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
		execute immediate l_stmt using p_instance_id;
		msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := 1;

end;


procedure process_uom(retcode out nocopy number, p_uom_code in varchar2)

as

cursor verify_entities_inuse is
select 1 from
msd_dem_entities_inuse
where internal_name = p_uom_code
and ebs_entity = 'UOM';

type c_get_new_uom_display_unit is ref cursor;
get_new_uom_display_unit c_get_new_uom_display_unit;
l_stmt_new_uom_display_unit varchar2(2000);


type new_uom_rectype is record(
display_units varchar2(500)
,display_units_id number
,data_table varchar2(500)
,data_field varchar2(500)
);

new_uom new_uom_rectype;

type c_get_component is ref cursor;
get_component c_get_component;
l_stmt_get_component varchar2(2000);

type c_get_component_sop is ref cursor;
get_component_sop c_get_component_sop;
l_stmt_get_component_sop varchar2(2000);

l_verify_entities_inuse number;

l_component_id number;
l_component_id_sop number;

l_stmt varchar2(2000);

begin

		open verify_entities_inuse;
		fetch verify_entities_inuse into l_verify_entities_inuse;
		close verify_entities_inuse;

		if l_verify_entities_inuse is null then

                -- Bug#7199587    syenamar
                -- Use 'data_field' field to look for empty dummy UOMs, 'display_units' field may contain values in any supported language other than english
				l_stmt_new_uom_display_unit := 'select display_units ,display_units_id ,data_table ,data_field ' ||
																			 ' from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
																			 ' where display_units_id in ' ||
																			 '  (select distinct display_units_id from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' ' ||
			 																 '   minus ' ||
			 																 '   select distinct display_units_id from ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') || ' ' || ')' ||
                                       ' and data_field in ' ||
                                       '  (select data_field from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' where data_field like ''EBSUOM%'' ' ||
			 																 '   minus ' ||
			 																 '   select column_name from msd_dem_entities_inuse where ebs_entity = ''UOM'' )' ||
																			 ' and rownum < 2';

				msd_dem_common_utilities.log_debug(l_stmt_new_uom_display_unit);
                -- syenamar

				open get_new_uom_display_unit for l_stmt_new_uom_display_unit;
				fetch get_new_uom_display_unit into new_uom;
				if get_new_uom_display_unit%notfound then
					msd_dem_common_utilities.log_message('Seeded Display Units not Available');
					msd_dem_common_utilities.log_debug('Seeded Display Units not Available');
					close get_new_uom_display_unit;
					retcode := 1;
					return;
				end if;
				close get_new_uom_display_unit;


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
                   ''UOM''
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

				execute immediate l_stmt using p_uom_code, new_uom.data_table, new_uom.data_field, sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, fnd_global.user_id;

				l_stmt := 'update ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') ||
									' set display_units = :1 ' ||
									' where display_units_id = :2';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using p_uom_code, new_uom.display_units_id;

				l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'AVAIL_UNITS') ||
									' (group_table_id ,display_units_id) ' ||
									' ( ' ||
									' select group_table_id, :1 ' ||
									' from ' || get_lookup_value('MSD_DEM_TABLES', 'GROUP_TABLES') ||
								  ' where group_type = 1 ' ||
									' minus ' ||
									' select group_table_id, display_units_id ' ||
									' from ' || get_lookup_value('MSD_DEM_TABLES', 'AVAIL_UNITS') ||
									' where  display_units_id  = :2 ' ||
									' )';

				msd_dem_common_utilities.log_debug(l_stmt);
				execute immediate l_stmt using new_uom.display_units_id, new_uom.display_units_id;

                -- Bug#7199587    syenamar
                -- Use component id obtained from lookup

                /*l_stmt_get_component := 'select dcm_product_id from ' ||get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS') || ' where product_name = ''' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'DEMAND_MANAGEMENT') || '''';

				msd_dem_common_utilities.log_debug(l_stmt_get_component);

				open get_component for l_stmt_get_component;
				fetch get_component into l_component_id;
				close get_component;*/

        /* Bug#8224935 - APP ID */ -- nallkuma
          l_component_id := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                               'COMP_DM',
                                                                               1,
                                                                               'dcm_product_id'));
					l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') ||
									' (dcm_product_id ,display_units_id) ' ||
									' (select :1, :2 from dual)';
				msd_dem_common_utilities.log_debug(l_stmt);
				execute immediate l_stmt using l_component_id,new_uom.display_units_id;


				/*l_stmt_get_component_sop := 'select dcm_product_id from ' ||get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS') || ' where product_name = ''' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'SOP') || '''';

				msd_dem_common_utilities.log_debug(l_stmt_get_component_sop);

				open get_component_sop for l_stmt_get_component_sop;
				fetch get_component_sop into l_component_id_sop;
				close get_component_sop;*/

				/* Bug#8224935 - APP ID */ -- nallkuma
        l_component_id_sop := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                  'COMP_SOP',
                                                                                  1,
                                                                                  'dcm_product_id'));
				l_stmt := 'insert into ' || get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_UNITS') ||
									' (dcm_product_id ,display_units_id) ' ||
									' (select :1, :2 from dual)';
				msd_dem_common_utilities.log_debug(l_stmt);
				execute immediate l_stmt using l_component_id_sop,new_uom.display_units_id;
                -- syenamar

		else
				l_stmt := null;
				l_stmt := 'update msd_dem_entities_inuse set table_name = (select data_table from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' where display_units = :1)' ||
				          ', column_name =  (select data_field from ' || get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' where display_units = :2)' ||
				          'where ebs_entity = ''UOM'' and demantra_entity = ''DISPLAY_UNIT'' and internal_name = :3';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using p_uom_code, p_uom_code, p_uom_code;

		end if;

		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := 1;

end;

procedure populate_demantra_uom_table(errbuf                 out nocopy varchar2,
																		  retcode                out nocopy number,
																			p_instance_id          in  number,
																			p_include_uom_list     in varchar2,
																			p_exclude_uom_list     in varchar2)

as

type c_uom_code is ref cursor;

get_uom_code c_uom_code;

l_stmt varchar2(500);
l_list varchar2(500);
l_list2 varchar2(500);

l_uom_code varchar2(30);

begin


		l_stmt := null;
		l_stmt := 'select distinct from_uom_code uom_code
							 from msd_dem_uom_conversions_gtt
							 union
							 select distinct to_uom_code uom_code
							 from msd_dem_uom_conversions_gtt';

		l_list := null;
		l_list2 := null;

		if p_include_uom_list is not null then

			l_list := '''' || replace(p_include_uom_list, ',', ''',''') || '''';
			l_list2 := p_include_uom_list;

		elsif p_exclude_uom_list is not null then

			l_list := '''' || replace(p_exclude_uom_list, ',', ''',''') || '''';

		end if;

		l_list2 := l_list2 || ',';

		if l_list is not null then

			l_stmt := 'select uom_code from (' || l_stmt;
			l_stmt := l_stmt || ')' || 'where uom_code ';

			if p_include_uom_list is null then
				l_stmt := l_stmt || ' not ';
			end if;

			l_stmt := l_stmt || ' in ' || '(' || l_list || ')';

		end if;



		open get_uom_code for l_stmt;

		loop

		fetch get_uom_code into l_uom_code;
		exit when get_uom_code%notfound;

		msd_dem_common_utilities.log_message('Populating UOM: ' || l_uom_code);
		msd_dem_common_utilities.log_debug('Populating UOM: ' || l_uom_code);

		l_list2 := replace(l_list2, l_uom_code||',' , '');

		process_uom(retcode, l_uom_code);

		if retcode = -1 or retcode = 1 then
			msd_dem_common_utilities.log_message('Failed processing UOM: ' || l_uom_code);
			msd_dem_common_utilities.log_debug('Failed Processing UOM: ' || l_uom_code);
			goto continue;
		end if;

		populate_uom(retcode, l_uom_code, p_instance_id);

<<continue>>
		null;

		end loop;

		close get_uom_code;

		l_list2 := rtrim(l_list2, ',');

		if l_list2 is not null then
		  retcode := 1;
			msd_dem_common_utilities.log_message('Following UOM''s dont exist in source: ' || l_list2);
			msd_dem_common_utilities.log_debug('Following UOM''s dont exist in source: ' || l_list2);
		end if;

		exception
			when others then
				msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
				msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
				retcode := 1;

end;

procedure collect_from_source(errbuf        out nocopy varchar2,
											        retcode       out nocopy number,
											        p_instance_id in  number)

as

l_stmt varchar2(4000);
l_key_values varchar2(4000);
l_instance_type number;
l_retcode number;
x_inst_type_sql varchar2(200);

begin

		-- Bug#8367471 nallkuma
		l_instance_type := null;

		x_inst_type_sql := ' select instance_type from msc_apps_instances where instance_id = ' || p_instance_id ;
		execute immediate x_inst_type_sql into l_instance_type ;
		msd_dem_common_utilities.log_debug('Instance_type : ' || l_instance_type);

		if l_instance_type in (1,2,4) then /* Non-Legacy Instances */ -- Bug#8367471 nallkuma
		  l_instance_type := ' 4 ' ;
		else                               /* Legacy Instances    */
		  l_instance_type := ' 3 ' ;
    end if;


	  l_key_values := '$C_INSTANCE#' || p_instance_id ||
										'$C_INST_TYPE#' || l_instance_type || '$'; -- Bug#8367471 nallkuma

	  msd_dem_query_utilities.get_query2 (
             			l_retcode,
             			l_stmt,
             			'MSD_DEM_UOM_FROM_SOURCE',
             			p_instance_id,
             			l_key_values,
             			0,
             			null);

		if l_stmt  is null then

			msd_dem_common_utilities.log_message('Cannot find query to get UOM conversions from source');
			msd_dem_common_utilities.log_debug('Cannot find query to get UOM conversions from source');
			retcode := -1;
			return;

		end if;

		msd_dem_common_utilities.log_debug('Query: ' || l_stmt);

		msd_dem_common_utilities.log_debug('p_instance_id ' || p_instance_id);

		msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
		execute immediate l_stmt;
		msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

		exception
			when others then
				errbuf  := substr(SQLERRM,1,150);
				msd_dem_common_utilities.log_message(errbuf);
				msd_dem_common_utilities.log_debug(errbuf);
				retcode := -1;


end;

procedure collect_uom(errbuf                 out nocopy varchar2,
											retcode                out nocopy number,
											p_instance_id          in  number,
											p_include_all          in  number,
											p_include_uom_list     in varchar2,
											p_exclude_uom_list     in varchar2)

as

begin

		if p_include_all = 1 and (p_include_uom_list is not null or p_exclude_uom_list is not null) then
			msd_dem_common_utilities.log_message('Cannot specify both collect all and include or exclude list');
			msd_dem_common_utilities.log_debug('Cannot specify both collect all and include or exclude list');
			retcode := -1;
			return;
		end if;

		if p_include_all = 2 and p_include_uom_list is null and p_exclude_uom_list is null then

			msd_dem_common_utilities.log_message('Exactly one of the parameters Include UOM''s or Exclude UOM''s must be specified, when Collect All UOM''s is No');
			msd_dem_common_utilities.log_debug('Exactly one of the parameters Include UOM''s or Exclude UOM''s must be specified, when Collect All UOM''s is No');
			retcode := -1;
			return;

		end if;

		if p_include_all = 2 and p_include_uom_list is not null and p_exclude_uom_list is not null then

			msd_dem_common_utilities.log_message('Should not specify both include and exclude list');
			msd_dem_common_utilities.log_debug('Should not specify both include and exclude list');
			retcode := -1;
			return;

		end if;

		msd_dem_common_utilities.log_message('Collecting UOM''s');
		msd_dem_common_utilities.log_debug('Collecting UOM''s');

		msd_dem_common_utilities.log_message('Collecting UOM conversions from source');
		msd_dem_common_utilities.log_debug('Collecting UOM conversions from source');
		collect_from_source(errbuf, retcode, p_instance_id);

		if retcode = -1 then
			goto error_handle;
		end if;


		msd_dem_common_utilities.log_message('Populating UOM''s in Demand Planning components');
		msd_dem_common_utilities.log_debug('Populating UOM''s in Demand Planning components');
		populate_demantra_uom_table(errbuf, retcode, p_instance_id, p_include_uom_list, p_exclude_uom_list);

		commit;

		if retcode <> -1 and retcode <> 1 then
			retcode := 0;
		end if;
		return;

<<error_handle>>
		retcode := -1;

		exception
			when others then
				errbuf  := substr(SQLERRM,1,150);
				msd_dem_common_utilities.log_message(errbuf);
				msd_dem_common_utilities.log_debug(errbuf);
				retcode := -1;


end;

END MSD_DEM_COLLECT_UOMS;


/
