--------------------------------------------------------
--  DDL for Package Body MSD_DEM_QUERY_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_QUERY_UTILITIES" AS
/* $Header: msddemqutlb.pls 120.2.12010000.2 2008/11/04 11:08:55 sjagathe ship $ */

v_srdblink varchar2(100);


      /*
       * This procedure logs a given debug message text in ???
       * only if the profile MSD_DEM_DEBUG is set to 'Yes'.
       * param: p_buff - debug message text to be logged.
       */
       PROCEDURE LOG_DEBUG ( p_buff           IN  VARCHAR2)
       IS
       BEGIN
          IF (C_MSD_DEM_DEBUG = 'Y') THEN
             NULL;
          END IF;
       END LOG_DEBUG;



      /*
       * This procedure logs a given message text in ???
       * param: p_buff - message text to be logged.
       */
       PROCEDURE LOG_MESSAGE ( p_buff           IN  VARCHAR2)
       IS
       BEGIN
          NULL;
       END LOG_MESSAGE;


/* Should be changed to msd_dem_common_utilites*/

procedure get_db_link(p_instance_id    IN  NUMBER,
                      p_dblink         IN OUT NOCOPY  VARCHAR2,
                      p_retcode        IN OUT NOCOPY  NUMBER)

as

Begin

        SELECT decode( m2a_dblink,
                      null, '',
                      '@'||m2a_dblink)
         INTO p_dblink
         FROM MSC_APPS_INSTANCES
         WHERE instance_id = p_instance_id;


        -- zia: changed retcode to 0, since 1 means warning
        --p_retcode := 1 ;
        p_retcode := 0; /* Should be changed to proper constants from msd_dem_common_utilities */

  Exception
     when others then
     p_dblink := null ;
     p_retcode := -1 ; /* Should be changed to proper constants from msd_dem_common_utilities */


End get_db_link ;

procedure get_query(retcode             OUT NOCOPY NUMBER,
                    query               OUT NOCOPY VARCHAR2,
                    p_entity_name       IN  VARCHAR2,
                    p_instance_id       IN  NUMBER,
                    p_dest_table        IN VARCHAR2 DEFAULT NULL,
                    p_add_where_clause  IN VARCHAR2 DEFAULT NULL)

as

l_part1_query       varchar2(32000);
l_part2_query       varchar2(32000);
l_part3_query       varchar2(32000);
l_final_query       varchar2(32000);

cursor c_get_part1_query is
select query
from msd_dem_queries  mdq,
     msd_dem_entity_queries mdeq
where mdeq.part1 = mdq.query_id
and mdeq.entity_name = p_entity_name;

cursor c_get_part2_query is
select query
from msd_dem_queries  mdq,
     msd_dem_entity_queries mdeq
where mdeq.part2 = mdq.query_id
and mdeq.entity_name = p_entity_name;

cursor c_get_part3_query is
select query
from msd_dem_queries  mdq,
     msd_dem_entity_queries mdeq
where mdeq.part3 = mdq.query_id
and mdeq.entity_name = p_entity_name;

begin

                msd_dem_common_utilities.log_debug('In procedure: get_query');
                get_db_link(p_instance_id, v_srdblink, retcode);

                /*msd_dem_common_utilities.log_message();*/
                msd_dem_common_utilities.log_debug('The instance dblink for this query will be: '|| v_srdblink );


                open c_get_part1_query;
                fetch c_get_part1_query into l_part1_query;
                close c_get_part1_query;

                open c_get_part2_query;
                fetch c_get_part2_query into l_part2_query;
                close c_get_part2_query;

                open c_get_part3_query;
                fetch c_get_part3_query into l_part3_query;
                close c_get_part3_query;

                l_final_query := replace(l_part1_query || l_part2_query || l_part3_query, 'C_DEST_TABLE', p_dest_table);

                l_final_query := replace(l_final_query, 'C_ADD_WHERE_CLAUSE', nvl(p_add_where_clause, ' 1 = 1 '));

                l_final_query := replace(l_final_query, 'DBLINK', v_srdblink);

                /*msd_dem_common_utilities.log_debug('The final query is: ' || l_final_query );                         */

                query := l_final_query;

                exception
                        when others then
                                msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
                                msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
                                retcode :=  -1;

