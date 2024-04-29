--------------------------------------------------------
--  DDL for Package Body MSD_FCST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_FCST_PUB" AS
    /* $Header: msdfpshb.pls 120.2 2006/07/07 10:51:55 amitku noship $ */

-- this auxiliary function executes a dynamic SQL string and gets a result
-- I need to do it this way because Forms' version of PL/SQL does not support dynamic SQL
function get_result(v_sql_stmt in varchar2)
return varchar2 IS
v_res varchar2(1000);
begin
  execute immediate v_sql_stmt into v_res;
  return v_res;
end;

function cstring (dblink in varchar2) return varchar2 is
begin
  if dblink is null then
    return '';
  else
    return '@' || dblink;
  end if;
end cstring;

-- this is the main routine in the package, it does everything
procedure MSDFPUSH_execute(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  p_demand_plan_id in number,
  p_scenario_id in number,
  p_revision in varchar2,
  p_instance_id in number,
  p_forecast_designator in varchar2,
  p_forecast_set in varchar2,
  p_demand_class in varchar2,
  p_level_id in number,
  p_value_id in number,
  p_customer_id in number,
  p_location_id in number,
  p_use_baseline_fcst in number,
  p_workday_control in number)
IS
  TYPE CurRef IS REF CURSOR;
  lpks CurRef;
  sc_entries CurRef;
  n number;
  a number;
  v_time_lvl_id number;
  v_bucket_type number;
  v_forecast_designator varchar2(10);
  v_new_fcst boolean;
  l_insert varchar2(3000) := 'INSERT ';
  l_select varchar2(3000) := 'SELECT ';
  l_from varchar2(3000):= 'FROM ';
  l_where varchar2(3000):= 'WHERE ';
  l_group_by varchar2(3000):= 'GROUP BY ';
  v_sql_stmt varchar2(3000);
  v_customer_id number;
  v_location_id number;
  cus_pk number;
  loc_pk number;
  v_level_id number;
  v_quant varchar2(20);
  v_item_id number;
  v_org_id msd_level_values.sr_level_pk%TYPE;
  org_id VARCHAR2(240);
  org_pk number;
  v_fcst_date date;
  v_quantity number;
  v_fcst_end_date date;
  i number :=0;
  v_organization_id number;
  v_dblink varchar2(129);
  cnt number;
  lvl_id number;
  dim varchar2(3);
  hier number;
  lvl number;
  lvl2 number;
  lvl3 number;
  qstr varchar2(2000);
  ltc varchar2(3);
  cus_state number;


-- B1485277 added new variables for use in Process MFG queries
  v_process_flag VARCHAR2(1) := NULL;
  v_forecast_id  NUMBER(10) := 0;
  l_source_apps_version VARCHAR2(1) := NULL;

  l_round_off number := NULL;

  CURSOR c_round_off IS
  SELECT roundoff_decimal_places
  FROM msd_demand_plans
  WHERE demand_plan_id = p_demand_plan_id;

  CURSOR c_sr_lvl_pk(p_lvl_pk number) IS
  select sr_level_pk
  from msd_level_values
  where level_pk = p_lvl_pk;

  l_sr_dcs_lvl_pk   varchar2(30) := NULL;
  l_sr_org_lvl_pk   varchar2(30) := NULL;

BEGIN

  retcode := 0;
  errbuf := '';

  -- Before we begin, we find time level - days, weeks, or periods

  select output_period_type into v_time_lvl_id from msd_dp_scenarios
  where demand_plan_id = p_demand_plan_id and scenario_id = p_scenario_id;

  if (v_time_lvl_id= 9) then v_bucket_type := 1;
  elsif (v_time_lvl_id = 1) then v_bucket_type := 2;
  elsif (v_time_lvl_id = 2) then v_bucket_type := 3;
  else
    errbuf := 'Invalid Output Period Type';
    retcode := -1;
    return;
  end if;

  select m2a_dblink into v_dblink from msc_apps_instances
  where instance_id = p_instance_id;

  v_dblink := cstring(v_dblink);

  v_quant := 'quantity';

