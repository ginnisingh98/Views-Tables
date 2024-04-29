--------------------------------------------------------
--  DDL for Package Body MSD_SRP_PROCESS_STREAM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SRP_PROCESS_STREAM_DATA" AS -- body
  /* $Header: MSDSRPPPB.pls 120.6.12010000.2 2008/09/08 11:26:52 vrepaka ship $*/

   null_char constant VARCHAR2(6) := '-23453';

  g_error constant NUMBER := 2;
  g_warning constant NUMBER := 1;

  v_sql_stmt pls_integer;
  v_debug boolean := nvl(fnd_profile.VALUE('MRP_DEBUG'),   'N') = 'Y';

  PROCEDURE log_message(p_error_text IN VARCHAR2) IS
  BEGIN

    IF fnd_global.conc_request_id > 0 THEN
      fnd_file.PUT_LINE(fnd_file.LOG,   p_error_text);
    END IF;

  EXCEPTION
  WHEN others THEN
    RETURN;
  END log_message;

  PROCEDURE launch(errbuf OUT nocopy VARCHAR2,   retcode OUT nocopy NUMBER,   p_instance_id IN NUMBER,   p_stream_id IN NUMBER) IS

  CURSOR get_dm_schema IS
  SELECT owner
  FROM dba_objects
  WHERE owner = owner
   AND object_type = 'TABLE'
   AND object_name = 'MDP_MATRIX'
  ORDER BY created DESC;

  CURSOR check_srp_plan IS
  SELECT demand_plan_id
  FROM msd_demand_plans
  WHERE demand_plan_id = 5555555;

  CURSOR get_scn_id IS
  SELECT scenario_id
  FROM msd_dp_scenarios
  WHERE scenario_name LIKE
    (SELECT DISTINCT(scenario_name)
     FROM msd_dp_scenario_entries
	 WHERE scenario_id = -23453)
  ;

  CURSOR get_scn_name IS
  SELECT DISTINCT(scenario_name)
  FROM msd_dp_scenario_entries
  WHERE scenario_id = -23453;

  CURSOR get_count_err_records(l_scenario_id NUMBER) IS
  SELECT COUNT(*)
  FROM msd_dp_scenario_entries
  WHERE demand_plan_id = 5555555
   AND scenario_id = l_scenario_id;

  CURSOR get_err_records IS
  SELECT * from MSC_ITEM_FAILURE_RATES
  where process_flag = 'E';

  msd_schema_name VARCHAR2(100);
  msc_schema_name VARCHAR2(100);
  l_scenario_name VARCHAR2(100);
  l_entity_name VARCHAR2(100);
  lv_sql_stmt VARCHAR2(4000);
  lv_sql_stmt1 VARCHAR2(4000);
  lv_sql_stmt2 VARCHAR2(4000);
  lv_sql_stmt3 VARCHAR2(4000);
  lv_sql_stmt4 VARCHAR2(4000);
  lv_sql_stmt5 VARCHAR2(4000);
  lv_sql_stmt6 VARCHAR2(4000);
  lv_error_text VARCHAR2(1000);
  lv_dummy1 VARCHAR2(32);
  lv_dummy2 VARCHAR2(32);

  bind_var VARCHAR2(20);

  l_scenario_id NUMBER;
  l_demand_plan_id NUMBER;
  l_err_count NUMBER;

  lv_retval boolean;

  failure_rate_id get_err_records % rowtype;

  BEGIN

    log_message('***************** Entered in the procedure - LAUNCH **********');

    OPEN get_dm_schema;
    FETCH get_dm_schema
    INTO msd_schema_name;
    CLOSE get_dm_schema;

    IF msd_schema_name IS NOT NULL THEN

      IF(p_stream_id < 6) THEN
        lv_retval := fnd_installation.get_app_info('MSD',   lv_dummy1,   lv_dummy2,   msd_schema_name);
      END IF;

    ELSE
      lv_retval := fnd_installation.get_app_info('MSD',   lv_dummy1,   lv_dummy2,   msd_schema_name);
    END IF;

    lv_retval := fnd_installation.get_app_info('MSC',   lv_dummy1,   lv_dummy2,   msc_schema_name);

    --LOG_MESSAGE('Fetched the schema name from profile MSD_DEM_SCHEMA as '||msd_schema_name);

    IF p_stream_id = 1 THEN

      l_entity_name := 'InstallBaseHistory';
      v_sql_stmt := 01;
      lv_sql_stmt := ' UPDATE  ' || msd_schema_name || '.MSD_DEM_INS_BASE_HISTORY t1'
      || ' SET t1.level1_sr_pk = ( SELECT t2.sr_inventory_item_id '
      || '    FROM msc_system_items t2 '
      || '    WHERE t2.sr_instance_id  =  :p_instance_id '
      || '                           AND   t2.item_name       = t1.level1 '
      || '                           AND   rownum = 1) ';

    END IF;

    IF p_stream_id = 2 THEN

      l_entity_name := 'Field Service Usage History';
      v_sql_stmt := 02;
      lv_sql_stmt := ' UPDATE  ' || msd_schema_name
      || '.MSD_DEM_FLD_SER_USG_HISTORY t1'
      || ' SET t1.level1_sr_pk = ( SELECT distinct(t2.sr_inventory_item_id) '
       || '            FROM msc_system_items t2 '
       || '          WHERE t2.sr_instance_id  =  :p_instance_id '
       || '          AND   t2.item_name       = t1.level1 '
       || '          AND   rownum = 1) ' ;

      lv_sql_stmt1 := ' UPDATE ' || msd_schema_name
      || '.MSD_DEM_FLD_SER_USG_HISTORY t1'
      || ' SET t1.level2_sr_pk = ( SELECT t2.region_id '
      || '                       FROM msc_regions t2 '
      || '              where t2.sr_instance_id = :p_instance_id '
       || '               AND t2.zone = t1.level2 '
       || '               AND t2.zone_usage = 1)'  ;

    END IF;

    IF p_stream_id = 3 THEN

      l_entity_name := 'Depot Repair Usage History';
      v_sql_stmt := 03;
      lv_sql_stmt := ' UPDATE  '
       || msd_schema_name
        || '.MSD_DEM_DPT_REP_USG_HISTORY t1'
	|| ' SET t1.level1_sr_pk = ( SELECT distinct(t2.sr_inventory_item_id) '
	|| '                           FROM msc_system_items t2 '
	|| '                  WHERE t2.sr_instance_id  =  :p_instance_id '
	|| '                    AND   t2.item_name       = t1.level1) ';

      lv_sql_stmt1 := ' UPDATE '
      || msd_schema_name
      || '.MSD_DEM_DPT_REP_USG_HISTORY t1'
      || ' SET t1.level2_sr_pk = ( SELECT t2.sr_tp_id '
      || '                       FROM msc_trading_partners t2 '
      || '              where t2.sr_instance_id = :p_instance_id '
      || '              AND t2.organization_code = t1.level2) ';

    END IF;

    IF p_stream_id = 4 THEN

      l_entity_name := 'Service Part Return History';
      v_sql_stmt := 04;
      lv_sql_stmt := ' UPDATE  '
      || msd_schema_name
      || '.MSD_DEM_SRP_RETURN_HISTORY t1'
      || ' SET t1.level1_sr_pk = ( SELECT distinct(t2.sr_inventory_item_id) '
      || '                           FROM msc_system_items t2 '
      || '                WHERE t2.sr_instance_id  =  :p_instance_id '
      || '                           AND   t2.item_name       = t1.level1 '
      || '                           AND   rownum = 1) ';

      lv_sql_stmt1 := ' UPDATE '
      || msd_schema_name || '.MSD_DEM_SRP_RETURN_HISTORY t1'
      || ' SET t1.level2_sr_pk = ( SELECT t2.region_id '
      || '                       FROM msc_regions t2 '
      || '             where t2.sr_instance_id = :p_instance_id '
      || '                       AND t2.zone = t1.level2 '
      || '                       AND t2.zone_usage = 1)';

    END IF;

    IF p_stream_id = 5 THEN

      l_entity_name := 'Failure Rates';
      v_sql_stmt := 05;

      lv_sql_stmt := 'UPDATE ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES t1'
      || ' SET t1.using_assembly_id = nvl((select distinct(t2.inventory_item_id)'
      || '                             FROM msc_system_items t2 '
      || '                  where t2.sr_instance_id = :p_instance_id '
      || '                     and t2.item_name = t1.using_assembly_name),-55555) ';

      lv_sql_stmt1 := 'UPDATE ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES t1'
      || ' SET t1.inventory_item_id = nvl((select distinct(t2.inventory_item_id) '
      || '                             FROM msc_system_items t2 '
      || '                      where t2.sr_instance_id = :p_instance_id '
      || '                             and t2.item_name = t1.item_name),-55555) ';

      lv_sql_stmt2 := ' UPDATE ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES '
      || ' SET FAILURE_RATE = 1'
      || ' where failure_rate > 1'
      || ' and process_flag = ''N'' ';

      lv_sql_stmt3 := ' UPDATE ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES '
      || ' SET FAILURE_RATE = 0'
      || ' where failure_rate < 0'
      || ' and process_flag = ''N'' ';

      lv_sql_stmt4 := ' UPDATE ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES '
      || ' SET PROCESS_FLAG = ''P'''
      || ' where PROCESS_FLAG = ''N''';

      lv_sql_stmt5 := ' UPDATE ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES '
      || ' SET PROCESS_FLAG = ''E'''
      || ' where PROCESS_FLAG = ''N'''
      || ' and (USING_ASSEMBLY_ID = -55555 or INVENTORY_ITEM_ID = -55555) ';

      lv_sql_stmt6 := 'DELETE FROM ' || msc_schema_name
      || '.MSC_ITEM_FAILURE_RATES '
      || 'WHERE PROCESS_FLAG = ''E''';

    END IF;

    IF p_stream_id = 6 THEN

      l_entity_name := 'Product Return History';
      v_sql_stmt := 06;
      --lv_sql_stmt := ' UPDATE  ' || msd_schema_name
      --|| '.MSD_DEM_RETURN_HISTORY t1'
      -- || ' SET t1.level1_sr_pk = ( SELECT distinct(t2.sr_inventory_item_id) '
      --|| '                           FROM msc_system_items t2 '
      -- || '                      WHERE t2.sr_instance_id  =  :p_instance_id '
      -- || '                           AND   t2.item_name       = t1.level1) ';

    END IF;

    IF p_stream_id = 7 THEN

      l_entity_name := 'Forecast Data';
      v_sql_stmt := 07;

	  OPEN check_srp_plan;
      FETCH check_srp_plan
      INTO l_demand_plan_id;
      CLOSE check_srp_plan;

      OPEN get_scn_id;
      FETCH get_scn_id
      INTO l_scenario_id;
      CLOSE get_scn_id;

      IF l_demand_plan_id IS NULL THEN

        INSERT
        INTO msd_demand_plans(demand_plan_id,   organization_id,   demand_plan_name,   last_update_date,   last_updated_by,   creation_date,   created_by,   sr_instance_id,   use_org_specific_bom_flag)
        VALUES(5555555,   -23453,   'SRP DUMMY PLAN',   trunc(sysdate),   fnd_global.user_id,   trunc(sysdate),   fnd_global.user_id,   -23453,   'N');

      END IF;

      IF l_scenario_id IS NOT NULL THEN

        OPEN get_scn_name;
        FETCH get_scn_name
        INTO l_scenario_name;
        CLOSE get_scn_name;

	lv_sql_stmt := 'DELETE FROM MSD_DP_SCENARIO_ENTRIES WHERE demand_plan_id = 5555555 and scenario_id = :l_scenario_id';
	EXECUTE IMMEDIATE lv_sql_stmt USING l_scenario_id;

          UPDATE MSD_DP_SCENARIO_ENTRIES SET SCENARIO_ID = l_scenario_id where scenario_name = l_scenario_name
          and demand_plan_id = 5555555 and scenario_id = -23453;

		END IF;

      IF l_scenario_id IS NULL THEN
        bind_var := ':l_scenario_name,';

        OPEN get_scn_name;
        FETCH get_scn_name
        INTO l_scenario_name;
        CLOSE get_scn_name;
        lv_sql_stmt := 'INSERT INTO MSD_DP_SCENARIOS(demand_plan_id,scenario_id,scenario_name, '
	|| 'last_update_date,last_updated_by,creation_date,created_by)'
	|| 'values(5555555,MSD_DP_SCENARIOS_S.nextval,' || bind_var
	|| 'trunc(sysdate),fnd_global.user_id,trunc(sysdate),fnd_global.user_id)';
        EXECUTE IMMEDIATE lv_sql_stmt USING l_scenario_name;

        INSERT INTO MSD_DP_SCENARIO_OUTPUT_LEVELS(demand_plan_id,scenario_id,level_id,last_update_date,last_updated_by,creation_date,created_by)
        values(5555555,MSD_DP_SCENARIOS_S.CURRVAL,1,trunc(sysdate),fnd_global.user_id,trunc(sysdate),fnd_global.user_id);

        OPEN get_scn_id;
        FETCH get_scn_id
        INTO l_scenario_id;
        CLOSE get_scn_id;

        lv_sql_stmt1 := 'UPDATE MSD_DP_SCENARIO_ENTRIES SET SCENARIO_ID = MSD_DP_SCENARIOS_S.CURRVAL' || ' WHERE SCENARIO_NAME = :l_scenario_name ';
        log_message(lv_sql_stmt1);
        EXECUTE IMMEDIATE lv_sql_stmt1 USING l_scenario_name;
      END IF;

      COMMIT;

      lv_sql_stmt2 := 'DELETE FROM MSD_DP_SCN_ENTRIES_DENORM ' || 'WHERE SCENARIO_ID = :l_scenario_id ' || 'AND DEMAND_PLAN_ID = 5555555';

      EXECUTE IMMEDIATE lv_sql_stmt2 USING l_scenario_id;

      INSERT
      INTO msd_dp_scn_entries_denorm(demand_plan_id,   scenario_id,   demand_id,   sr_inventory_item_id,   sr_organization_id,   start_time,   end_time,   quantity,   creation_date,   created_by)
        (SELECT mdse.demand_plan_id,
           mdse.scenario_id,
           mdse.entry_id,
           msi.sr_inventory_item_id,
           mtp.sr_tp_id,
           mdse.time_lvl_val_from,
           mdse.time_lvl_val_to,
           mdse.total_quantity,
           mdse.creation_date,
           mdse.created_by
         FROM msd_dp_scenario_entries mdse,
           msc_trading_partners mtp,
           msc_system_items msi
         WHERE mdse.demand_plan_id = 5555555
         AND mdse.scenario_id = l_scenario_id
         AND mdse.organization_lvl_val = mtp.organization_code
         AND mdse.product_lvl_val = msi.item_name
         AND mtp.sr_instance_id = p_instance_id
         AND mtp.partner_type = 3
         AND mtp.sr_tp_id = msi.organization_id
         AND msi.sr_instance_id = p_instance_id
         AND msi.plan_id = -1)
      ;

      DELETE FROM msd_dp_scenario_entries mdse
      WHERE mdse.scenario_id = l_scenario_id
       AND mdse.organization_lvl_val IN
        (SELECT organization_code
         FROM msc_trading_partners
         WHERE sr_instance_id = p_instance_id
         AND partner_type = 3
         AND organization_code LIKE mdse.organization_lvl_val
         AND rownum = 1)
      AND mdse.product_lvl_val IN
        (SELECT item_name
         FROM msc_system_items
         WHERE sr_instance_id = p_instance_id
         AND item_name LIKE mdse.product_lvl_val
         AND rownum = 1)
      ;

      OPEN get_count_err_records(l_scenario_id);
      FETCH get_count_err_records
      INTO l_err_count;
      CLOSE get_count_err_records;

      IF l_err_count > 0 THEN
        log_message('Records with demand_plan_id 5555555 and scenario_id '|| l_scenario_id ||' in table  MSD_DP_SCENARIO_ENTRIES errored out.');
        retcode := g_error;

		END IF;

      COMMIT;

    END IF;

    IF v_debug THEN
      log_message(lv_sql_stmt);

      IF lv_sql_stmt1 IS NOT NULL THEN
        log_message(lv_sql_stmt1);
      END IF;

      IF lv_sql_stmt2 IS NOT NULL THEN
        log_message(lv_sql_stmt2);
      END IF;

    END IF;

    BEGIN

      IF lv_sql_stmt IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt USING p_instance_id;
      END IF;

      IF lv_sql_stmt1 IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt1 USING p_instance_id;
      END IF;

      IF lv_sql_stmt2 IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt2;
      END IF;

      IF lv_sql_stmt3 IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt3;
      END IF;

      IF lv_sql_stmt5 IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt5;

        LOG_MESSAGE('The following records errored out during validation : ');

        FOR failure_rate_id in get_err_records
        LOOP
          LOG_MESSAGE(failure_rate_id.FAILURE_RATE || '~' ||
                      failure_rate_id.COLLECTED_FLAG || '~' ||
                      failure_rate_id.RETIREMENT_RATE || '~' ||
                      failure_rate_id.ITEM_NAME || '~' ||
                      failure_rate_id.USING_ASSEMBLY_NAME
          );
          retcode := g_error;
        EXIT WHEN get_err_records % NOTFOUND;
        END LOOP;
      END IF;

      IF lv_sql_stmt4 IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt4;
      END IF;

      IF lv_sql_stmt6 IS NOT NULL
       AND p_stream_id < 7 THEN
        EXECUTE IMMEDIATE lv_sql_stmt6;
      END IF;

    EXCEPTION
    WHEN others THEN
      log_message('Error generating Source Keys');

      lv_error_text := SUBSTR('MSD_SRP_PROCESS_STREAM_DATA.LAUNCH ' || '(' || v_sql_stmt || ')' || sqlerrm,   1,   240);
      log_message(lv_error_text);

      errbuf := lv_error_text;
      retcode := g_error;
    END;
    --Final commit
    COMMIT;

    log_message('***************** Exiting from the procedure - LAUNCH **********');

  END launch;

END msd_srp_process_stream_data;


/