end get_query;


procedure get_query2(retcode             OUT NOCOPY NUMBER,
		    query               OUT NOCOPY VARCHAR2,
                    p_entity_name       IN  VARCHAR2,
                    p_instance_id       IN  NUMBER,
                    keys_values IN VARCHAR2,
                    flag IN NUMBER,
		    view_name VARCHAR2 default null
)
as

l_part1_query   varchar2(32000);
l_part2_query   varchar2(32000);
l_part3_query   varchar2(32000);
l_final_query   varchar2(32000);
pos1 number;
pos2 number;
pos3 number;
i number;
key varchar2(30);
value varchar2(300);
cv_name varchar2(300);

x_is_view_valid NUMBER := NULL;

TYPE c_get_cursor is ref cursor;
c_get_parts  c_get_cursor;

begin

		msd_dem_common_utilities.log_debug('In procedure: msd_dem_query_utilities.get_query2');
		get_db_link(p_instance_id, v_srdblink, retcode);

		/*msd_dem_common_utilities.log_message();*/
		msd_dem_common_utilities.log_debug('The instance dblink for this query will be: '|| v_srdblink );

			open c_get_parts for select query from msd_dem_queries mdq,msd_dem_entity_queries mdeq where mdeq.part1 = mdq.query_id and mdeq.entity_name = p_entity_name;
			fetch c_get_parts into l_part1_query;
			close c_get_parts;

			open c_get_parts for select query from msd_dem_queries mdq,msd_dem_entity_queries mdeq where mdeq.part2 = mdq.query_id and mdeq.entity_name = p_entity_name;
			fetch c_get_parts into l_part2_query;
			close c_get_parts;

			open c_get_parts for select query from msd_dem_queries mdq,msd_dem_entity_queries mdeq where mdeq.part3 = mdq.query_id and mdeq.entity_name = p_entity_name;
			fetch c_get_parts into l_part3_query;
			close c_get_parts;
			query := l_part1_query || l_part2_query || l_part3_query;
			cv_name:=p_entity_name||'_V';

		if(flag=1) then
		 cv_name:=view_name;
		end if;
			-- Custom view does not exists. Create a new view.
			open c_get_parts for select query from msd_dem_queries mdq,msd_dem_entity_queries mdeq where mdeq.part1 = mdq.query_id and mdeq.entity_name = p_entity_name||'_V';
			fetch c_get_parts into l_part1_query;
			close c_get_parts;

			open c_get_parts for select query from msd_dem_queries mdq,msd_dem_entity_queries mdeq where mdeq.part2 = mdq.query_id and mdeq.entity_name = p_entity_name||'_V';
			fetch c_get_parts into l_part2_query;
			close c_get_parts;

			open c_get_parts for select query from msd_dem_queries mdq,msd_dem_entity_queries mdeq where mdeq.part3 = mdq.query_id and mdeq.entity_name = p_entity_name||'_V';
			fetch c_get_parts into l_part3_query;
			close c_get_parts;

				i:=0;
				l_final_query := l_part1_query || l_part2_query || l_part3_query;
				loop
					i:=i+1;
					pos1:= instr(keys_values,'$',1,i);
					pos2:=instr(keys_values,'#',1,i);
					key:=substr(keys_values,pos1+1,pos2-pos1-1);
					pos3:= instr(keys_values,'$',1,i+1);
					value:=substr(keys_values,pos2+1,pos3-pos2-1);
					exit when (instr(keys_values,'$',1,i+1)=0);
					l_final_query := replace(l_final_query, key,value);
					query := replace(query, key,value);
					msd_dem_common_utilities.log_debug('key=' || key ||' value='||value || ' i = ' ||i);
				end loop;
                                l_final_query := replace(l_final_query,'C_SOURCE_VIEW_NAME',cv_name);
                                query := replace(query,'C_DBLINK',v_srdblink);
                                query := replace(query,'C_SOURCE_VIEW_NAME',cv_name);
				--execute create view query by passing it to the source procedure
		if(flag=0) then
			 l_final_query := replace(l_final_query,'''','''''');
				l_final_query:='
				begin
				MSD_DEM_SR_UTIL.EXECUTE_REMOTE_QUERY'||v_srdblink||'('''||l_final_query||''');
			end;';
                        msd_dem_common_utilities.log_debug('The query is: ' || l_final_query );
			execute immediate l_final_query;

                        /* Check if the view created is VALID or NOT */
                        begin
                           execute immediate 'SELECT 1 FROM ' || cv_name || v_srdblink || ' WHERE 1 = 2 ' INTO x_is_view_valid;
                        exception
                           when no_data_found then
                              null;
                           when others then
                              retcode := -1;
                              msd_dem_common_utilities.log_message ('Error: msd_dem_query_utilities.get_query2 - ');
                              msd_dem_common_utilities.log_message ('The source view ' || cv_name || ' was not created sucessfully');
                        end;
                else
                   msd_dem_common_utilities.log_message('In msd_dem_query_utilities.get_query - ');
                   msd_dem_common_utilities.log_message('Custom View ' || cv_name || ' used.');
		end if;
	exception
	when others then
		msd_dem_common_utilities.log_message(substr(SQLERRM,1,150));
		msd_dem_common_utilities.log_debug(substr(SQLERRM,1,150));
		retcode :=   -1;

end get_query2;


   PROCEDURE GET_QUERY3 (
   		retcode             	OUT NOCOPY 	NUMBER,
		query               	OUT NOCOPY 	VARCHAR2,
                p_entity_name       	IN  		VARCHAR2,
                p_instance_id       	IN  		NUMBER,
                p_key_values 		IN 		VARCHAR2,
                p_custom_view_flag	IN 		NUMBER,
		p_custom_view_name	IN 		VARCHAR2 DEFAULT NULL,
		p_series_type		IN		NUMBER	 DEFAULT 1,
		p_ps_view_name		IN		VARCHAR2 DEFAULT NULL )
   AS

      TYPE C_GET_CURSOR IS REF CURSOR;
      xc_get_parts		C_GET_CURSOR;

      x_query_part1		VARCHAR2(5000)	:= NULL;
      x_query_part2		VARCHAR2(5000)	:= NULL;
      x_query_part3		VARCHAR2(5000)	:= NULL;
      x_query_final   		VARCHAR2(32000) := NULL;

      i 			NUMBER		:= NULL;
      x_pos1 			NUMBER		:= NULL;
      x_pos2 			NUMBER		:= NULL;
      x_pos3 			NUMBER		:= NULL;

      x_key			VARCHAR2(50)	:= NULL;
      x_value			VARCHAR2(500)	:= NULL;

      x_view_name		VARCHAR2(100)	:= NULL;
      x_is_view_valid 		NUMBER 		:= NULL;

   BEGIN
      log_debug ('Entering: msd_dem_query_utilities.get_query2 - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      IF (p_series_type = 1)
      THEN
         get_db_link(p_instance_id, v_srdblink, retcode);
         IF (retcode = -1)
         THEN
            log_message ('Error(1): msd_dem_query_utilities.get_query2 - Unable to get db_link' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
            query := NULL;
            RETURN;
         END IF;
      ELSE
         v_srdblink := NULL;
      END IF;

      log_debug ('The instance dblink for this query will be: ' || v_srdblink);

      OPEN xc_get_parts FOR SELECT query
                               FROM msd_dem_entity_queries mdeq,
                                    msd_dem_queries mdq
                               WHERE  mdeq.entity_name = p_entity_name
                                  AND mdq.query_id = mdeq.part1;
      FETCH xc_get_parts INTO x_query_part1;
      CLOSE xc_get_parts;

      OPEN xc_get_parts FOR SELECT query
                               FROM msd_dem_entity_queries mdeq,
                                    msd_dem_queries mdq
                               WHERE  mdeq.entity_name = p_entity_name
                                  AND mdq.query_id = mdeq.part2;
      FETCH xc_get_parts INTO x_query_part2;
      CLOSE xc_get_parts;

      OPEN xc_get_parts FOR SELECT query
                               FROM msd_dem_entity_queries mdeq,
                                    msd_dem_queries mdq
                               WHERE  mdeq.entity_name = p_entity_name
                                  AND mdq.query_id = mdeq.part3;
      FETCH xc_get_parts INTO x_query_part3;
      CLOSE xc_get_parts;

      query := x_query_part1 || x_query_part2 || x_query_part3;

      x_view_name := p_entity_name || '_V';
      IF (p_series_type = 2)
      THEN
         x_view_name := p_ps_view_name;
      END IF;

      IF (p_custom_view_flag = 1)
      THEN
         x_view_name := p_custom_view_name;
      END IF;

      IF (    p_series_type = 1
          AND nvl(p_custom_view_flag, 0) <> 1)
      THEN

         x_query_part1 := NULL;
         x_query_part2 := NULL;
         x_query_part3 := NULL;

         OPEN xc_get_parts FOR SELECT query
                                  FROM msd_dem_entity_queries mdeq,
                                       msd_dem_queries mdq
                                  WHERE  mdeq.entity_name = x_view_name
                                     AND mdq.query_id = mdeq.part1;
         FETCH xc_get_parts INTO x_query_part1;
         CLOSE xc_get_parts;

         OPEN xc_get_parts FOR SELECT query
                                  FROM msd_dem_entity_queries mdeq,
                                       msd_dem_queries mdq
                                  WHERE  mdeq.entity_name = x_view_name
                                     AND mdq.query_id = mdeq.part2;
         FETCH xc_get_parts INTO x_query_part2;
         CLOSE xc_get_parts;

         OPEN xc_get_parts FOR SELECT query
                                  FROM msd_dem_entity_queries mdeq,
                                       msd_dem_queries mdq
                                  WHERE  mdeq.entity_name = x_view_name
                                     AND mdq.query_id = mdeq.part3;
         FETCH xc_get_parts INTO x_query_part3;
         CLOSE xc_get_parts;

         x_query_final := x_query_part1 || x_query_part2 || x_query_part3;

      END IF;

      i:= 0;
      LOOP
         i := i + 1;

         x_pos1 := instr (p_key_values, '$', 1, i);
         x_pos2 := instr (p_key_values, '#', 1, i);

         x_key := substr (p_key_values, x_pos1 + 1, x_pos2 - x_pos1 - 1);

         x_pos3 := instr (p_key_values, '$', 1, i + 1);

         x_value := substr (p_key_values, x_pos2 + 1, x_pos3 - x_pos2 - 1);

         EXIT WHEN (instr ( p_key_values, '$', 1, i + 1) = 0);

         x_query_final := replace (x_query_final, x_key, x_value);
	 query := replace (query, x_key, x_value);
         log_debug('KEY = ' || x_key || ', VALUE = ' || x_value || ', i = ' || i);

      END LOOP;

      x_query_final := replace (x_query_final, 'C_SOURCE_VIEW_NAME', x_view_name);
      query := replace(query, 'C_DBLINK', v_srdblink);
      query := replace(query, 'C_SOURCE_VIEW_NAME', x_view_name);


      IF (    p_series_type = 1
          AND p_custom_view_flag = 0)
      THEN

         x_query_final := replace (x_query_final, '''', '''''');
         x_query_final:=' BEGIN msd_dem_sr_util.execute_remote_query' || v_srdblink || '(''' || x_query_final || '''); END;';

         log_debug ('The source query is : ' || x_query_final);
         EXECUTE IMMEDIATE x_query_final;

         /* Check if the view created is VALID or NOT */
         BEGIN
            EXECUTE IMMEDIATE 'SELECT 1 FROM ' || x_view_name || v_srdblink || ' WHERE 1 = 2 ' INTO x_is_view_valid;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               retcode := -1;
               log_message ('Error(2): msd_dem_query_utilities.get_query2 - ');
               log_message ('The source view ' || x_view_name || ' was not created sucessfully');
         END;
      ELSE
         log_message('Custom View ' || x_view_name || ' used.');
      END IF;

      log_debug ('Exiting: msd_dem_query_utilities.get_query2 - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         log_message (substr(SQLERRM,1,150));
         retcode :=   -1;

   END GET_QUERY3;



   /*
    * Given an identifier for the query to be executed and a list of key value pairs.
    * This procedure generates the query, replaces the constants and executes the query.
    */
   PROCEDURE EXECUTE_QUERY (
                errbuf              	OUT NOCOPY 	VARCHAR2,
                retcode             	OUT NOCOPY 	VARCHAR2,
                p_entity_name       	IN  		VARCHAR2,
                p_sr_instance_id       	IN  		NUMBER,
                p_key_values 		IN 		VARCHAR2 )
   IS

      TYPE C_GET_CURSOR IS REF CURSOR;
      xc_get_parts		C_GET_CURSOR;

      x_query_part1		VARCHAR2(5000)	:= NULL;
      x_query_part2		VARCHAR2(5000)	:= NULL;
      x_query_part3		VARCHAR2(5000)	:= NULL;
      x_query   		VARCHAR2(32000) := NULL;

      i 			NUMBER		:= NULL;
      x_pos1 			NUMBER		:= NULL;
      x_pos2 			NUMBER		:= NULL;
      x_pos3 			NUMBER		:= NULL;

      x_key			VARCHAR2(50)	:= NULL;
      x_value			VARCHAR2(500)	:= NULL;

   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_query_utilities.execute_query - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      /* Log the parameters */
      msd_dem_common_utilities.log_debug (' Entity Name - ' || p_entity_name);
      msd_dem_common_utilities.log_debug (' Instance Id - ' || to_char(p_sr_instance_id));
      msd_dem_common_utilities.log_debug (' Key Values Pairs - ' || p_key_values);


      OPEN xc_get_parts FOR SELECT query
                               FROM msd_dem_entity_queries mdeq,
                                    msd_dem_queries mdq
                               WHERE  mdeq.entity_name = p_entity_name
                                  AND mdq.query_id = mdeq.part1;
      FETCH xc_get_parts INTO x_query_part1;
      CLOSE xc_get_parts;

      OPEN xc_get_parts FOR SELECT query
                               FROM msd_dem_entity_queries mdeq,
                                    msd_dem_queries mdq
                               WHERE  mdeq.entity_name = p_entity_name
                                  AND mdq.query_id = mdeq.part2;
      FETCH xc_get_parts INTO x_query_part2;
      CLOSE xc_get_parts;

      OPEN xc_get_parts FOR SELECT query
                               FROM msd_dem_entity_queries mdeq,
                                    msd_dem_queries mdq
                               WHERE  mdeq.entity_name = p_entity_name
                                  AND mdq.query_id = mdeq.part3;
      FETCH xc_get_parts INTO x_query_part3;
      CLOSE xc_get_parts;

      x_query := x_query_part1 || x_query_part2 || x_query_part3;

      msd_dem_common_utilities.log_debug (' The query v1 is - ');
      msd_dem_common_utilities.log_debug (x_query);


      /* Replace the constants */
      IF (p_key_values IS NOT NULL)
      THEN
         i:= 0;
         LOOP
            i := i + 1;

            x_pos1 := instr (p_key_values, '$', 1, i);
            x_pos2 := instr (p_key_values, '#', 1, i);

            x_key := substr (p_key_values, x_pos1 + 1, x_pos2 - x_pos1 - 1);

            x_pos3 := instr (p_key_values, '$', 1, i + 1);

            x_value := substr (p_key_values, x_pos2 + 1, x_pos3 - x_pos2 - 1);

            EXIT WHEN (instr ( p_key_values, '$', 1, i + 1) = 0);

            x_query := replace (x_query, x_key, x_value);
            msd_dem_common_utilities.log_debug ('KEY = ' || x_key || ', VALUE = ' || x_value || ', i = ' || i);

         END LOOP;
      END IF;

      x_query := replace (x_query, 'C_SR_INSTANCE_ID', to_char(p_sr_instance_id));
      x_query := replace (x_query, 'C_SCHEMANAME', fnd_profile.value('MSD_DEM_SCHEMA'));

      msd_dem_common_utilities.log_debug (' The query v2 is - ');
      msd_dem_common_utilities.log_debug (x_query);

      msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
      EXECUTE IMMEDIATE x_query;
      COMMIT;
      msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_query_utilities.execute_query - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_query_utilities.execute_query - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	 RETURN;

   END EXECUTE_QUERY;


   /*
    * Given a table name, location (MSD(2) or Demantra(1)), this procedure truncates(1) or deletes(2)
    * all data from the table.
    */
   PROCEDURE TRUNCATE_TABLE (
                errbuf              	OUT NOCOPY 	VARCHAR2,
                retcode             	OUT NOCOPY 	VARCHAR2,
                p_table_name		IN		VARCHAR2,
                p_owner			IN		NUMBER 	DEFAULT 1,
                p_truncate		IN		NUMBER 	DEFAULT 1 )
   IS

      x_schema		VARCHAR2(100) := NULL;
      x_sql		VARCHAR2(500) := NULL;

      x_dummy1         	VARCHAR2(32);
      x_dummy2         	VARCHAR2(32);
      x_retval         	BOOLEAN;


   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_query_utilities.truncate_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      /* Log the parameters */
      msd_dem_common_utilities.log_debug (' Table Name - ' || p_table_name);
      msd_dem_common_utilities.log_debug (' Owner - ' || to_char(p_owner));
      msd_dem_common_utilities.log_debug (' Truncate - ' || to_char(p_truncate));

      IF (p_owner = 1)
      THEN
         x_schema := fnd_profile.value('MSD_DEM_SCHEMA');
      ELSE
         x_retval := fnd_installation.get_app_info ( 'MSD', x_dummy1, x_dummy2, x_schema );
      END IF;

      msd_dem_common_utilities.log_debug (' Schema - ' || x_schema);

      IF (p_truncate = 1)
      THEN
         x_sql := 'TRUNCATE TABLE ' || x_schema || '.' || p_table_name;
      ELSE
         x_sql := 'DELETE FROM ' || x_schema || '.' || p_table_name;
      END IF;

      msd_dem_common_utilities.log_debug ('Query - ');
      msd_dem_common_utilities.log_debug (x_sql);

      msd_dem_common_utilities.log_debug ('Query Start Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
      IF (p_truncate = 1)
      THEN
         EXECUTE IMMEDIATE x_sql;
      ELSE
         EXECUTE IMMEDIATE x_sql;
         COMMIT;
      END IF;
      msd_dem_common_utilities.log_debug ('Query End Time - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_query_utilities.truncate_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_query_utilities.truncate_table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	 RETURN;

   END TRUNCATE_TABLE;


END MSD_DEM_QUERY_UTILITIES;


/
