--------------------------------------------------------
--  DDL for Package Body MSD_ASCP_FLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_ASCP_FLOW" AS
/* $Header: msdxscpb.pls 120.2 2006/05/26 10:49:36 sjagathe noship $ */

 PROCEDURE LAUNCH_ASCP_PLAN
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out NOCOPY varchar2
  ) IS

  l_default_scenario_id number;
  l_default_plan_name varchar2(200);
  l_plan_id number;
  PlanID varchar2(200);
  g_owner varchar2(50) := null;
  l_dp_plan_id number;
  l_org_id number;
  l_instance_id number;
  l_scn_count number;
  l_sch_count number;
  l_attach_scn_count number;
  l_plan_launched varchar2(10);

  CURSOR c_plan_id (l_default_plan_name IN VARCHAR2) IS
  SELECT plan_id
  FROM msc_plans
  WHERE compile_designator = l_default_plan_name;

  CURSOR c_scn_count (l_dp_plan_id IN NUMBER, l_default_scenario_id IN NUMBER) IS
  SELECT count(*)
  FROM msd_dp_ascp_scenarios_v
  WHERE demand_plan_id = l_dp_plan_id
  AND scenario_id = l_default_scenario_id;

  CURSOR c_org_id (l_plan_id IN NUMBER) IS
  SELECT organization_id, sr_instance_id
  FROM msc_plan_organizations
  WHERE plan_id = l_plan_id;

  CURSOR c_sch_count (l_plan_id IN NUMBER,l_instance_id IN NUMBER, l_org_id IN NUMBER, l_default_scenario_iD IN NUMBER) IS
  SELECT count(*)
  FROM msc_plan_schedules
  WHERE plan_id = l_plan_id
  AND organization_id = l_org_id
  AND sr_instance_id = l_instance_id
  AND input_schedule_id = l_default_scenario_id
  AND designator_type = 7;

  CURSOR c_attach_scenario (l_plan_id IN NUMBER, l_dp_plan_id IN NUMBER) IS
  SELECT count(*)
  FROM msc_plan_schedules
  WHERE plan_id = l_plan_id
  AND input_schedule_id in ( SELECT scenario_id
                             FROM msd_dp_ascp_scenarios_v
                             WHERE demand_plan_id = l_dp_plan_id)
  AND designator_type = 7;


 BEGIN
  l_plan_launched :='N';
  resultout :='COMPLETE:Y';

  g_owner:=wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'DPADMIN');

  msd_wf.setowner(g_owner);