-- p_customer_id and p_location_id are the filters

  if p_customer_id is null then
    v_customer_id := NULL;
  else
    select sr_level_pk
    into v_customer_id
    from msd_level_values
    where level_pk = p_customer_id;
  end if;

  if p_location_id is null then
    v_location_id := NULL;
  else
    select sr_level_pk
    into v_location_id
    from msd_level_values
    where level_pk = p_location_id;
  end if;


   /* DWK  Need to change here.
       If user choose ORG level_id, then we should only consider those
       orgs that user has chosen from the forms */

/* For SR ORG Level PKs that exist in the scenario entries */
/* Begin of 1 */
for v_org_id in (select lv.sr_level_pk
                   from   msd_level_values lv,
                          (select organization_lvl_pk opk
                           from msd_dp_scenario_entries
                           where demand_plan_id = p_demand_plan_id
                           and scenario_id = p_scenario_id
                           and revision = p_revision
                           group by organization_lvl_pk) sce
                   where  lv.level_pk = sce.opk ) LOOP

  BEGIN  /* Begin of 2 */

  /* If user selects organization as a filter condition
     then populate forecast set only for this org */
 l_sr_org_lvl_pk := NULL;
 IF (p_level_id = 7) and (p_value_id is not NULL) THEN
      OPEN c_sr_lvl_pk(p_value_id);
      FETCH c_sr_lvl_pk INTO l_sr_org_lvl_pk;
      CLOSE c_sr_lvl_pk;
 END IF;

 IF ( nvl(l_sr_org_lvl_pk, v_org_id.sr_level_pk) = v_org_id.sr_level_pk) THEN

      /* If user selects demand class as filter condition */
      l_sr_dcs_lvl_pk := NULL;
      IF (p_level_id = 34) and (p_value_id is not NULL) THEN
         OPEN c_sr_lvl_pk(p_value_id);
         FETCH c_sr_lvl_pk  INTO l_sr_dcs_lvl_pk;
         CLOSE c_sr_lvl_pk;

        /* If passed demand class value is 'Other' then treat it as NULL */
         IF l_sr_dcs_lvl_pk = '-777' THEN
            l_sr_dcs_lvl_pk := NULL;
         END IF;
      END IF;

    -- Check if forecast_designator/org_id already exists
    org_id := v_org_id.sr_level_pk;

    select APPS_VER
    into l_source_apps_version
    from msc_apps_instances
    where instance_id = p_instance_id;

    v_process_flag := 'N';

    if (l_source_apps_version = 3) then   /* Only for 11i source instance */
       -- B1485277 This query will collect the indicator as to whether an org is
       -- process or not
       v_sql_stmt :=    ' SELECT'
                     || '   process_enabled_flag'
                     || ' FROM'
                     || '   mtl_parameters'|| v_dblink
                     || ' WHERE'
                     || '   organization_id = :l_org_id ';
       EXECUTE IMMEDIATE v_sql_stmt INTO v_process_flag USING org_id;
    end if;

    -- B1485277 If the organization is not process then execute the following
    -- otherwise execute the discrete version
    IF v_process_flag = 'N' THEN
      v_sql_stmt := 'select count(*) from mrp_forecast_designators'|| v_dblink ||
        ' where forecast_designator = :l_forecast_designator '||
        ' and organization_id = :l_org_id ';
      execute immediate v_sql_stmt into cnt USING p_forecast_designator, org_id;
