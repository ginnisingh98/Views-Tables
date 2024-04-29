--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_LEVEL_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_LEVEL_TYPES" AS
/* $Header: msddemcltb.pls 120.3.12010000.4 2010/03/19 08:29:37 sjagathe ship $ */

LOC_TEMPORARY_TABLE              VARCHAR2(240) := 'MSD_DEM_LOCATIONS_GTT ';
LOC_POPULATE_TEMP_TABLE_VIEW     VARCHAR2(240) := 'MSD_DEM_LOCATIONS_GTT_V';

v_collect_level_type varchar2(30);

procedure delete_duplicates(retcode out nocopy number)
as

cursor get_instances is
select instance_id
from msc_apps_instances
order by instance_id;

l_stmt varchar2(4000);

begin

		for c_instance_id in get_instances loop

				l_stmt := 'delete from msd_dem_items_gtt ' ||
									' where (inventory_item_id, sr_demand_class_pk) in ' ||
									' (select sr_inventory_item_id, sr_demand_class_pk ' ||
									' from msd_dem_items_gtt ' ||
									' group by sr_inventory_item_id, sr_demand_class_pk ' ||
									' having count(*) > 1) ' ||
									' and sr_instance_id > :1';

				execute immediate l_stmt using c_instance_id.instance_id;

		end loop;

		exception
        when others then
            msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
            msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
            retcode := -1;

end;


procedure populate_temporary_tables(errbuf             OUT NOCOPY VARCHAR2,
                                  retcode             OUT NOCOPY NUMBER,
                                  p_instance_id      IN  NUMBER,
                                  p_collect_level_type  IN NUMBER,
                                  p_plan_id             IN NUMBER)
as

l_stmt varchar2(4000);

l_sales_staging_table    VARCHAR2(100)    := NULL;

cursor get_plan_info is
select plan_type
from msc_plans
where plan_id = p_plan_id;

l_plan_type number;

begin

       msd_dem_common_utilities.log_debug('In procedure populate_temporary_tables');
             l_sales_staging_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE');
       if (l_sales_staging_table IS NULL)
           then
              retcode := -1;
              msd_dem_common_utilities.log_message ('Unable to find sales staging table name');
              return;
       end if;

       if p_plan_id <> -1 then
       				open get_plan_info;
       				fetch get_plan_info into l_plan_type;
       				close get_plan_info;
				else
							l_plan_type := 0;
				end if;

       if p_collect_level_type = 1 then

               msd_dem_query_utilities.get_query(retcode, l_stmt, 'LOCATION_GTT', p_instance_id, l_sales_staging_table);

               if retcode = -1 then
                   return;
               end if;

       elsif p_collect_level_type = 2 then

               msd_dem_query_utilities.get_query(retcode, l_stmt, 'ITEM_GTT', p_instance_id, l_sales_staging_table);

               l_stmt := replace(l_stmt, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

               if retcode = -1 then
                   return;
               end if;
       else

               retcode := -1;
               return;

     end if;

       l_stmt := replace(l_stmt, 'C_DATA_PLAN_TYPE', l_plan_type);
       l_stmt := replace(l_stmt, 'C_PLAN_ID', p_plan_id);
       l_stmt := replace(l_stmt, 'C_INSTANCE_ID', p_instance_id);

       if p_plan_id <> -1 then
       		delete_duplicates(retcode);
       end if;

       msd_dem_common_utilities.log_debug('Insert statement for populating temporary table for ' ||
                                                                            v_collect_level_type || fnd_global.local_chr(10) || l_stmt || fnd_global.local_chr(10) ||
                                                                            'Instance: ' || p_instance_id || fnd_global.local_chr(10));

       msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10));
       execute immediate l_stmt;
       msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10));

       retcode := 0;

       exception
           when others then
               errbuf  := substr(SQLERRM,1,150);
               dbms_output.put_line(errbuf);
               msd_dem_common_utilities.log_message(errbuf);
               msd_dem_common_utilities.log_debug(errbuf);
               retcode := -1;

end;