--  msd_wf.selector(null, null, null, 'TEST_CTX', resultout);

  /*  Get Demand Plan Id  */
  PlanID:=wf_engine.GetItemAttrText(Itemtype => ItemType,
                       Itemkey => ItemKey,
                       aname => 'ODPPLAN');

  l_dp_plan_id := to_number(PlanID);

  /* Bug# 5248221 Analyze tables MSD_DP_SCENARIO_ENTRIES, MSD_DP_SCENARIO_REVISIONS and
     MSD_DP_PLANNING_PERCENTAGES before populating the denorm tables
   */
  MSD_ANALYZE_TABLES.analyze_table('MSD_DP_SCENARIO_ENTRIES',null);
  MSD_ANALYZE_TABLES.analyze_table('MSD_DP_SCENARIO_REVISIONS',null);
  MSD_ANALYZE_TABLES.analyze_table('MSD_DP_PLANNING_PERCENTAGES',null);

  /* Populate denormalized msd_planning_percentage table and
     msd_dp_ascp_scn_entries tables */

  Populate_denorm_tables(l_dp_plan_id);




  /* Get Default ASCP Unconstrained Plan Name */
  l_default_plan_name := NULL;
  l_default_plan_name := FND_PROFILE.VALUE('MSC_DEFAULT_UNCONST_PLAN');

  IF l_default_plan_name is not null THEN

     l_plan_id := NULL;

     OPEN c_plan_id(l_default_plan_name);
     FETCH c_plan_id INTO l_plan_id;
     CLOSE c_plan_id;

     /* Get Default DP scenario Id */
     l_default_scenario_id := NULL;
     l_default_scenario_id := FND_PROFILE.VALUE('MSD_DEFAULT_DP_SCENARIO');

     IF l_default_scenario_id is not null THEN

        l_scn_count := 0;

        /* Check If default scenario has been defined in Demand Plan */
        OPEN c_scn_count(l_dp_plan_id, l_default_scenario_id);
        FETCH c_scn_count INTO l_scn_count;
        CLOSE c_scn_count;

        IF (l_scn_count > 0) then

          /* Get Organization Id, Instance Id for default ASCP unconstrained plan */
          OPEN c_org_id(l_plan_id);
          LOOP
             l_org_id := NULL;
             l_instance_id := NULL;

     	     FETCH c_org_id INTO l_org_id, l_instance_id;
             EXIT WHEN c_org_id%NOTFOUND;

             /*  Check if default scenario has been attached to ASCP Plan Schedules */
             l_sch_count := 0;

             OPEN c_sch_count(l_plan_id, l_instance_id, l_org_id, l_default_scenario_id);
             FETCH c_sch_count INTO l_sch_count;
             CLOSE c_sch_count;

             /* If default scenario is not attached to ASCP Plan Schedules, Attach the default scenario to ASCP plan */
             IF (l_sch_count = 0) then

                insert into msc_plan_schedules (
             	   PLAN_ID,
             	   ORGANIZATION_ID,
             	   INPUT_SCHEDULE_ID,
             	   SR_INSTANCE_ID,
             	   INPUT_TYPE,
             	   DESIGNATOR_TYPE,
             	   LAST_UPDATE_DATE,
             	   LAST_UPDATED_BY,
             	   CREATION_DATE,
             	   CREATED_BY )
                values (
                   l_plan_id,
                   l_org_id,
                   l_default_scenario_id,
                   l_instance_id,
                   1,
                   7,
                   sysdate,
                   FND_GLOBAL.USER_ID,
                   sysdate,
                   FND_GLOBAL.USER_ID );

             END IF;

          END LOOP;
     	  CLOSE c_org_id;

          COMMIT;

          fnd_file.put_line(fnd_file.log, 'Launching ASCP engine with default unconstrained plan');

          -- launch ASCP engine with default unconstrained plan
          MSC_X_CP_FLOW.Start_ASCP_Engine_WF ( p_constrained_plan_flag => 2 );

          l_plan_launched := 'Y';

       ELSE
          l_plan_launched := 'N';
       END IF;

    END IF;

    IF l_plan_launched = 'N' THEN

       OPEN c_attach_scenario(l_plan_id, l_dp_plan_id);
       FETCH c_attach_scenario INTO l_attach_scn_count;
       CLOSE c_attach_scenario;

       IF l_attach_scn_count > 0 then

          fnd_file.put_line(fnd_file.log, 'Launching ASCP engine with default unconstrained plan');

          -- launch ASCP engine with default unconstrained plan
          MSC_X_CP_FLOW.Start_ASCP_Engine_WF ( p_constrained_plan_flag => 2 );

       END IF;
    END IF;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, 'Errors in Launching ASCP Plan from DP');
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));

 END;

function get_priority(p_demand_plan_id in number,
                      p_scenario_id in number,
                      p_sr_instance_id in number,
                      p_bucket_type in number,
                      p_start_time in date,
                      p_end_time in date,
                      p_inventory_item_id in number,
                      p_demand_class in varchar2)
return number
is

l_priority number         :=to_number(NULL);
l_dmd_prty_scen_id number := -999;
l_sr_inventory_item_id   number;