--
-- Changes -- VM
-- Changed sql stmts into dynamic sql statements as inserts into mrp_forecast_designators and
-- other mrp tables should be done at source instance not in the planning server
--
       if cnt=0 then
         v_sql_stmt  := 'insert into mrp_forecast_designators'
           || v_dblink || '( ' ||
          'forecast_designator,' ||
          'organization_id,' ||
          'forecast_set,' ||
          'consume_forecast,' ||
          'update_type,' ||
          'bucket_type,' ||
          'last_update_date,' ||
          'last_updated_by,' ||
          'creation_date,' ||
          'created_by,' ||
          'demand_class,' ||
          'customer_id,' ||
          'ship_id' ||
          ') values (' ||
          '''' || replace(p_forecast_designator, '''', '''''') || ''',' || -- forecast_designator,
          org_id                        || ','   || -- organization_id,
          '''' || replace(p_forecast_set, '''', '''''') || ''','   ||  -- forecast_set
          '''' || '1'                   || ''','   || -- consume_forecast,
          'decode (' ||  '''' || v_customer_id || ''''  ||   ', '''',' ||
          'decode (' ||  '''' || v_location_id || ''''  ||   ',  '''', 6, 2),' ||
          'decode (' ||  '''' || v_location_id || ''''  ||   ',  '''', 4,2)),' || -- update_type
          '''' || v_bucket_type         || ''','   || -- bucket_type,
          'sysdate'                     || ','   || -- last_update_date,
          '''' || '1'                   || ''',' ||  -- last_updated_by,
          'sysdate, ' || -- creation_date,
          '''' || '1'                   || ''',' ||   -- created_by
          '''' || nvl(l_sr_dcs_lvl_pk,replace(p_demand_class, '''', '''''')) || ''','   || -- demand_class,
          '''' || v_customer_id         || ''','   || -- customer_id,
          '''' || V_location_id         || ''')'; -- ship_id
          -- Execute the insert.
         execute immediate v_sql_stmt;
       else /* else for cnt=0 */
         v_sql_stmt := 'delete from mrp_forecast_items' || v_dblink ||
           ' where forecast_designator = :l_forecast_designator' ||
           ' and organization_id = :l_org_id ';
         execute immediate v_sql_stmt USING p_forecast_designator, org_id;

         v_sql_stmt := 'delete from mrp_forecast_dates ' || v_dblink ||
          ' where forecast_designator = :l_forecast_designator' ||
          ' and organization_id = :l_org_id ';
         execute immediate v_sql_stmt USING p_forecast_designator, org_id;

         v_sql_stmt := 'update mrp_forecast_designators' || v_dblink || ' ' ||
          ' set ' ||
          'forecast_set = ' || '''' || replace(p_forecast_set, '''', '''''') || ''',' ||
          'bucket_type = '  || '''' || v_bucket_type  || ''',' ||
          'last_update_date = sysdate,' ||
          'last_updated_by = 1,' ||
          'demand_class = ' || '''' || nvl(l_sr_dcs_lvl_pk,replace(p_demand_class, '''', '''''')) || ''',' ||
          'customer_id = '  || '''' || v_customer_id  || ''',' ||
          'ship_id = '''      || v_location_id  || '''' ||
          ' where forecast_designator = ' || '''' || replace(p_forecast_designator, '''', '''''')
          || '''' ||
          '  and organization_id = ' || org_id;
          execute immediate v_sql_stmt;
       end if; /* end of cnt=0 */

    -- now - the same for forecast set

       v_sql_stmt := 'select count(*) from mrp_forecast_designators' || v_dblink
                  || ' ' ||
                  'where forecast_designator = ''' || replace(p_forecast_set, '''', '''''') || '''' ||
                  '  and organization_id = ' || org_id;
       execute immediate v_sql_stmt into cnt;

       if cnt=0 then
         v_sql_stmt := 'insert into mrp_forecast_designators' || v_dblink
          || ' (' ||
          'forecast_designator, ' ||
          'organization_id, ' ||
          'forecast_set, ' ||
          'consume_forecast, ' ||
          'update_type, ' ||
          'bucket_type, ' ||
          'last_update_date, ' ||
          'last_updated_by, ' ||
          'creation_date, ' ||
          'created_by, ' ||
          'demand_class, ' ||
          'customer_id, ' ||
          'ship_id ' ||
          ') values ( ' ||
          '''' || replace(p_forecast_set, '''', '''''') || ''',' ||  -- forecast_designator,
          org_id                 || ','   ||  -- organization_id,
          'NULL,'                         ||  -- forecast_set
          '1,'                            ||  -- consume_forecast,
          'decode (' ||  '''' || v_customer_id || ''''  ||   ', '''',' ||
          'decode (' ||  '''' || v_location_id || ''''  ||   ',  '''', 6, 2),' ||
          'decode (' ||  '''' || v_location_id || ''''  ||   ',  '''', 4,2)),' || -- update_type
          '''' || v_bucket_type  || ''',' || -- bucket_type,
          'sysdate,'                      ||  -- last_update_date,
          '1,'                            || -- last_updated_by,
          'sysdate,'                      || -- creation_date,
          '1,'                            || -- created_by
          '''' || nvl(l_sr_dcs_lvl_pk,replace(p_demand_class, '''', '''''')) || ''',' ||  -- demand_class,
          'NULL, '                        ||-- customer_id,
          'NULL '                         ||-- ship_id
          ')';
         execute immediate v_sql_stmt;
       else  /* Else of cnt=0 */
         v_sql_stmt := 'update mrp_forecast_designators' || v_dblink || ' ' ||
          ' set bucket_type = ' || '''' || v_bucket_type || ''',' ||
          '     last_update_date = sysdate, '             ||
          '     last_updated_by = 1,'                     ||
          '     demand_class = ' || '''' || nvl(l_sr_dcs_lvl_pk,replace(p_demand_class, '''', '''''')) || '''' ||
          '     where forecast_designator = ' || '''' || replace(p_forecast_set, '''', '''''') || '''' ||
          '      and organization_id = ' || org_id;
         execute immediate v_sql_stmt;
       end if; /* end for cnt=0 */
   END IF;  /* END for v_process_flag = 'N' */

--
-- End Changes VM
--
    -- we now find out whether f_desg AND dp_sc_entries are loc and/or customer specific

    cus_state := 0;

    v_level_id := 0;

    begin
      v_sql_stmt := 'select level_id from msd_dp_scn_output_levels_v ' ||
                    'where demand_plan_id = ' || p_demand_plan_id ||
                    '  and scenario_id = ' || p_scenario_id ||
                    '  and owning_dimension_code = ''GEO''';
      execute immediate v_sql_stmt into v_level_id;

      -- zia 4/12/01 handle NO_DATA_FOUND exception
      exception
        when others then
          null;
    end;


    if (v_customer_id is NULL) and (v_location_id is NULL) then
      cus_state := 4; -- simply aggregate, not customer-specific
    elsif (v_location_id is NOT NULL) then
      if v_level_id = 11 then -- location level
        cus_state := 1; -- OK, loc-loc case
      else
        cus_state := -1; -- error
      end if;
    else -- i.e. customer is NOT NULL but location is NULL in f_desg
      if v_level_id = 11 then -- location level
        cus_state := 3; -- OK, loc-cus case
      elsif v_level_id = 15 then -- customer level
        cus_state := 2; -- cus-cus case
      else
        cus_state := -1; -- error
      end if;
    end if;

    if cus_state = -1 then
      errbuf:= errbuf || org_id || ' '; -- add to the list of bad orgs
    else -- everything is OK, go to the main part
      l_insert := 'INSERT ';
      l_select := 'SELECT ';
      l_from := 'FROM ';
      l_where := 'WHERE ';
      l_group_by := 'GROUP BY ';

      select level_pk
      into org_pk
      from msd_level_values
      where instance = p_instance_id
        and sr_level_pk = org_id
        and level_id = 7; -- level_id=7 - organization level

      -- Now create the dynamic query

      /* Find the round off decimal place for UOM conversion */
      OPEN c_round_off;
      FETCH c_round_off INTO l_round_off;
      CLOSE c_round_off;

      IF l_round_off is null THEN
         l_round_off := 6;
      END IF;

      l_insert := l_insert || 'INTO MSD_DP_SCN_ENTRIES_TEMP' ||
                  ' (inventory_item_id, forecast_designator, organization_id, ' ||
                  ' forecast_date, quantity, bucket_type, forecast_end_date) ';

      -- select
      l_select := l_select ||
        'sce.sr_product_lvl_pk, ' ||
        '''' || p_forecast_designator || ''', ' ||
        org_id || ', ' ||
        'sce.time_lvl_val_from, ' ||
        'ROUND(sum(sce.' || v_quant || ' *  decode(sce.PRODUCT_LVL_ID, 1, 1,' ||
                                           ' msd_common_utilities.msd_uom_convert(sce.sr_product_lvl_pk, ' ||
                                           '     null, sce.total_quantity_uom, lp.base_uom))),' ||
                                                 l_round_off || '), ' ||
        to_char(v_bucket_type) || ', ' ||
        'sce.time_lvl_val_to ' || ' ';

      -- from
      l_from := l_from ||
	' msd_dp_scenario_entries sce, ' ||
	' msd_item_list_price lp ';

      -- where
      l_where := l_where ||
	'sce.scenario_id = ' || to_char(p_scenario_id) || ' AND ' ||
	'sce.demand_plan_id = ' || to_char(p_demand_plan_id) || ' AND ' ||
	'sce.revision = ' || p_revision || ' AND ' ||
        'sce.'||v_quant|| '  is not NULL AND ' ||
        'lp.instance = sce.instance AND ' ||
        'lp.sr_item_pk = sce.sr_product_lvl_pk AND ' ||
        'sce.organization_lvl_pk = ' || org_pk || ' ';

      -- now - special treatment for various customer/location cases as stored in cus_state

      loc_pk := p_location_id;
      cus_pk := p_customer_id;

      if cus_state = 1 then
      -- state 1 means that both scenario_entries and f_desg/org_id are on the location level
        l_where := l_where || ' AND sce.geography_lvl_pk = ' || to_char(loc_pk) || ' ' ;
      elsif cus_state = 2 then
      -- state 1 means that both scenario_entries and f_desg/org_id are on the customer level
        l_where := l_where || ' AND sce.geography_lvl_pk = ' || to_char(cus_pk) || ' ' ;
      elsif cus_state = 3 then
      -- state 3 means that scenario_entries is on the location level while
      -- f_desg/org_id is on the customer level
      -- so we need to include all "child" locations on the f_desg/org_id's customer
        l_where := l_where || ' AND sce.geography_lvl_pk IN ('||
        'SELECT level_pk from msd_level_values_v where parent_level_pk = ' || to_char(cus_pk) || ') ';
      end if;
      -- state 4 means that forecast_designator/org_id is aggregate across all customers
      -- and therefore nothing should be added

      -- now, if p_level_id and p_value_id are not null, we need to add yet another filter
      if (p_level_id is not null) and (p_value_id is not null) then

        select dimension_code into dim
        from msd_levels
        where level_id = p_level_id;

        -- zia 4/12/01 handle case where this dimension is not in the plan
        begin

          SELECT mdsol.level_id into lvl
            FROM msd_dp_scenario_output_levels mdsol
           WHERE mdsol.demand_plan_id = p_demand_plan_id
             and mdsol.scenario_id = p_scenario_id
             and exists (select 1
                           from msd_levels mlv,
                                msd_dp_dimensions mdd
                          where mdd.demand_plan_id = p_demand_plan_id
                            and mdd.dimension_code = mlv.dimension_code
                            and mlv.level_id = mdsol.level_id
                            and mdd.dimension_code = dim);

          exception
            when others then
              null;
        end;
        -- zia 4/12/01/ end

        select min(hierarchy_id) into hier
        from
        (select hierarchy_id from msd_hierarchy_levels where level_id = p_level_id
        INTERSECT
         select hierarchy_id from msd_hierarchy_levels where level_id = lvl);

        lvl2 := p_level_id;
        qstr := '(' || to_char(p_value_id) || ')';

        while (lvl2 <> lvl) loop

          select level_id into lvl2
          from msd_hierarchy_levels
          where parent_level_id = lvl2
            and hierarchy_id = hier;

          open lpks for 'select level_pk from msd_level_values_v ' ||
            ' where level_id = ' || to_char(lvl2) || ' ' ||
            '   and parent_level_pk in ' || qstr;

          qstr := NULL;

          loop
            fetch lpks into n;
      	    exit when lpks%NOTFOUND;
            if qstr is NULL then
              qstr := '(' || to_char(n);
            else
              qstr := qstr || ',' || to_char(n);
            end if;
          end loop;

          if qstr is NULL then
            RAISE NO_DATA_FOUND;
          end if;

          qstr := qstr || ')';

        end loop;

      --  at this point qstr contains the list of "valid" level_pk's on the scenario_output_level (=== lvl)

        if dim = 'PRD' then
          l_where := l_where || ' AND sce.product_lvl_pk IN ' || qstr || ' ';
        elsif dim = 'GEO' then
          l_where := l_where || ' AND sce.geography_lvl_pk IN ' || qstr || ' ';
        elsif dim = 'CHN' then
          l_where := l_where || ' AND sce.saleschannel_lvl_pk IN ' || qstr || ' ';
        elsif dim = 'REP' then
          l_where := l_where || ' AND sce.sales_rep_lvl_pk IN ' || qstr || ' ';
        elsif dim = 'ORG' then
          l_where := l_where || ' AND sce.organization_lvl_pk IN ' || qstr || ' ';
        elsif dim = 'UD1' then
          l_where := l_where || ' AND sce.user_defined1_lvl_pk IN ' ||
                                 qstr || ' ';
        elsif dim = 'UD2' then
          l_where := l_where || ' AND sce.user_defined2_lvl_pk IN ' ||
                                 qstr || ' ';
        elsif dim = 'DCS' then
          l_where := l_where || ' AND sce.demand_class_lvl_pk IN ' || qstr || ' ';
        else
          null; -- we could raise an error here, but instead just ignore the filter
        end if;

      end if;

      -- group_by
      l_group_by := l_group_by || 'sce.sr_product_lvl_pk, sce.time_lvl_val_from, sce.time_lvl_val_to ';

      /* Clear Temp table before insertion */
      DELETE FROM MSD_DP_SCN_ENTRIES_TEMP;

      /* Insert Forecast into MSD_DP_SCN_ENTRIES_TEMP table first */
      v_sql_stmt := l_insert || l_select || l_from || l_where || l_group_by;
      EXECUTE IMMEDIATE v_sql_stmt;

      /* Clean up mrp_forecast_interface table before inserting new forecast */
      v_sql_stmt := ' DELETE FROM mrp_forecast_interface'|| v_dblink ||
                    ' WHERE forecast_designator = '||
                    '''' || p_forecast_designator || '''' ||
                    ' and organization_id = nvl(' || org_id ||', organization_id)';
      EXECUTE IMMEDIATE v_sql_stmt;

      /* Insert Forecast into MRP_FORECAST_INTERFACE table */
      -- insert
      v_sql_stmt := 'INSERT INTO mrp_forecast_interface' || v_dblink ||
                  ' (inventory_item_id, forecast_designator, organization_id, ' ||
                  ' forecast_date, quantity, process_status, confidence_percentage, ' ||
                  ' bucket_type, forecast_end_date, last_update_date, last_updated_by, ' ||
                  '  creation_date, created_by, workday_control) ' ||
                  ' SELECT inventory_item_id, forecast_designator, organization_id, ' ||
                  ' forecast_end_date, quantity, 2, 100, ' ||
                  ' bucket_type, forecast_end_date, SYSDATE, -1, SYSDATE, -1, ' ||
                    to_char(p_workday_control) || ' ' ||
                  ' FROM MSD_DP_SCN_ENTRIES_TEMP ';
      EXECUTE IMMEDIATE v_sql_stmt;

      /* Delete temp table after insert forecast into the source */
      DELETE FROM MSD_DP_SCN_ENTRIES_TEMP;

--    insert into dwk_test10 values(v_sql_stmt);

      commit;

    end if;

    END IF;  /* ( nvl(l_sr_org_lvl_pk, v_org_id.sr_level_pk) = v_org_id.sr_level_pk) */


    /* Add error handler in LOOP so that any error during loop will continue to
    the next org */
    EXCEPTION
        when others then
          null;
    END; /* End of 2 */


  END LOOP  /* End of 1 */;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;


--  return;

END;

END msd_fcst_pub;

/