procedure  populate_demantra_staging(errbuf              OUT NOCOPY VARCHAR2,
                                            retcode             OUT NOCOPY NUMBER,
                                    p_instance_id       IN  NUMBER,
                                            p_collect_level_type  IN NUMBER,
                                            p_plan_id             IN NUMBER)

as

l_stmt varchar2(32000);

l_staging_table    VARCHAR2(100)    := NULL;
l_master_org            NUMBER        := NULL;
l_category_set_id    NUMBER        := NULL;

l_master_string   VARCHAR2(1000) := NULL;
l_category_string VARCHAR2(1000) := NULL;

cursor get_instances is
select instance_id
from msc_apps_instances;

x_dem_version				VARCHAR2(10) 	:= msd_dem_common_utilities.get_demantra_version;

begin

       msd_dem_common_utilities.log_debug('In procedure populate_demantra_staging');

       if p_collect_level_type = 1 then
                     l_staging_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','LOCATION_STAGING_TABLE');

               msd_dem_query_utilities.get_query(retcode, l_stmt, 'LOCATIONS', p_instance_id, l_staging_table);

               if retcode = -1 then
                   return;
               end if;

       elsif p_collect_level_type = 2 then

               l_staging_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','ITEM_STAGING_TABLE');

               l_master_org := to_number(msd_dem_common_utilities.get_parameter_value (
                                           p_instance_id,
                                           'MSD_DEM_MASTER_ORG'));
               l_category_set_id := to_number(msd_dem_common_utilities.get_parameter_value (
                                           p_instance_id,
                                           'MSD_DEM_CATEGORY_SET_NAME'));
               IF ( l_master_org IS NULL)
               THEN
                  retcode := -1;
                  msd_dem_common_utilities.log_message ('Master organization not set.');
                  return;
               END IF;

               IF (x_dem_version = '7.2')
               THEN
                  msd_dem_query_utilities.get_query(retcode, l_stmt, 'ITEMS', p_instance_id, l_staging_table);
               ELSE
                  msd_dem_query_utilities.get_query(retcode, l_stmt, 'ITEMS_730', p_instance_id, l_staging_table);
               END IF;

               if retcode = -1 then
                   return;
               end if;

     end if;

     msd_dem_common_utilities.log_debug('Insert statement for populating Demantra staging table for ' || v_collect_level_type || fnd_global.local_chr(10) || l_stmt || fnd_global.local_chr(10));
     IF (p_collect_level_type = 2)
     THEN
         msd_dem_common_utilities.log_debug('Bind Variables - ');
         msd_dem_common_utilities.log_debug('Master Organization Id - ' || to_char(l_master_org));
         msd_dem_common_utilities.log_debug('Category Set Id - ' || to_char(l_category_set_id));
     END IF;

       msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10));
       IF (p_collect_level_type = 1)
       THEN
          execute immediate l_stmt;
       ELSIF (p_collect_level_type = 2)
       THEN

					if p_plan_id is not null then

						l_master_string := 'decode(itt.sr_instance_id';
						l_category_string := 'decode(item_master.sr_instance_id';

       			for get_instances_rec in get_instances loop
               		l_master_org := to_number(msd_dem_common_utilities.get_parameter_value (
                                           get_instances_rec.instance_id,
                                           'MSD_DEM_MASTER_ORG'));
               		l_category_set_id := to_number(msd_dem_common_utilities.get_parameter_value (
                                           get_instances_rec.instance_id,
                                           'MSD_DEM_CATEGORY_SET_NAME'));

									l_master_string := l_master_string || ', ' || get_instances_rec.instance_id || ', '''  || l_master_org || '''';
									l_category_string := l_category_string || ', ' || get_instances_rec.instance_id || ', '  || nvl(to_char(l_category_set_id), 'null');

          	end loop;

						l_master_string := l_master_string || ')';
          	l_category_string := l_category_string || ')';

          	l_stmt := replace(l_stmt, 'C_INSTANCE_STRING', l_master_string);
          	l_stmt := replace(l_stmt, 'C_CATEGORY_STRING', l_category_string);

          	EXECUTE IMMEDIATE l_stmt;

          else

          	l_stmt := replace(l_stmt, 'C_INSTANCE_STRING', '''' || l_master_org || '''');
          	l_stmt := replace(l_stmt, 'C_CATEGORY_STRING', l_category_set_id);
          	EXECUTE IMMEDIATE l_stmt;
          end if;

       END IF;
       msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10));

       commit;

       retcode := 0;

       exception
           when others then
               errbuf  := substr(SQLERRM,1,150);
               dbms_output.put_line(errbuf);
               msd_dem_common_utilities.log_message(errbuf);
               msd_dem_common_utilities.log_debug(errbuf);
               retcode := -1;

end;


   PROCEDURE POPULATE_NEW_ITEMS (
   			errbuf              OUT NOCOPY VARCHAR2,
   			retcode             OUT NOCOPY NUMBER,
   			p_sr_instance_id    IN  NUMBER)
   IS

      /*** CURSORS ***/

         CURSOR c_check_new_items
         IS
            SELECT 1
               FROM dual
               WHERE EXISTS (SELECT 1
                                FROM msd_dem_new_items
                                WHERE  sr_instance_id = p_sr_instance_id
                                   AND process_flag = 2);


      /*** LOCAL VARIABLES ***/

         x_errbuf		VARCHAR2(200)	:= NULL;
         x_retcode		VARCHAR2(100)	:= NULL;

         x_new_items_present	NUMBER		:= NULL;

         x_sql			VARCHAR2(32000) := NULL;

         x_item_staging_table	VARCHAR2(100)    := NULL;
         x_master_org		NUMBER		:= NULL;
         x_category_set_id	NUMBER		:= NULL;

         TYPE INV_ITEM_ID_TAB	IS TABLE OF msd_dem_new_items.inventory_item_id%TYPE;
         x_inv_item_id_tab	 INV_ITEM_ID_TAB;

   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_level_types.populate_new_items');


      msd_dem_common_utilities.log_message ('      Populate New Items ');
      msd_dem_common_utilities.log_message ('     --------------------');

      /* Check if there are any yet to be processed NPIs */
      OPEN c_check_new_items;
      FETCH c_check_new_items INTO x_new_items_present;
      CLOSE c_check_new_items;

      IF (x_new_items_present = 1)
      THEN
        msd_dem_common_utilities.log_message ('Found new items for processing');

        x_item_staging_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','ITEM_STAGING_TABLE');
        x_master_org := to_number(msd_dem_common_utilities.get_parameter_value (
                                           	p_sr_instance_id,
                                           	'MSD_DEM_MASTER_ORG'));
        x_category_set_id := to_number(msd_dem_common_utilities.get_parameter_value (
                                           	p_sr_instance_id,
                                           	'MSD_DEM_CATEGORY_SET_NAME'));

        IF ( x_master_org IS NULL)
        THEN
           retcode := 1;
           errbuf  := 'Master organization not set.';
           msd_dem_common_utilities.log_message ('Warning(1): msd_dem_collect_level_types.populate_new_items');
           msd_dem_common_utilities.log_message (errbuf);
           RETURN;
        END IF;

        msd_dem_query_utilities.get_query(x_retcode, x_sql, 'NEW_ITEMS', p_sr_instance_id, x_item_staging_table);

        IF (x_retcode = -1)
        THEN
           retcode := 1;
           errbuf := 'Unable to get the query for populating new items into item staging table';
           msd_dem_common_utilities.log_message ('Warning(2): msd_dem_collect_level_types.populate_new_items');
           msd_dem_common_utilities.log_message (errbuf);
           RETURN;
        END IF;

        msd_dem_common_utilities.log_debug ('Query - ');
        msd_dem_common_utilities.log_debug ('Bind Variables - ');
        msd_dem_common_utilities.log_debug ('Source Instance Id - ' || to_char(p_sr_instance_id));
        msd_dem_common_utilities.log_debug ('Master Organization Id - ' || to_char(x_master_org));
        msd_dem_common_utilities.log_debug ('Category Set Id - ' || to_char(x_category_set_id));

        msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
        EXECUTE IMMEDIATE x_sql USING p_sr_instance_id, p_sr_instance_id, x_master_org, x_category_set_id;
        msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

        /* Set the process_flag */
        UPDATE msd_dem_new_items
           SET process_flag = 1
           WHERE  sr_instance_id = p_sr_instance_id
              AND process_flag = 2;

        COMMIT;

      ELSE
         msd_dem_common_utilities.log_message ('No new items found for processing');
      END IF;

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_level_types.populate_new_items');

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         retcode := 1;
         errbuf  := substr(SQLERRM,1,150);
         msd_dem_common_utilities.log_message ('Exception: msd_dem_collect_level_types.populate_new_items');
         msd_dem_common_utilities.log_message (errbuf);
         RETURN;

   END POPULATE_NEW_ITEMS;


procedure truncate_tables(errbuf               OUT NOCOPY VARCHAR2,
                         retcode               OUT NOCOPY NUMBER,
                         p_collect_level_type  IN NUMBER)

as

l_stmt varchar2(200);

begin

       msd_dem_common_utilities.log_debug('In procedure truncate_tables');

       l_stmt := 'truncate table ';

       if p_collect_level_type = 1 then

           l_stmt := l_stmt || msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','LOCATION_STAGING_TABLE');

       elsif p_collect_level_type = 2 then

           l_stmt := l_stmt || msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','ITEM_STAGING_TABLE');

       end if;
             if l_stmt = 'truncate table ' then
           msd_dem_common_utilities.log_message('Staging table not found');
           retcode := -1;
           return;
       end if;

       msd_dem_common_utilities.log_debug('Truncate Statement for ' || v_collect_level_type || fnd_global.local_chr(10) || l_stmt || fnd_global.local_chr(10));


       msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10));
       execute immediate l_stmt;
       execute immediate l_stmt || '_err';   --saravan Bug# 6357056
        msd_dem_common_utilities.log_debug('Truncated'|| l_stmt || '_err'||'Table');  -- saravan
       msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') || fnd_global.local_chr(10));

       retcode := 0;

       exception
           when others then
               errbuf  := substr(SQLERRM,1,150);
               msd_dem_common_utilities.log_message(errbuf);
               msd_dem_common_utilities.log_debug(errbuf);
               retcode := -1;

end;

procedure collect_levels(errbuf              OUT NOCOPY VARCHAR2,
                           retcode             OUT NOCOPY NUMBER,
                           p_instance_id       IN  NUMBER,
                           p_collect_level_type  IN NUMBER,
                           p_plan_id             IN NUMBER DEFAULT -1)

as
l_schema_name VARCHAR2(100);
begin

      -- BUG#8267074 nallkuma
      l_schema_name := substr(msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE')
                          , 1
                          ,	instr(msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE'), '.')-1) ;

      IF (l_schema_name = 'MSD' ) then -- BUG#8267074 nallkuma
        msd_dem_common_utilities.log_message('NO ACTION performed related to levels since there is NO demantra schema found');
        msd_dem_common_utilities.log_message('NO ACTION performed related to levels assuming its SRP collections');
        return;
      End if ;

       select decode(p_collect_level_type, 1 , 'Locations', 2, 'Items') into v_collect_level_type from dual;

       msd_dem_common_utilities.log_message('Collecting '|| v_collect_level_type || fnd_global.local_chr(10));
       msd_dem_common_utilities.log_debug('Collecting '|| v_collect_level_type || fnd_global.local_chr(10));

       msd_dem_common_utilities.log_message('Step 1: Cleaning up staging tables for ' || v_collect_level_type || fnd_global.local_chr(10));
       msd_dem_common_utilities.log_debug('Step 1: Cleaning up staging tables for ' || v_collect_level_type || fnd_global.local_chr(10));
       truncate_tables(errbuf,retcode,p_collect_level_type);

       if retcode = -1 then
           return;
       end if;

       msd_dem_common_utilities.log_message('Step 2: Populating Temporary Tables ' || v_collect_level_type || fnd_global.local_chr(10));
       msd_dem_common_utilities.log_debug('Step 2: Populating Temporary Tables ' || v_collect_level_type || fnd_global.local_chr(10));
       populate_temporary_tables(errbuf,retcode,p_instance_id,p_collect_level_type, p_plan_id);

       if retcode = -1 then
           return;
       end if;

       msd_dem_common_utilities.log_message('Step 3: Populating Demantra Staging Tables ' || v_collect_level_type || fnd_global.local_chr(10));
       msd_dem_common_utilities.log_debug('Step 3: Populating Demantra Staging Tables ' || v_collect_level_type || fnd_global.local_chr(10));
       populate_demantra_staging(errbuf,retcode, p_instance_id, p_collect_level_type, p_plan_id);

       if retcode = -1 then
           return;
       end if;

       /* Collect NPIs */
/* Bug# 5869314
       if (p_collect_level_type = 2) then
          msd_dem_common_utilities.log_debug('Step 4: Populate New Items ');
          populate_new_items (errbuf,retcode, p_instance_id);
*/
          /* Failure of NPIs collection will be a 'Warning' and not 'Error' */
/* Bug# 5869314
          if retcode = 1 then
             msd_dem_common_utilities.log_message('Warning: msd_dem_collect_level_types.collect_levels');
             msd_dem_common_utilities.log_message('Collect new items completed with warning(s).');
             return;
          end if;
       end if;
*/
       /* Call Custom Hook for Item/Location */
       IF (p_collect_level_type = 2) /* ITEM */
       THEN

          msd_dem_common_utilities.log_debug ('Begin Call Custom Hook msd_dem_custom_hooks.item_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          msd_dem_custom_hooks.item_hook (
           		errbuf,
           		retcode);

          msd_dem_common_utilities.log_debug ('End Call Custom Hook msd_dem_custom_hooks.item_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          IF (retcode = -1)
          THEN
             msd_dem_common_utilities.log_message ('Error: msd_dem_collect_level_types.collect_levels - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             msd_dem_common_utilities.log_message ('Error in call to custom hook msd_dem_custom_hooks.item_hook ');
             RETURN;
          END IF;

          /* Analyze Item Staging Table */
          msd_dem_common_utilities.log_debug ('Begin Analyze item staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          msd_dem_collect_history_data.analyze_table (
           		errbuf,
           		retcode,
         	  	msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','ITEM_STAGING_TABLE'));

          msd_dem_common_utilities.log_debug ('End Analyze item staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          IF (retcode = 1)
          THEN
             msd_dem_common_utilities.log_message ('Warning: msd_dem_collect_level_types.collect_levels - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             msd_dem_common_utilities.log_message ('Error while analyzing item staging table. ');
          END IF;

       ELSIF (p_collect_level_type = 1) /* LOCATION */
       THEN

          msd_dem_common_utilities.log_debug ('Begin Call Custom Hook msd_dem_custom_hooks.location_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          msd_dem_custom_hooks.location_hook (
           		errbuf,
           		retcode);

          msd_dem_common_utilities.log_debug ('End Call Custom Hook msd_dem_custom_hooks.location_hook - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          IF (retcode = -1)
          THEN
             msd_dem_common_utilities.log_message ('Error: msd_dem_collect_level_types.collect_levels - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             msd_dem_common_utilities.log_message ('Error in call to custom hook msd_dem_custom_hooks.location_hook ');
             RETURN;
          END IF;

          /* Analyze Location Staging Table */
          msd_dem_common_utilities.log_debug ('Begin Analyze location staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          msd_dem_collect_history_data.analyze_table (
           		errbuf,
           		retcode,
         	  	msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','LOCATION_STAGING_TABLE'));

          msd_dem_common_utilities.log_debug ('End Analyze location staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

          IF (retcode = 1)
          THEN
             msd_dem_common_utilities.log_message ('Warning: msd_dem_collect_level_types.collect_levels - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
             msd_dem_common_utilities.log_message ('Error while analyzing location staging table. ');
          END IF;

       END IF;

       exception
           when others then
               errbuf  := substr(SQLERRM,1,150);
               msd_dem_common_utilities.log_message(errbuf);
               msd_dem_common_utilities.log_debug(errbuf);
               retcode := -1;

end collect_levels;

END MSD_DEM_COLLECT_LEVEL_TYPES;

/