begin


 select nvl(dmd_priority_scenario_id,-999) into l_dmd_prty_scen_id
 from msd_dp_scenarios
 where demand_plan_id = p_demand_plan_id
 and scenario_id = p_scenario_id;

 if (l_dmd_prty_scen_id = -999) then
      return l_priority;
 else

     select sr_inventory_item_id into l_sr_inventory_item_id
     from msc_apps_instances mai, msc_system_items msi
     where msi.plan_id = -1
     and  msi.sr_instance_id = p_sr_instance_id
     and  msi.organization_id = mai.validation_org_id
     and  msi.inventory_item_id = p_inventory_item_id
     and  mai.instance_id = p_sr_instance_id;

    begin

      select quantity into l_priority
      from msd_dp_scenario_entries
      where demand_plan_id = p_demand_plan_id
      and scenario_id = l_dmd_prty_scen_id
      and decode(time_lvl_id, 9, 1, 1, 2, 3) = p_bucket_type
      and time_lvl_val_from = p_start_time
      and TIME_LVL_VAL_TO = p_end_time
      and to_number(INSTANCE) = p_sr_instance_id
      and to_number(decode(ltrim(sr_product_lvl_pk, '.0123456789'), null, sr_product_lvl_pk, -1)) = l_sr_inventory_item_id
      and decode(demand_class_lvl_id,40, null,34, decode(demand_class,'-777', null,demand_class),demand_class) = p_demand_class
      and rownum < 2;

      return l_priority;

    exception
      when no_data_found then
        return l_priority;
      when others then
         return l_priority;
    end;


 end if;

exception
 when others then
      return l_priority;
end get_priority;



PROCEDURE populate_denorm_tables(p_demand_plan_id  number) IS

   /* Bug# 5248221 - Get the scenario ids which should
    *                be published to ASCP
    */
   CURSOR c_get_scenario_ids
   IS
      SELECT scenario_id
      FROM msd_dp_scenarios a
      WHERE
             a.demand_plan_id = p_demand_plan_id
         AND NOT EXISTS (SELECT 1
                            FROM msd_dp_scenarios b
                            WHERE
                                   b.demand_plan_id = a.demand_plan_id
                               AND b.dmd_priority_scenario_id = a.scenario_id);

   /* Bug# 5248221 - Get the demand priority scenario ids
    */
   CURSOR c_get_dmd_priority_scn_ids
   IS
      SELECT dmd_priority_scenario_id
         FROM msd_dp_scenarios
         WHERE
             demand_plan_id = p_demand_plan_id
         AND dmd_priority_scenario_id is not null;

   /* Bug# 5248221 - Variables to store the list of scenario ids
    */
   x_scenario_id_list         VARCHAR2(1000) := '';
   x_dmd_pri_scenario_id_list VARCHAR2(1000) := '';
   x_sql_stmt                 VARCHAR2(20000);

   x_first_time NUMBER := -1;

