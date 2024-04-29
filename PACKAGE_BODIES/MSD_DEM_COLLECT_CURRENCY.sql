--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_CURRENCY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_CURRENCY" AS
/* $Header: msddemccb.pls 120.5.12010000.5 2009/06/08 10:39:07 syenamar ship $ */

  PROCEDURE get_min_max_date(l_min_date OUT NOCOPY DATE,
  													 l_max_date OUT NOCOPY DATE) AS

  l_stmt VARCHAR2(1000);

  BEGIN

    l_stmt := 'select max(datet), min(datet) from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'INPUTS');

    EXECUTE IMMEDIATE l_stmt
    INTO l_max_date,
      l_min_date;

  EXCEPTION
  WHEN others THEN
    msd_dem_common_utilities.log_message(SUBSTR(sqlerrm,   1,   150));
    msd_dem_common_utilities.log_debug(SUBSTR(sqlerrm,   1,   150));

  END;

  PROCEDURE process_currency(retcode OUT NOCOPY VARCHAR2,
  													 p_currency_code IN VARCHAR2,
  													 p_base_currency_code IN VARCHAR2,
  													 p_from_date IN DATE,
  													 p_to_date IN DATE,
  													 l_base_curr IN VARCHAR2,
  													 g_dblink IN VARCHAR2)

   AS

  l_lookup_value VARCHAR2(200);
  l_schema_name VARCHAR2(200);

  CURSOR verify_entities_inuse IS
  SELECT 1
  FROM msd_dem_entities_inuse
  WHERE internal_name = p_currency_code
  and ebs_entity = 'Currency';

  type c_get_new_currency_real_value IS ref CURSOR;
  get_new_currency_real_value c_get_new_currency_real_value;
  l_stmt_new_currency_real_value VARCHAR2(2000);

  type new_currency_rectype IS record(real_value_id NUMBER,   real_table VARCHAR2(500));

  new_currency new_currency_rectype;

  type c_get_old_currency_real_value IS ref CURSOR;
  get_old_currency_real_value c_get_old_currency_real_value;
  l_stmt_old_currency_real_value VARCHAR2(2000);

  type c_get_component IS ref CURSOR;
  get_component c_get_component;
  l_stmt_get_component VARCHAR2(2000);

   type c_get_component_sop IS ref CURSOR;
  get_component_sop c_get_component_sop;
  l_stmt_get_component_sop VARCHAR2(2000);

  type c_get_seeded_unit is ref cursor;
  get_seeded_unit c_get_seeded_unit;
  l_stmt_get_seeded_unit varchar2(2000);

  l_get_seeded_unit varchar2(250);

  l_verify_entities_inuse NUMBER;

  l_component_id NUMBER;
  l_component_id_sop NUMBER;
  l_cur_count number;

  l_stmt VARCHAR2(2000);

  BEGIN

  	l_stmt_get_seeded_unit := 'select real_value from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'REAL_VALUES') ||
		                                   ' where real_value = ''' || p_currency_code || '''';

		open get_seeded_unit for l_stmt_get_seeded_unit;
		fetch get_seeded_unit into l_get_seeded_unit;
		close get_seeded_unit;

    OPEN verify_entities_inuse;
    FETCH verify_entities_inuse
    INTO l_verify_entities_inuse;
    CLOSE verify_entities_inuse;

    IF l_verify_entities_inuse IS NOT NULL THEN

      l_stmt_old_currency_real_value := 'select real_value_id, real_table from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'REAL_VALUES') || ' where real_value = ''' || p_currency_code || '''';

      OPEN get_old_currency_real_value FOR l_stmt_old_currency_real_value;
      FETCH get_old_currency_real_value
      INTO new_currency;
      CLOSE get_old_currency_real_value;

      -- msd_dem_common_utilities.log_message('Currency Code: '||p_currency_code ||' already exists.');

      ELSIF l_verify_entities_inuse IS NULL THEN

      	if l_get_seeded_unit is not null then
		  			msd_dem_common_utilities.log_message('Seeded Display Unit with name ' || p_currency_code || ' exist in Demantra. This Currency will not be created');
		  			msd_dem_common_utilities.log_debug('Seeded Display Unit with name ' || p_currency_code || ' exist in Demantra. This Currency will not be created');
		  			retcode := 1;
		  			return;
    	  end if;

        msd_dem_common_utilities.log_message('Creating Currency : ' || p_currency_code);

        -- Bug#7199587    syenamar
        -- Use 'real_table' field to look for empty dummy currencies, 'real_value' field might contain value in any supported language other than english

        l_stmt_new_currency_real_value := 'select real_value_id, real_table from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'REAL_VALUES') ||
                                            ' where real_value_id in ' ||
                                            '       (select distinct real_value_id from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'REAL_VALUES') ||
                                            '        minus ' ||
                                            '        select distinct real_value_id from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'DCM_PRODUCTS_INDEX') || ') ' ||
                                            ' and real_table in ' ||
                                            '       (select real_table from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'REAL_VALUES') || ' where real_table like ''EBSCURRENCY%''' ||
                                            '        minus ' ||
                                            '        select table_name from msd_dem_entities_inuse where ebs_entity = ''Currency'')' ||
                                            ' and rownum < 2';
        msd_dem_common_utilities.log_debug(l_stmt_new_currency_real_value);
        -- syenamar

        OPEN get_new_currency_real_value FOR l_stmt_new_currency_real_value;
        FETCH get_new_currency_real_value
        INTO new_currency;

        IF get_new_currency_real_value % NOTFOUND THEN
          msd_dem_common_utilities.log_message('Cannot create new currency' || ' as no more empty dummy currency exists.');
          msd_dem_common_utilities.log_debug('Cannot create new currency' || ' as no more empty dummy currency exists.');
          CLOSE get_new_currency_real_value;
          retcode := 1;
          RETURN;
        END IF;

        CLOSE get_new_currency_real_value;

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
                   ''Currency''
                   ,''INDEX''
                   ,:1
                   ,:2
                   ,NULL
                   ,:4
                   ,:5
                   ,:6
                   ,:7
                   ,:8
                   )';

        EXECUTE IMMEDIATE l_stmt USING p_currency_code, new_currency.real_table, sysdate, fnd_global.user_id, sysdate, fnd_global.user_id, fnd_global.user_id;
        l_stmt := 'update ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'REAL_VALUES') || '
                                     set real_value = :1
                                     where real_value_id = :2';

        EXECUTE IMMEDIATE l_stmt USING p_currency_code,
          new_currency.real_value_id;

          -- Bug#7199587    syenamar
          -- Use component id obtained from lookup

        /*l_stmt_get_component := 'select dcm_product_id from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'DCM_PRODUCTS') || ' where product_name = '''
                                || msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'DEMAND_MANAGEMENT') || '''';

        OPEN get_component FOR l_stmt_get_component;
        FETCH get_component
        INTO l_component_id;
        CLOSE get_component;*/

        /* Bug#8224935 - APP ID */ -- nallkuma
        l_component_id := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                             'COMP_DM',
                                                                              1,
                                                                              'dcm_product_id'));

        l_stmt := 'insert into ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'DCM_PRODUCTS_INDEX') || '
                                     (dcm_product_id
                                      ,real_value_id
                                     )
                                     (
                                     select :1, :2 from dual
                                     )';
        EXECUTE IMMEDIATE l_stmt USING l_component_id,
          new_currency.real_value_id;



        /*l_stmt_get_component_sop := 'select dcm_product_id from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'DCM_PRODUCTS') || ' where product_name = '''
                                || msd_dem_common_utilities.get_lookup_value('MSD_DEM_COMPONENTS', 'SOP') || '''';

        OPEN get_component_sop FOR l_stmt_get_component_sop;
        FETCH get_component_sop
        INTO l_component_id_sop;
        CLOSE get_component_sop;*/

        /* Bug#8224935 - APP ID */ -- nallkuma
         l_component_id_sop := to_number(msd_dem_common_utilities.get_app_id_text('MSD_DEM_DEMANTRA_OBJECT_ID',
                                                                                  'COMP_SOP',
                                                                                  1,
                                                                                  'dcm_product_id'));

        l_stmt := 'insert into ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES',   'DCM_PRODUCTS_INDEX') || '
                                     (dcm_product_id
                                      ,real_value_id
                                     )
                                     (
                                     select :1, :2 from dual
                                     )';
        EXECUTE IMMEDIATE l_stmt USING l_component_id_sop, new_currency.real_value_id;
        -- syenamar

        l_stmt := 'insert into ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'INDEXES_FOR_UNITS') ||
				          ' (display_units_id, real_value_id) ' ||
				          ' (select display_units_id, :1 from ' || msd_dem_common_utilities.get_lookup_value('MSD_DEM_TABLES', 'DISPLAY_UNITS') || ' du, msd_dem_entities_inuse mdei ' ||
				          ' where mdei.ebs_entity = ''PRL'' and mdei.internal_name =  du.display_units)';

				msd_dem_common_utilities.log_debug(l_stmt);

				execute immediate l_stmt using new_currency.real_value_id;

      END IF;

      msd_dem_common_utilities.log_message('Collecting Currency : ' || p_currency_code);
      msd_dem_common_utilities.log_debug('Collecting Currency : ' || p_currency_code);

      msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate,   'DD-MM-YYYY HH24:MI:SS'));

      l_stmt := 'delete from ' || fnd_profile.VALUE('MSD_DEM_SCHEMA') || '.' || new_currency.real_table || ' where index_date between :1 and :2 ';

      msd_dem_common_utilities.log_debug('Bind Variables: ');
      msd_dem_common_utilities.log_debug('From Date: ' || p_from_date);
      msd_dem_common_utilities.log_debug('To Date: ' || p_to_date);
      msd_dem_common_utilities.log_debug('Delete statement for currency: ' || l_stmt);

      EXECUTE IMMEDIATE l_stmt USING p_from_date,
        p_to_date;

      IF(p_currency_code <> l_base_curr) THEN
        l_stmt := 'insert into ' || fnd_profile.VALUE('MSD_DEM_SCHEMA') || '.' || new_currency.real_table || ' (index_date, index_value) ' || '(select conversion_date, round(conversion_rate, 5) from
                             gl_daily_ratesDBLINK
                              where from_currency = ' || '''' || p_base_currency_code || '''' || ' and to_currency = ' || '''' || p_currency_code || '''' || ' and conversion_date between :1 and :2 ' ||
                              ' and conversion_type = fnd_profile.valueDBLINK(''MSD_DEM_CONVERSION_TYPE'') )';
        l_stmt := REPLACE(l_stmt,   'DBLINK',   g_dblink);
      ELSE
        l_stmt := 'insert into ' || fnd_profile.VALUE('MSD_DEM_SCHEMA') || '.' || new_currency.real_table || ' (index_date, index_value) ' || '(select conversion_date, round((1/conversion_rate), 5) from
                             gl_daily_ratesDBLINK
                              where from_currency = ' || '''' || p_currency_code || '''' || ' and to_currency = ' || '''' || p_base_currency_code || '''' || ' and conversion_date between :1 and :2 ' ||
                              ' and conversion_type = fnd_profile.valueDBLINK(''MSD_DEM_CONVERSION_TYPE'') )';
        l_stmt := REPLACE(l_stmt,   'DBLINK',   g_dblink);
      END IF;

      msd_dem_common_utilities.log_debug(l_stmt);

      EXECUTE IMMEDIATE l_stmt USING p_from_date,
        p_to_date;
      COMMIT;

			l_stmt := 'select count(*) from ' ||  fnd_profile.VALUE('MSD_DEM_SCHEMA') || '.' || new_currency.real_table || ' where rownum < 5';

			execute immediate l_stmt into l_cur_count;

			if l_cur_count = 0 then
				msd_dem_common_utilities.log_message('No records exist for currency ' || p_currency_code || ' between ' || p_from_date || ' and ' || p_to_date);
			end if;

      msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate,   'DD-MM-YYYY HH24:MI:SS'));
      msd_dem_common_utilities.log_message('Currency : ' || p_currency_code || ' collection is finished.');
      msd_dem_common_utilities.log_debug('Currency : ' || p_currency_code || ' collection is finished.');

    END;

    PROCEDURE collect_currency(errbuf OUT NOCOPY VARCHAR2,
    													 retcode OUT NOCOPY VARCHAR2,
    													 p_instance_id IN NUMBER,
    													 p_from_date IN VARCHAR2 DEFAULT NULL,
    													 p_to_date IN VARCHAR2 DEFAULT NULL,
    													 p_all_currencies IN NUMBER,
    													 p_include_currency_list IN VARCHAR2 DEFAULT NULL,
    													 p_exclude_currency_list IN VARCHAR2 DEFAULT NULL)

     AS

    /*** LOCAL VARIABLES ****/ x_errbuf VARCHAR2(200) := NULL;
    x_retcode VARCHAR2(100) := NULL;
    g_dblink VARCHAR2(30) := NULL;

    l_min_date DATE;
    l_max_date DATE;

    l_date_to DATE;
    l_date_from DATE;

    type get_curr_code IS ref CURSOR;
    c_get_curr_code get_curr_code;

    l_stmt VARCHAR2(3000);

    l_base_curr VARCHAR2(30);

    l_list VARCHAR2(5000);
    l_list2 VARCHAR2(5000);

    l_curr_code VARCHAR2(30);

    BEGIN

      msd_dem_common_utilities.log_debug('Entering: msd_dem_collect_currency.collect_currency - ' || to_char(systimestamp,   'DD-MON-YYYY HH24:MI:SS'));
      msd_dem_common_utilities.log_message('Entering: msd_dem_collect_currency.collect_currency - ' || to_char(systimestamp,   'DD-MON-YYYY HH24:MI:SS'));

      /* Get the db link to the source instance */ msd_dem_common_utilities.get_dblink(x_errbuf,   x_retcode,   p_instance_id,   g_dblink);

      IF(x_retcode = '-1') THEN
        retcode := -1;
        errbuf := x_errbuf;
        msd_dem_common_utilities.log_message('Error(1): msd_dem_collect_currency.collect_currency - ' || to_char(systimestamp,   'DD-MON-YYYY HH24:MI:SS'));
        RETURN;
      END IF;

      /* Get the min and max date in demantra time */

       get_min_max_date(l_min_date,   l_max_date);

      l_base_curr := fnd_profile.VALUE('MSD_DEM_CURRENCY_CODE');

      l_date_from := nvl(fnd_date.canonical_to_date(p_from_date),   l_min_date);
      l_date_to := nvl(fnd_date.canonical_to_date(p_to_date),   l_max_date);

      /* Error if p_from_date is greater than p_to_date */

      IF(l_date_from > l_date_to) THEN
        retcode := -1;
        errbuf := 'From Date should not be greater than To Date.';
        msd_dem_common_utilities.log_message('Error: msd_dem_collect_currency.collect_currency- ' || to_char(systimestamp,   'DD-MON-YYYY HH24:MI:SS'));
        msd_dem_common_utilities.log_message(errbuf);
        RETURN;
      END IF;

      IF(p_all_currencies = 2) THEN

        IF p_include_currency_list IS NOT NULL
         AND p_exclude_currency_list IS NOT NULL THEN

          msd_dem_common_utilities.log_message('Both include list and exclude list are specified for currency collection. Please specify either include list or excluse list.');
          msd_dem_common_utilities.log_debug('Both include list and exclude list are specified for currency collection. Please specify either include list or excluse list.');
          retcode := -1;
          RETURN;
          ELSIF p_include_currency_list IS NULL
           AND p_exclude_currency_list IS NULL THEN

            msd_dem_common_utilities.log_message('None of include list and exclude list are not specified for currency collection. Please specify either include list or excluse list.');
            msd_dem_common_utilities.log_debug('None of include list and exclude list are not specified for currency collection. Please specify either include list or excluse list.');
            retcode := -1;
            RETURN;

          END IF;

        END IF;

         /* FOR THOSE CURRENCIES WHICH HAVE CONVERSION RATES DEFINED FROM THEM TO THE BASE CURRENCIES. */

        l_stmt := NULL;

        l_stmt := 'select distinct from_currency from_currency ' || ' from gl_daily_rates' || g_dblink || ' where to_currency = ''' || l_base_curr || '''' ||
        					' and conversion_type = fnd_profile.value' || g_dblink || '(''MSD_DEM_CONVERSION_TYPE'') ';

        l_list := NULL;
        l_list2 := NULL;

        IF p_include_currency_list IS NOT NULL THEN

          l_list := replace(p_include_currency_list, '''', '''''');
          l_list := '''' || REPLACE(l_list,   ',',   ''',''') || '''';
          l_list2 := p_include_currency_list;

          ELSIF p_exclude_currency_list IS NOT NULL THEN

            l_list := replace(p_exclude_currency_list, '''', '''''');
            l_list := '''' || REPLACE(l_list,   ',',   ''',''') || '''';

          END IF;

          l_list2 := l_list2 || ',';

          IF l_list IS NOT NULL THEN

            l_stmt := 'select from_currency from (' || l_stmt;
            l_stmt := l_stmt || ')' || 'where from_currency ';

            IF p_include_currency_list IS NULL THEN
              l_stmt := l_stmt || ' not ';
            END IF;

            l_stmt := l_stmt || ' in ' || '(' || l_list || ')';

          END IF;

          msd_dem_common_utilities.log_debug(l_stmt);

          OPEN c_get_curr_code FOR l_stmt;

          LOOP
            FETCH c_get_curr_code
            INTO l_curr_code;

            EXIT
          WHEN c_get_curr_code % NOTFOUND;

          /*if l_curr_code = l_base_curr then
          		msd_dem_common_utilities.log_message('Warning: Base Currency is selected for collection');
          		retcode := 1;
          		goto continue;
          end if;*/

          process_currency(x_retcode,   l_curr_code,   l_base_curr,   l_date_from,   l_date_to,   l_curr_code,   g_dblink);
          l_list2 := REPLACE(l_list2,   l_curr_code || ',',   '');

<<continue>>
					null;

          IF(x_retcode = 1) THEN
            retcode := 1;
            errbuf := x_errbuf;
          END IF;

        END LOOP;

        CLOSE c_get_curr_code;

				if instr(l_list2, l_base_curr) > 0 then
						msd_dem_common_utilities.log_message('Warning: Base Currency ' || l_base_curr || ' is selected. Base Currency cannot be collected.');
						l_list2 := RTRIM(l_list2, l_base_curr || ',');
          	retcode := 1;
				end if;

        l_list2 := RTRIM(l_list2, ',');

        IF(l_list2 IS NOT NULL) THEN
          retcode := 1;
          msd_dem_common_utilities.log_message('Warning: Currencies: ' || l_list2 || ' do not exist.');
        END IF;

        if retcode <> -1 and retcode <> 1 then
        	retcode := 0;
        end if;
        RETURN;

      EXCEPTION
      WHEN others THEN
        errbuf := SUBSTR(sqlerrm,   1,   150);
        msd_dem_common_utilities.log_message(errbuf);
        msd_dem_common_utilities.log_debug(errbuf);
        retcode := -1;

      END;

    END msd_dem_collect_currency;


/