BEGIN

  /* Bug# 5248221 - Get the scenarios ids which should
   *                be published to ASCP
   */
  x_first_time := 1;
  FOR x_scenario_id_rec IN c_get_scenario_ids
  LOOP

     IF x_first_time = 1 THEN
        x_scenario_id_list := ' IN (' || x_scenario_id_rec.scenario_id;
        x_first_time := 0;
     ELSE
        x_scenario_id_list := x_scenario_id_list || ',' || x_scenario_id_rec.scenario_id;
     END IF;

  END LOOP;

  IF x_first_time = 0 THEN
     x_scenario_id_list := x_scenario_id_list || ')';
  ELSE
     x_scenario_id_list := ' IN (null)';
  END IF;

  /* Bug# 5248221 - Get the demand priority scenarios ids
   */
  x_first_time := 1;
  FOR x_dmd_priority_scn_id_rec IN c_get_dmd_priority_scn_ids
  LOOP

     IF x_first_time = 1 THEN
        x_dmd_pri_scenario_id_list := ' IN (' || x_dmd_priority_scn_id_rec.dmd_priority_scenario_id;
        x_first_time := 0;
     ELSE
        x_dmd_pri_scenario_id_list := x_dmd_pri_scenario_id_list || ',' || x_dmd_priority_scn_id_rec.dmd_priority_scenario_id;
     END IF;

  END LOOP;

  IF x_first_time = 0 THEN
     x_dmd_pri_scenario_id_list := x_dmd_pri_scenario_id_list || ')';
  ELSE
     x_dmd_pri_scenario_id_list := ' IN (null)';
  END IF;

  /* Bug# 5248221 */
  /* For Scenario Entries */
  x_sql_stmt := 'DELETE from msd_dp_scn_entries_denorm ' ||
                'WHERE demand_plan_id = ' || p_demand_plan_id  || ' ' ||
                'AND   scenario_id ' || x_scenario_id_list;

  EXECUTE IMMEDIATE x_sql_stmt;

   /* Bug# 5181742
    * Removed the function call MSD_ASCP_FLOW.get_priority
    */
   x_sql_stmt := 'INSERT INTO msd_dp_scn_entries_denorm(                          ' ||
                   'demand_plan_id,                                               ' ||
                   'scenario_id,                                                  ' ||
                   'demand_id,                                                    ' ||
                   'bucket_type,                                                  ' ||
                   'start_time,                                                   ' ||
                   'end_time,                                                     ' ||
                   'quantity,                                                     ' ||
                   'sr_organization_id,                                           ' ||
                   'sr_instance_id,                                               ' ||
                   'sr_inventory_item_id,                                         ' ||
                   'error_type,                                                   ' ||
                   'forecast_error,                                               ' ||
                   'inventory_item_id,                                            ' ||
                   'sr_ship_to_loc_id,                                            ' ||
                   'sr_customer_id,                                               ' ||
                   'sr_zone_id,                                                   ' ||
                   'priority,                                                     ' ||
                   'dp_uom_code,                                                  ' ||
                   'ascp_uom_code,                                                ' ||
                   'demand_class,                                                 ' ||
                   'unit_price,                                                   ' ||
                   'creation_date,                                                ' ||
                   'created_by,                                                   ' ||
                   'last_update_login )                                           ' ||
   'SELECT ' || p_demand_plan_id || ',                                            ' ||
         'fcst_sce.scenario_id,                                                   ' ||
         'fcst_sce.demand_id,                                                     ' ||
         'fcst_sce.bucket_type,                                                   ' ||
         'fcst_sce.start_time,                                                    ' ||
         'fcst_sce.end_time,                                                      ' ||
         'fcst_sce.quantity,                                                      ' ||
         'fcst_sce.sr_organization_id,                                            ' ||
         'fcst_sce.sr_instance_id,                                                ' ||
         'fcst_sce.sr_inventory_item_id,                                          ' ||
         'fcst_sce.error_type,                                                    ' ||
         'fcst_sce.forecast_error,                                                ' ||
         'fcst_sce.inventory_item_id,                                             ' ||
         'fcst_sce.sr_ship_to_loc_id,                                             ' ||
         'fcst_sce.sr_customer_id,                                                ' ||
         'fcst_sce.sr_zone_id,                                                    ' ||
         'dmpr_sce.quantity,                                                      ' ||
         'fcst_sce.dp_uom_code,                                                   ' ||
         'fcst_sce.ascp_uom_code,                                                 ' ||
         'decode (fcst_sce.demand_class,''-100'', null, fcst_sce.demand_class),   ' ||
         'fcst_sce.unit_price,                                                    ' ||
         '''' || sysdate || ''','                                                   ||
         FND_GLOBAL.USER_ID || ','                                                  ||
         FND_GLOBAL.LOGIN_ID || ' '                                                 ||
     'FROM                                                                        ' ||
     '(SELECT mdas.scenario_id SCENARIO_ID,                                       ' ||
             'mdas.demand_id DEMAND_ID,                                           ' ||
             'mdas.bucket_type BUCKET_TYPE,                                       ' ||
             'mdas.start_time START_TIME,                                         ' ||
             'mdas.end_time END_TIME,                                             ' ||
             'mdas.quantity QUANTITY,                                             ' ||
             'mdas.sr_organization_id SR_ORGANIZATION_ID,                         ' ||
             'mdas.sr_instance_id SR_INSTANCE_ID,                                 ' ||
             'mdas.sr_inventory_item_id SR_INVENTORY_ITEM_ID,                     ' ||
             'mdas.error_type ERROR_TYPE,                                         ' ||
             'mdas.forecast_error FORECAST_ERROR,                                 ' ||
             'mdas.inventory_item_id INVENTORY_ITEM_ID,                           ' ||
             'mdas.sr_ship_to_loc_id SR_SHIP_TO_LOC_ID,                           ' ||
             'mdas.sr_customer_id SR_CUSTOMER_ID,                                 ' ||
             'mdas.sr_zone_id SR_ZONE_ID,                                         ' ||
             'mdas.dp_uom_code DP_UOM_CODE,                                       ' ||
             'mdas.ascp_uom_code ASCP_UOM_CODE,                                   ' ||
             'nvl(mdas.demand_class,''-100'') DEMAND_CLASS,                       ' ||
             'mdas.unit_price UNIT_PRICE,                                         ' ||
             'mdas.dmd_priority_scenario_id DMD_PRIORITY_SCENARIO_ID,             ' ||
             'mdas.time_lvl_id TIME_LVL_ID                                        ' ||
         'FROM msd_dp_ascp_scn_entries_v mdas                                     ' ||
         'WHERE mdas.demand_plan_id = ' || p_demand_plan_id || ' '                  ||
         'AND   mdas.scenario_id ' || x_scenario_id_list || ') fcst_sce,          ' ||
     '(SELECT mdse.scenario_id SCENARIO_ID,                                       ' ||
             'mdse.time_lvl_id TIME_LVL_ID,                                       ' ||
             'mdse.time_lvl_val_from START_TIME,                                  ' ||
             'mdse.time_lvl_val_to END_TIME,                                      ' ||
             'max(mdse.quantity) QUANTITY,                                        ' ||
             'to_number(mdse.instance) SR_INSTANCE_ID,                            ' ||
             'to_number(decode(ltrim(sr_product_lvl_pk, ''.0123456789''),         ' ||
                              'null,                                              ' ||
                              'sr_product_lvl_pk,                                 ' ||
                              '-1)) SR_INVENTORY_ITEM_ID,                         ' ||
             'nvl(decode(mdse.demand_class_lvl_id,                                ' ||
                    '40,                                                          ' ||
                    'null,                                                        ' ||
                    '34,                                                          ' ||
                    'decode(mdse.demand_class,                                    ' ||
                           '''-777'',                                             ' ||
                           'null,                                                 ' ||
                           'mdse.demand_class),                                   ' ||
                    'mdse.demand_class),                                          ' ||
                    '''-100'') DEMAND_CLASS                                       ' ||
   	  'from msd_dp_scenarios mds,                                             ' ||
               'msd_dp_scenario_entries mdse                                      ' ||
         'WHERE mds.demand_plan_id = ' || p_demand_plan_id || ' '                   ||
         'AND   mds.scenario_id ' || x_dmd_pri_scenario_id_list                     ||
         'AND   mds.demand_plan_id = mdse.demand_plan_id                          ' ||
         'AND   mds.scenario_id = mdse.scenario_id                                ' ||
         'AND   mds.last_revision = mdse.revision                                 ' ||
         'GROUP BY mdse.scenario_id,                                              ' ||
	       'mdse.time_lvl_id,                                                 ' ||
      	       'mdse.time_lvl_val_from,                                           ' ||
      	       'mdse.time_lvl_val_to,                                             ' ||
      	       'mdse.instance,                                                    ' ||
      	       'mdse.SR_PRODUCT_LVL_PK,                                           ' ||
      	       'mdse.demand_class_lvl_id,                                         ' ||
      	       'mdse.demand_class) dmpr_sce                                       ' ||
     'WHERE fcst_sce.dmd_priority_scenario_id = dmpr_sce.scenario_id (+)          ' ||
     'AND   fcst_sce.time_lvl_id              = dmpr_sce.time_lvl_id (+)          ' ||
     'AND   fcst_sce.start_time               = dmpr_sce.start_time (+)           ' ||
     'AND   fcst_sce.end_time                 = dmpr_sce.end_time (+)             ' ||
     'AND   fcst_sce.sr_instance_id           = dmpr_sce.sr_instance_id (+)       ' ||
     'AND   fcst_sce.sr_inventory_item_id     = dmpr_sce.sr_inventory_item_id (+) ' ||
     'AND   fcst_sce.demand_class             = dmpr_sce.demand_class (+)         ';

  EXECUTE IMMEDIATE x_sql_stmt;


   /* For Planning Percentage */
  /* Bug# 5181742 */
  x_sql_stmt := 'DELETE from msd_dp_planning_pct_denorm ' ||
                'WHERE demand_plan_id = ' || p_demand_plan_id  || ' ' ||
                'AND   dp_scenario_id ' || x_scenario_id_list;

  EXECUTE IMMEDIATE x_sql_stmt;

   x_sql_stmt := 'INSERT INTO msd_dp_planning_pct_denorm(                  ' ||
                          'demand_plan_id             ,      ' ||
                          'dp_scenario_id             ,      ' ||
                          'component_sequence_id      ,      ' ||
                          'orig_component_sequence_id ,      ' ||
                          'bill_sequence_id           ,      ' ||
                          'sr_instance_id             ,      ' ||
                          'organization_id            ,      ' ||
                          'inventory_item_id          ,      ' ||
                          'assembly_item_id           ,      ' ||
                          'date_to                    ,      ' ||
                          'date_from                  ,      ' ||
                          'planning_factor            ,      ' ||
                          'plan_percentage_type       ,      ' ||
                          'creation_date              ,      ' ||
                          'created_by                 ,      ' ||
                          'last_update_login                 ' ||
                          ')                                 ' ||
   'SELECT                                                   ' ||
                          'demand_plan_id             ,      ' ||
                          'dp_scenario_id             ,      ' ||
                          'component_sequence_id      ,      ' ||
                          'orig_component_sequence_id ,      ' ||
                          'bill_sequence_id           ,      ' ||
                          'sr_instance_id             ,      ' ||
                          'organization_id            ,      ' ||
                          'inventory_item_id          ,      ' ||
                          'assembly_item_id           ,      ' ||
                          'date_to                    ,      ' ||
                          'date_from                  ,      ' ||
                          'planning_factor            ,      ' ||
                          'plan_percentage_type       ,      ' ||
                          '''' || sysdate || ''','             ||
                          FND_GLOBAL.USER_ID || ','            ||
                          FND_GLOBAL.LOGIN_ID                  ||
   ' FROM msd_dp_planning_percentages_v                      ' ||
   'WHERE demand_plan_id = ' || p_demand_plan_id || ' '        ||
   'AND   dp_scenario_id ' || x_scenario_id_list;

  EXECUTE IMMEDIATE x_sql_stmt;


  /* Bug# 5248221 Analyze tables MSD_DP_SCN_ENTRIES_DENORM and
     MSD_DP_PLANNING_PCT_DENORM after populating them to update statistics
   */
  commit;

  MSD_ANALYZE_TABLES.analyze_table('MSD_DP_SCN_ENTRIES_DENORM',null);
  MSD_ANALYZE_TABLES.analyze_table('MSD_DP_PLANNING_PCT_DENORM',null);


  EXCEPTION
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.log, 'Errors in populating denormalized tables');
      fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
      raise;

END populate_denorm_tables;


END MSD_ASCP_FLOW;

/
