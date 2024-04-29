--------------------------------------------------------
--  DDL for Package Body MSD_VALIDATE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_VALIDATE_DEMAND_PLAN" AS
/* $Header: msddpvlb.pls 120.15 2006/09/08 08:31:38 amitku noship $ */
    --
    -- Private procedures

    Procedure chk_required_dim 	(p_demand_plan_id in number);
    Procedure chk_usr_dim 	(p_demand_plan_id in number);
    Procedure chk_usd_dim 	(p_demand_plan_id in number);
    Procedure chk_dim_hier 	(p_demand_plan_id in number);
    Procedure chk_dim_lvl_val 	(p_demand_plan_id in number);
    Procedure chk_input_param 	(p_demand_plan_id in number);
    Procedure chk_fact_data 	(p_demand_plan_id in number);
    Procedure chk_scenarios 	(p_demand_plan_id in number,
                                 p_g_min_tim_lvl_id in number,
                                 p_m_min_tim_lvl_id in number,
                                 p_f_min_tim_lvl_id in number,
                                 p_c_min_tim_lvl_id in number);
    Procedure chk_time_data 	(p_demand_plan_id in number);
    Procedure chk_calendars     (p_demand_plan_id in number,
                                 p_calendar_type  in number,
                                 p_lowest_lvl_id  in varchar2);
    Procedure chk_min_time      (p_g_min_tim_lvl_id in number,
                                 p_m_min_tim_lvl_id in number,
                                 p_f_min_tim_lvl_id in number,
                                 p_c_min_tim_lvl_id in number);
    Procedure chk_uom_data 	(p_demand_plan_id in number);
    Procedure chk_curr_data 	(p_demand_plan_id in number);
    Procedure chk_output_levels (p_demand_plan_id in number);
    Procedure chk_dup_dim_output_levels (p_demand_plan_id in number);
    Procedure chk_ip_multiple	(p_parameter_type in varchar2,
			         p_multiple_flag  in varchar2,
			         p_parameter_name in varchar2);
    Procedure chk_ip_allo_agg	(p_parameter_type in varchar2,
			         p_parameter_name in varchar2,
			         p_demand_plan_id in number,
			         p_cs_def_id 	  in number,
    			         p_stream_id 	  in number);

    Procedure chk_scen_events	(p_demand_plan_id in number);
    Procedure chk_iv_org        (p_demand_plan_id in number,
                                 p_iv_flag        in varchar2,
                               p_stripe_stream_name in varchar2,
                               p_stripe_sr_level_pk in varchar2);

    Procedure chk_iso_org (p_demand_plan_id in number);

    Procedure update_plan	(p_demand_plan_id in number,
				 p_ret_code 	  in number);
    Procedure show_message	(p_text 	  in varchar2);
    Procedure debug_out (p_text in varchar2);

    --Added for multiple composites enhancements
    Procedure chk_composite_group_dimension (p_demand_plan_id     in number);
    Procedure chk_composite_group_level     (p_demand_plan_id     in number);
    Function  get_level_column_name         (p_dim_code           in varchar2,
                                             p_cs_id              in number)
                                             return Varchar2;

    Function  get_level_id                  (p_view_name          in varchar2,
                                             p_View_level_col     in varchar2,
                                             p_view_date_col      in varchar2,
                                             p_start_date         in date,
                                             p_end_date           in date,
                                             p_system_flag        in Varchar2,
                                             p_multi_stream_flag  in Varchar2,
                                             p_parameter_name     in Varchar2,
                                             p_cs_id              in Number,
                                             p_call_source        in Number,
                                             p_input_demand_plan_id        in Number,
                                             p_input_scenario_id        in Number)
                                             return Number;

    Procedure Lock_Row(p_demand_plan_id in number);

    function get_desig_clmn_name (p_cs_id in number) return VARCHAR2;

    --Added for multiple composites enhancements

    /* Bug# 5248868
     * This procedure validates that whether price list data exists
     * for the price lists specified in the demand plan.
     * Note: Only time range validation is done
     */
    PROCEDURE chk_price_list_data 	(p_demand_plan_id IN NUMBER);

    --
    --
    -- Constants
    --
    FATAL_ERROR Constant varchar2(30):='FATAL_ERROR';
    ERROR       Constant varchar2(30):='ERROR';
    WARNING     Constant varchar2(30):='WARNING';
    INFORMATION Constant varchar2(30):='INFORMATION';
    HEADING     Constant varchar2(30):='HEADING';
    SECTION     Constant varchar2(30):='SECTION';
    SUCCESS	    Constant varchar2(30):='SUCCESS';

    C_YES_FLAG   Constant  varchar2(30):= 'Y';

    l_debug     VARCHAR2(240) := NVL(fnd_profile.value('MRP_DEBUG'), 'N');

    --
    -- get demand plan record
    --

    CURSOR get_dp (p_demand_plan_id NUMBER) IS
    SELECT base_uom,
           demand_plan_id,
           demand_plan_name,
           enable_fcst_explosion,
           g_min_tim_lvl_id,
           f_min_tim_lvl_id,
           c_min_tim_lvl_id,
           m_min_tim_lvl_id,
           use_org_specific_bom_flag,
           stripe_sr_level_pk,
           stripe_stream_name
    FROM   msd_demand_plans
    WHERE  demand_plan_id = p_demand_plan_id;

    --
    -- check TIM and PRD dimensions are there
    --
    CURSOR get_dim (p_demand_plan_id 	NUMBER,
                    p_dp_dimension_code VARCHAR2,
                    p_dimension_code 	VARCHAR2) IS
    SELECT dimension_code
    FROM   msd_dp_dimensions_v
    WHERE  demand_plan_id    = p_demand_plan_id
    AND    dp_dimension_code = p_dp_dimension_code
    AND    dimension_code    = p_dimension_code;

    --
    -- check there are at least three user dimensions and not more than four.
    --
    CURSOR chk_user_dim (p_demand_plan_id number) IS
    SELECT COUNT(DISTINCT dp_dimension_code)
    FROM   msd_dp_dimensions_v
    WHERE  demand_plan_id = p_demand_plan_id;

    --
    -- check there is only one collapsed dimension.
    --
    CURSOR chk_coll_dim (p_demand_plan_id number) IS
    SELECT COUNT(1)
      FROM (
            SELECT dp_dimension_code, count(1)
              FROM   msd_dp_dimensions_v
             WHERE  demand_plan_id = p_demand_plan_id
          GROUP BY dp_dimension_code
            HAVING COUNT(1) > 1);

    --
    -- check all dimensions are used in the demand plan.
    --
    CURSOR chk_used_dim (p_demand_plan_id number) IS
    SELECT DISTINCT dp_dimension_code
    FROM   msd_dp_dimensions_v mddv
    WHERE  demand_plan_id = p_demand_plan_id
    and not exists (
    select 1
    from msd_cs_definitions mcd, msd_cs_defn_dim_dtls mcdd, msd_dp_parameters mdp
    where mcd.cs_definition_id = mcdd.cs_definition_id
    and mdp.parameter_type = mcd.name
    and mdp.demand_plan_id = p_demand_plan_id
    and mcdd.dimension_code = mddv.dp_dimension_code
    and mcdd.collect_flag = C_YES_FLAG);

    --
    -- find user dimensions that don't have hierarchies or have invald hierarchies
    --
    CURSOR get_usr_dim_with_no_hier (p_demand_plan_id in number) IS
    SELECT DISTINCT dp_dimension dp_dimension
    FROM   msd_dp_dimensions_v pd
    WHERE  demand_plan_id = p_demand_plan_id
    AND    dp_dimension_code <> 'TIM'
    AND    NOT EXISTS
           (SELECT hierarchy_id
            FROM   msd_dp_hierarchies_v dh
            WHERE  pd.demand_plan_id 	= dh.demand_plan_id
            AND    pd.dp_dimension_code = dh.dp_dimension_code);
    --
    -- find dimensions that don't have hierarchies or have invalid hierarchies
    --
    CURSOR  get_dim_with_no_hier (p_demand_plan_id IN NUMBER) IS
    SELECT  DISTINCT dimension dimension_code
    FROM    msd_dp_dimensions_v pd
    WHERE   demand_plan_id = p_demand_plan_id
    AND     dp_dimension_code <> 'TIM'
    AND     NOT EXISTS
            (select hierarchy_id
             from   msd_dp_hierarchies_v dh
             where  pd.demand_plan_id = dh.demand_plan_id
             and    pd.dimension_code = dh.owning_dimension_code);


    -- Find dimension that exist as dp_dimension code but not as dimension.
    CURSOR  get_hier_collaps (p_demand_plan_id NUMBER) IS
    SELECT  DISTINCT dp_dimension
    FROM    msd_dp_dimensions_v dd1
    WHERE   demand_plan_id = p_demand_plan_id
    AND	    NOT EXISTS
            (select 	1
             from 	msd_dp_dimensions_v dd2
             where 	dd2.demand_plan_id    = p_demand_plan_id
	     and	dd1.dp_dimension_code = dd2.dimension_code
	     and	dd1.dp_dimension_code = dd2.dp_dimension_code
            );
    -- Find invalid hierarchies in the plan
    cursor get_inval_hier (p_demand_plan_id number) is
    select
        dh.hierarchy_name,
        hi.dimension_code
    from
        msd_dp_hierarchies_v dh,
        msd_hierarchies hi
    where
        dh.hierarchy_id = hi.hierarchy_id and
        dh.demand_plan_id = p_demand_plan_id and
        hi.valid_flag <> '1';
    --
    -- Find demand plan dimension, except time,  that don't have level values
    --
    CURSOR get_dim_no_lvl( p_demand_plan_id NUMBER) IS
    SELECT  DISTINCT dp_dimension_code,
            hl. hierarchy_name,
            level_name
    FROM    msd_dp_hierarchies_v dh,
            msd_hierarchy_levels_v hl
    WHERE   demand_plan_id = p_demand_plan_id
    AND	    dp_dimension_code <> 'TIM'
    AND     dh.hierarchy_id = hl.hierarchy_id
    AND     level_id NOT IN
	        (select distinct level_id
        	 from   msd_level_values lv);

    --
    -- Validate Time dimensions has values
    --
    CURSOR get_tim(p_calendar_type VARCHAR2, p_calendar_code VARCHAR2,
                   p_start_date DATE, p_end_date DATE) IS
    SELECT MIN(day) min_date, MAX(day) max_date
      FROM msd_time dp
     WHERE dp.calendar_type = p_calendar_type
       AND dp.calendar_code = p_calendar_code
       AND day between p_start_date and p_end_date;

    --
    -- Validate all Demand Plan Calendars
    --
    CURSOR get_dp_cal(p_demand_plan_id NUMBER) IS
    SELECT calendar_type, calendar_code, decode(calendar_type,
                                                1, initcap(calendar_code),
                                                calendar_code) op_cal_code
      FROM msd_dp_calendars
     WHERE demand_plan_id = p_demand_plan_id;

    --
    -- Validate input parameters
    --
    CURSOR get_dupl_input_parameter (p_demand_plan_id NUMBER) IS
    SELECT parameter_type,
	   parameter_name,
           forecast_date_used,
           count(*)
    FROM   msd_dp_parameters_cs_v
    WHERE  demand_plan_id = p_demand_plan_id
    AND    parameter_type_id <> '7'
    GROUP BY 	parameter_type,
		parameter_name,
		forecast_date_used
    HAVING COUNT(*) > 1;
    --
    -- Find all the scenarios
    --
    CURSOR get_scen (p_demand_plan_id NUMBER) IS
    SELECT mds.scenario_id,
	   mds.forecast_based_on,
	   mds.parameter_name,
	   mds.scenario_name,
	   mds.history_start_date,
	   mds.history_end_date,
	   mds.horizon_start_date,
	   mds.horizon_end_date,
	   mds.publish_flag,
	   mds.output_period_type,
           csd.cs_definition_id,
           csd.system_flag,
	   csd.multiple_stream_flag,
           csd.allocation_allowed_flag,
           csd.lowest_level_flag,
           mdp.input_demand_plan_id,
           mdp.input_scenario_id,
	   mdp.forecast_date_used,
           mdp.start_date prm_start_date,
           mdp.end_date prm_end_date,
           nvl(mdp.view_name, nvl(csd.planning_server_view_name,'MSD_CS_DATA_V')) view_name,
           msd_cs_dfn_utl.get_planning_server_clmn(csd.cs_definition_id, mdp.FORECAST_DATE_USED) date_planning_view_clmn,
       cdd.collect_level_id
    FROM   msd_dp_scenarios mds,
           msd_dp_parameters mdp,
           msd_cs_definitions csd,
           msd_cs_defn_dim_dtls cdd
   WHERE  mds.demand_plan_id = p_demand_plan_id
     AND  mds.enable_flag = 'Y'
     AND  mdp.demand_plan_id (+) = mds.demand_plan_id
     AND  mdp.parameter_type (+) = mds.forecast_based_on
     AND  mdp.forecast_date_used (+) = mds.forecast_date_used
     AND  nvl(mdp.parameter_name, '-*()')  = nvl(mds.parameter_name, '-*()')
     AND  csd.name (+) = mdp.parameter_type
     AND  cdd.cs_definition_id (+) = csd.cs_definition_id
     AND  cdd.dimension_code (+) = 'TIM'
     and  cdd.collect_flag (+) = 'Y';

    --
    -- get output levels w/Org Specific BOM
    --
    CURSOR get_output_levels_org( p_demand_plan_id NUMBER, p_scenario_id NUMBER) IS
    select count( distinct decode(mlv.level_id, 3, 1, mlv.level_id))
      from msd_levels mlv,
           msd_dp_scenario_output_levels mdsol,
	   msd_demand_plans mdp
     where mdsol.demand_plan_id = p_demand_plan_id
       and mdsol.demand_plan_id = mdp.demand_plan_id
       and nvl(mlv.plan_type,'DP') = decode(mdp.plan_type,'SOP','DP','','DP',mdp.plan_type)
       and mlv.level_id = mdsol.level_id
       and mdsol.scenario_id = p_scenario_id
       and mlv.level_id in (7, 1, 3);

    --
    -- get output levels w/out Org Specific BOM
    --
    CURSOR get_output_levels( p_demand_plan_id NUMBER, p_scenario_id NUMBER) IS
    select count( distinct decode(mlv.level_id, 3, 1, mlv.level_id))
      from msd_levels mlv,
           msd_dp_scenario_output_levels mdsol,
	   msd_demand_plans mdp
     where mdsol.demand_plan_id = p_demand_plan_id
       and mdsol.demand_plan_id = mdp.demand_plan_id
       and nvl(mlv.plan_type,'DP') = decode(mdp.plan_type,'SOP','DP','','DP',mdp.plan_type)
       and mlv.level_id = mdsol.level_id
       and mdsol.scenario_id = p_scenario_id
       and mlv.level_id in (1, 3);

    --
    -- get invalid output parameters. do not check for top level values.
    --
    CURSOR get_inv_output_levels ( p_demand_plan_id IN NUMBER) IS
    SELECT scen.scenario_name,
	   ml.level_name,
           ml.dimension_code
    FROM   msd_dp_scenario_output_levels a, msd_levels ml, msd_dp_scenarios scen, msd_demand_plans mdp
    WHERE  a.demand_plan_id = p_demand_plan_id
    and    a.demand_plan_id = mdp.demand_plan_id
    and    nvl(ml.plan_type,'DP') = decode(mdp.plan_type,'SOP','DP','','DP',mdp.plan_type)
    AND    a.level_id = ml.level_id
    AND    a.scenario_id = scen.scenario_id
    AND    scen.enable_flag = 'Y'
    AND    a.level_id not in
           ( select b.level_id
             from   msd_hierarchy_levels b,
              	    msd_dp_hierarchies_v c
             where  b.hierarchy_id = c.hierarchy_id
             and    c.demand_plan_id = p_demand_plan_id
	     union
             select b.parent_level_id
             from   msd_hierarchy_levels b,
              	    msd_dp_hierarchies_v c
             where  b.hierarchy_id = c.hierarchy_id
             and    c.demand_plan_id = p_demand_plan_id
	   );



    --
    -- get duplicate dimensions in output parameters.
    --
    CURSOR get_dup_dim_output_levels ( p_demand_plan_id IN NUMBER) IS
    SELECT scen.scenario_name,ml.dimension_code, count(*)
    FROM   msd_dp_scenario_output_levels a, msd_levels ml, msd_dp_scenarios scen, msd_demand_plans mdp
    WHERE  a.level_id = ml.level_id
    and    a.demand_plan_id = mdp.demand_plan_id
    and    nvl(ml.plan_type,'DP') = decode(mdp.plan_type,'SOP','DP','','DP',mdp.plan_type)
    AND    a.scenario_id = scen.scenario_id
    AND    scen.enable_flag = 'Y'
	and scen.demand_plan_id = p_demand_plan_id
	group by scen.scenario_name,ml.dimension_code
	having count(*) >1 ;




    --
    -- get associated input parameter
    --
    CURSOR get_input_param(p_demand_plan_id NUMBER,
			   p_parameter_type VARCHAR2,
			   p_cs_name VARCHAR2,
			   p_date_used in VARCHAR2) IS
    SELECT start_date, end_date
    FROM   msd_dp_parameters
    WHERE  demand_plan_id = p_demand_plan_id
    AND    parameter_type = p_parameter_type
    AND    (((parameter_name IS NULL) AND (p_cs_name IS NULL))
	    OR
	    ((parameter_name IS NOT NULL) AND (p_cs_name IS NOT NULL)
              AND (parameter_name = p_cs_name)))
    AND    (((forecast_date_used is NULL) and (p_date_used IS NULL))
	    OR
	    ((forecast_date_used IS NOT NULL) AND (p_date_used IS NOT NULL)
	      AND (forecast_date_used = p_date_used)))
    AND    parameter_type <> '7';
    --
    -- get invalid input parameters. these parameters do not have
    -- hierarchies which contain levels in the stream definition.
    --
    /* Modified by DWK. for date_clmn: In case of Input scenario which does not
       have any forecast_date_used column specified,  Use 'END_DATE' intead. */
    CURSOR get_inv_hier_prms (p_demand_plan_id IN NUMBER) IS
    SELECT DISTINCT mcd.description,
                    mcdd.dimension_code,
                    mcdd.collect_level_id level_id,
                    mcd.cs_definition_id,
                    mcd.multiple_stream_flag,
                    nvl(mcd.planning_server_view_name,'MSD_CS_DATA_V') planning_server_view_name,
                    mdp.parameter_name,
                    mdp.start_date,
                    mdp.end_date,
                    mcd.system_flag,
                    MSD_CS_DFN_UTL.get_planning_server_clmn(mcd.cs_definition_id, nvl(mdp.FORECAST_DATE_USED, 'END_DATE')) date_clmn,
                    mdp.input_demand_plan_id,
                    mdp.input_scenario_id,
                    mdp.revision
    FROM   msd_cs_defn_dim_dtls mcdd,
           msd_dp_parameters mdp,
           msd_cs_definitions mcd,
           msd_dp_dimensions_v mdd
    WHERE  mdp.demand_plan_id = p_demand_plan_id
    AND    mdd.demand_plan_id = p_demand_plan_id
    AND    mdd.dimension_code = mcdd.dimension_code
    AND    mcdd.cs_definition_id = mcd.cs_definition_id
    AND    mcd.name = mdp.parameter_type
    AND    nvl(mcdd.collect_level_id, 0) not in
           ( select b.level_id
             from   msd_hierarchy_levels b,
              	    msd_dp_hierarchies_v c
             where  b.hierarchy_id = c.hierarchy_id
             and    c.demand_plan_id = p_demand_plan_id
             and    mcdd.dimension_code <> 'TIM'
	         union
             select b.parent_level_id
             from   msd_hierarchy_levels b,
              	    msd_dp_hierarchies_v c
             where  b.hierarchy_id = c.hierarchy_id
             and    c.demand_plan_id = p_demand_plan_id
             and    mcdd.dimension_code <> 'TIM'
	    );

     -- Determine whether level is contain in Dp Hierarchies.
     CURSOR get_inv_hier_lvl_prms (p_demand_plan_id IN NUMBER, p_lvl_id in NUMBER) is
             select 1
             from   msd_hierarchy_levels b,
              	    msd_dp_hierarchies_v c
             where  b.hierarchy_id = c.hierarchy_id
             and    c.demand_plan_id = p_demand_plan_id
             and    (b.level_id = p_lvl_id
                     or
                     b.parent_level_id = p_lvl_id);

     -- Get Invalid Time Hierarchy Params
     CURSOR get_inv_hier_tim_prms (p_demand_plan_id IN NUMBER, p_lvl_id in NUMBER) IS
     select meaning
       from fnd_lookup_values_vl
      where lookup_type = 'MSD_PERIOD_TYPE'
        and lookup_code = p_lvl_id
        and not exists (
                 select 1
                  from msd_dp_calendars
                 where demand_plan_id = p_demand_plan_id
                   and calendar_type =  decode(p_lvl_id,
                             1,2,2,2,3,3,4,3,5,3,6,1,7,1,8,1,10,4,11,4,12,4,13,4,calendar_type));


    --
    -- UOM Conversions
    --
    CURSOR uom_conv (p_base_uom VARCHAR2) IS
    SELECT 1
    FROM   msd_uom_conversions
    WHERE  (from_uom_code = p_base_uom OR to_uom_code = p_base_uom)
    AND    ROWNUM < 2;
    --
    -- Currency Conversion
    --
    CURSOR curr_conv (p_curr VARCHAR2, p_from_date IN DATE, p_to_date IN DATE) IS
    SELECT 1
    FROM   msd_currency_conversions
    WHERE  from_currency = NVL(p_curr, from_currency)
    AND    conversion_date BETWEEN p_from_date AND p_to_date
    AND    ROWNUM < 2;

    /* Retrieves all Parameters within a Demand Plan Definition. */
    CURSOR get_all_input_param (p_demand_plan_id IN NUMBER) IS
    SELECT mdp.demand_plan_id,
           mdp.parameter_id,
           mdp.cs_definition_id,
	   mdp.system_flag,		/* Add to view */
	   mdp.cs_type,
	   mdp.parameter_type_id,
	   mdp.parameter_type,
	   mdp.parameter_name,
	   mdp.multiple_stream_flag,
	   mdp.forecast_date_used,
	   mdp.date_planning_view_clmn,
	   mdp.start_date,
	   mdp.end_date,
	   mdp.view_name,
	   mdp.input_demand_plan_id,
	   mdp.input_scenario_id,
	   mdp.revision,
	   mdp.allo_agg_basis_stream_id
   FROM    msd_dp_parameters_cs_v mdp
   WHERE   mdp.demand_plan_id = p_demand_plan_id
   AND	   mdp.parameter_type_id <> '7';

   CURSOR get_ps_view_name (p_cs_def_id NUMBER, p_demand_plan_id number) IS
   SELECT decode(stripe_stream_name,
                 null, decode(stripe_sr_level_pk,
                              null,
                              nvl(planning_server_view_name,'MSD_CS_DATA_V'),
                              planning_server_view_name_ds),
                 planning_server_view_name_ds),
          planning_server_view_name
   FROM   msd_cs_definitions_vl,
          msd_demand_plans mdp
   WHERE  cs_definition_id = p_cs_def_id
      and mdp.demand_plan_id = p_demand_plan_id;

   CURSOR param_cs_wgt (p_cs_def_id NUMBER) IS
   SELECT count(1)
     FROM msd_cs_defn_column_dtls a
    WHERE a.cs_definition_id = p_cs_def_id
      AND ((a.allocation_type IN ('AVG', 'WGT'))
 	  OR (a.aggregation_type = 'WGT')
          OR  exists (select 1
                        from msd_cs_clmn_dim_dtls b
                       where a.cs_column_dtls_id = b.cs_column_dtls_id
                         and ((b.allocation_type IN ('AVG', 'WGT'))
                              OR (b.aggregation_type = 'WGT'))));


   CURSOR get_one_param (p_demand_plan_id IN NUMBER, p_parameter_type IN VARCHAR2) IS
   SELECT cs_definition_id
   FROM   msd_dp_parameters_cs_v
   WHERE  demand_plan_id = p_demand_plan_id
   AND    parameter_type = p_parameter_type
   AND    parameter_type <> '7';

    --Added for multiple composites enhancements
    --
    -- check composite group has the same dimension
    --
    CURSOR chk_comp_group(p_demand_plan_id NUMBER) IS
    SELECT DISTINCT DEF2.DESCRIPTION DESCRIPTION,
                    DEF2.COMPOSITE_GROUP_CODE COMPOSITE_GROUP_CODE
              FROM MSD_CS_DEFINITIONS DEF1,
                   MSD_CS_DEFINITIONS DEF2,
                   MSD_CS_DEFN_DIM_DTLS DIM1,
                   MSD_CS_DEFN_DIM_DTLS DIM2,
                   MSD_DP_PARAMETERS MPV1,
                   MSD_DP_PARAMETERS MPV2
             WHERE MPV1.DEMAND_PLAN_ID = p_demand_plan_id
               AND DEF1.name = MPV1.parameter_type
               AND DEF1.COMPOSITE_GROUP_CODE IS NOT NULL
               AND NVL(DEF1.ENABLE_FLAG,'Y') = 'Y'
               AND DIM1.CS_DEFINITION_ID = DEF1.CS_DEFINITION_ID
               AND NVL(DEF2.ENABLE_FLAG,'Y') = 'Y'
               AND NVL(DEF2.COMPOSITE_GROUP_CODE,-9999) = NVL(DEF1.COMPOSITE_GROUP_CODE,-9998)
               AND DIM2.CS_DEFINITION_ID = DEF2.CS_DEFINITION_ID
               AND DIM2.DIMENSION_CODE = DIM1.DIMENSION_CODE
               AND DIM2.COLLECT_FLAG <> DIM1.COLLECT_FLAG
               AND MPV2.DEMAND_PLAN_ID = p_demand_plan_id
               AND MPV2.parameter_type <> MPV1.parameter_type
               AND MPV2.parameter_type = DEF2.name;

    --
    -- check composite group has the same level
    --
    CURSOR chk_comp_group_lvl(p_demand_plan_id NUMBER) IS
    SELECT DEF1.DESCRIPTION DESCRIPTION1,
       DEF2.DESCRIPTION DESCRIPTION2,
       DEF2.NAME NAME2,
       DEF1.NAME NAME1,
       DEF2.COMPOSITE_GROUP_CODE COMPOSITE_GROUP_CODE,
       NVL(DIM1.COLLECT_LEVEL_ID,-1234) LEVEL_ID1,
       NVL(DIM2.COLLECT_LEVEL_ID,-9999) LEVEL_ID2,
       DIM1.DIMENSION_CODE DIM1_CODE,
       DIM2.DIMENSION_CODE DIM2_CODE,
       DEF1.CS_DEFINITION_ID CS_ID1,
       DEF2.CS_DEFINITION_ID CS_ID2,
       nvl(DEF1.PLANNING_SERVER_VIEW_NAME,'MSD_CS_DATA_V') VIEW_NAME1,
       nvl(DEF2.PLANNING_SERVER_VIEW_NAME,'MSD_CS_DATA_V') VIEW_NAME2,
       MPV1.START_DATE START_DATE1,
       MPV1.END_DATE END_DATE1,
       MPV2.START_DATE START_DATE2,
       MPV2.END_DATE END_DATE2,
       MPV1.INPUT_DEMAND_PLAN_ID INPUT_DEMAND_PLAN_ID1,
       MPV2.INPUT_DEMAND_PLAN_ID INPUT_DEMAND_PLAN_ID2,
       MPV1.INPUT_SCENARIO_ID INPUT_SCENARIO_ID1,
       MPV2.INPUT_SCENARIO_ID INPUT_SCENARIO_ID2,
       DECODE(DEF1.NAME,'MSD_INPUT_SCENARIO',MPV1.REVISION,MPV1.PARAMETER_NAME) PARAM1,
       DECODE(DEF2.NAME,'MSD_INPUT_SCENARIO',MPV2.REVISION,MPV2.PARAMETER_NAME) PARAM2,
       DECODE(DEF1.NAME,'MSD_INPUT_SCENARIO','TIME_LVL_VAL_FROM',MSD_CS_DFN_UTL.get_planning_server_clmn(def1.cs_definition_id, mpv1.FORECAST_DATE_USED)) DATE_CLMN1,
       DECODE(DEF2.NAME,'MSD_INPUT_SCENARIO','TIME_LVL_VAL_FROM',MSD_CS_DFN_UTL.get_planning_server_clmn(def2.cs_definition_id, mpv2.FORECAST_DATE_USED)) DATE_CLMN2,
       DEF1.SYSTEM_FLAG SYSTEM_FLAG1,
       DEF2.SYSTEM_FLAG SYSTEM_FLAG2,
       DEF1.MULTIPLE_STREAM_FLAG MULTI_STREAM_FLAG1,
       DEF2.MULTIPLE_STREAM_FLAG MULTI_STREAM_FLAG2
  FROM MSD_CS_DEFINITIONS DEF1,
       MSD_CS_DEFINITIONS DEF2,
       MSD_CS_DEFN_DIM_DTLS DIM1,
       MSD_CS_DEFN_DIM_DTLS DIM2,
       MSD_DP_PARAMETERS MPV1,
       MSD_DP_PARAMETERS MPV2
 WHERE MPV1.DEMAND_PLAN_ID = p_demand_plan_id
   AND DEF1.name = MPV1.parameter_type
   AND NVL(DEF1.ENABLE_FLAG,'Y') = 'Y'
   --AND NVL(DEF1.LOWEST_LEVEL_FLAG,1) = 0
   AND DIM1.CS_DEFINITION_ID = DEF1.CS_DEFINITION_ID
   AND DIM1.COLLECT_FLAG = 'Y'
   AND NVL(DEF2.ENABLE_FLAG,'Y') = 'Y'
   --AND NVL(DEF2.LOWEST_LEVEL_FLAG,1) = 0
   AND NVL(DEF2.COMPOSITE_GROUP_CODE,-9999) = NVL(DEF1.COMPOSITE_GROUP_CODE,-1234)
   AND DIM2.CS_DEFINITION_ID = DEF2.CS_DEFINITION_ID
   AND DIM2.DIMENSION_CODE = DIM1.DIMENSION_CODE
   AND DIM2.COLLECT_FLAG = 'Y'    		-- Bug# 4562757
   AND NVL(DIM2.COLLECT_LEVEL_ID,-9999) <> NVL(DIM1.COLLECT_LEVEL_ID,-1234)
   AND MPV2.DEMAND_PLAN_ID = p_demand_plan_id
   AND MPV2.parameter_type <> MPV1.parameter_type
   AND MPV2.parameter_type = DEF2.name
   ORDER BY NAME2;

    --
    -- Derives the level_id column name in the planning server view for a given
    -- Dimension and stream
    --
    CURSOR get_lvl_column_name(p_dim_code Varchar2,p_cs_id NUMBER) IS
    SELECT decode(planning_view_column_name,'TIM_LEVEL_ID','TIME_LEVEL_ID',
                  planning_view_column_name)
    FROM   msd_cs_defn_column_dtls_v
    WHERE  column_identifier  = upper(p_dim_code)||'_LEVEL_ID'
    AND    identifier_type    = 'DIMENSION_ID'
    AND    cs_definition_id   = p_cs_id;

    --Added for multiple composites enhancements

    /*
     * Variables
     */
    dummy           varchar2(80);
    l_cnt           number;
    l_dp_max_date   date;
    l_dp_min_date   date;
    l_a_date        date;
    l_b_date        date;
    l_dp_rec        get_dp%rowtype;
    l_min_date      date;
    l_max_date      date;
    l_result        varchar2(30);
    g_ret_code      number;
    --
    -- USED BY DISPLAY_MESSAGE
    --
    l_last_msg_type varchar2(30);
    --
    -- Define Exception
    --
    EX_FATAL_ERROR Exception;
    --
    -- Private functions/proceudres
    --
    --
    -- Store result
    --
    Procedure calc_result ( p_msg_type in varchar2) is
    Begin
        if p_msg_type = FATAL_ERROR then
            g_ret_code := 4;
            l_result := FATAL_ERROR;
        elsif p_msg_type = ERROR then
            g_ret_code := 2;
            l_result   := p_msg_type;
        elsif p_msg_type = WARNING then
            if g_ret_code <> 2 then
                g_ret_code := 1;
                l_result := p_msg_type;
            end if;
        end if;
    End;
    --
    Procedure show_message(p_text in varchar2) is

    Begin

	if (p_text is not NULL) then
    		fnd_file.put_line(fnd_file.log, p_text);
		-- dbms_output.put_line(p_text);
  	end if;

 --
    end;

    Procedure debug_out(p_text in varchar2) is
    i number := 1;
    Begin
      while i<= length(p_text) loop
        fnd_file.put_line(fnd_file.output, substr(p_text, i, 90));
--        dbms_output.put_line(substr(p_text, i, 90));
	i := i+90;
      end loop;
    end;
    --

    Procedure display_message(p_text varchar2, msg_type varchar2 default null) is
        l_tab           varchar2(4):='    ';
        L_MAX_LENGTH    number:=90;
    Begin
        if msg_type = SECTION then
            if nvl(l_last_msg_type, 'xx') <> SECTION then
                show_message('');
            end if;
            --
            show_message( substr(p_text, 1, L_MAX_LENGTH) );
            --
        elsif msg_type in (INFORMATION, HEADING) then
            show_message( l_tab || substr(p_text, 1, L_MAX_LENGTH));
        else
            show_message( l_tab || rpad(p_text, L_MAX_LENGTH) || ' ' || msg_type );
        end if;
        --
        if msg_type in (ERROR, WARNING, FATAL_ERROR) then
            calc_result (msg_type);
        end if;
        --
        if msg_type = FATAL_ERROR then
            show_message(' ');
            show_message( l_tab || 'Exiting Demand Plan validation process with FATAL ERROR');
            raise   EX_FATAL_ERROR;
        end if;
        --
        l_last_msg_type := msg_type;
    End;
    --
    Procedure Blank_Line is
    Begin
        fnd_file.put_line(fnd_file.log, '');
--        dbms_output.put_line('');
    End;
    --
PROCEDURE CHK_CAL_FOR_BUCKET (p_date           IN DATE,
                              p_demand_plan_id IN NUMBER,
                              p_field_name     IN VARCHAR2) IS
CURSOR C1 IS
SELECT count(1)
  FROM msd_time mtv, msd_dp_calendars mdc
 WHERE mtv.day = p_date
   AND rownum = 1
   AND mtv.calendar_type = mdc.calendar_type
   AND mtv.calendar_code = mdc.calendar_code
   AND mdc.demand_plan_id = p_demand_plan_id;


num_buckets number := 0;

BEGIN

open c1;
fetch c1 into num_buckets;

if num_buckets = 0 then
  display_message(p_field_name || 'not in any calendars',  WARNING);
end if;

close c1;

END CHK_CAL_FOR_BUCKET;

Function func_output_level_string (p_demand_plan_id in number,
                                   p_scenario_id in number)
Return varchar2 is

cursor c1(p_demand_plan_id number,p_scenario_id number)  is
select
--scen.scenario_name,
dim1||decode(dim2,NULL,'',','||dim2)||decode(dim3,NULL,'',','||dim3)||decode(dim4,NULL,'',','||dim4)||decode(dim5,NULL,'',','||dim5)||decode(dim6,NULL,'',','||dim6)||decode(dim7,NULL,'',','||dim7)||decode(dim8,NULL,'',','||dim8)
from (
select demand_plan_id,scenario_id,level_id as dim1,
LEAD(level_id,1) over (partition by scenario_id order by level_id) as dim2,
LEAD(level_id,2) over (partition by scenario_id order by level_id) as dim3,
LEAD(level_id,3) over (partition by scenario_id order by level_id) as dim4,
LEAD(level_id,4) over (partition by scenario_id order by level_id) as dim5,
LEAD(level_id,5) over (partition by scenario_id order by level_id) as dim6,
LEAD(level_id,6) over (partition by scenario_id order by level_id) as dim7,
LEAD(level_id,7) over (partition by scenario_id order by level_id) as dim8,
row_number() over (partition by scenario_id order by level_id) as rno
from msd_dp_scenario_output_levels
) a,
msd_dp_scenarios scen
where a.rno=1
and a.scenario_id = scen.scenario_id
and a.demand_plan_id = scen.demand_plan_id
and scen.demand_plan_id = p_demand_plan_id
and scen.scenario_id =    p_scenario_id;

l_output_level_str varchar2(240) := to_char(NULL);
Begin

    open c1 (p_demand_plan_id,p_scenario_id);
      fetch c1 into l_output_level_str;
    close c1;

    if (l_output_level_str is null) then
      l_output_level_str := '-999';
    end if;

    return l_output_level_str;

End func_output_level_string;
--
-- Validate that Demand Priority Scenario Output Levels are matched with the Scenario Attached
--
Procedure chk_priority_scen_levels ( p_demand_plan_id in number) is

cursor c1(p_demand_plan_id number) is
select a.scenario_id ,a.scenario_name fcst_scenario_name,a.dmd_priority_scenario_id,b.scenario_name pri_scenario_name
from msd_dp_scenarios a,
     msd_dp_scenarios b
where a.demand_plan_id = p_demand_plan_id
and a.dmd_priority_scenario_id is not null
and b.scenario_id = a.dmd_priority_scenario_id
and b.demand_plan_id = p_demand_plan_id;


Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_priority_scen_levels ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message( 'Validating Forecast and attached Priority Scenario Output Levels' , SECTION);
    display_message( rpad('Forecast Scenario Name', 30) || ' ' || rpad('Demand Priority Scenario Name', 30) || ' ' ||
                    'Error Description' , HEADING);
    display_message( rpad('-', 30, '-') || ' ' || rpad('-', 30, '-') || ' ' ||
                     rpad('-' ,30, '-'), HEADING);
    --
    for c1_rec in c1(p_demand_plan_id) loop

       if func_output_level_string(p_demand_plan_id,c1_rec.scenario_id) <> func_output_level_string(p_demand_plan_id,c1_rec.dmd_priority_scenario_id) then
	    --
            -- error in output levels
            display_message( rpad(c1_rec.fcst_scenario_name, 30) || ' ' ||
            rpad(c1_rec.pri_scenario_name, 30) || 'has different output levels.', ERROR);

       end if;

    end loop;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_priority_scen_levels ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End chk_priority_scen_levels;



Procedure validate_demand_plan(
        errbuf          out nocopy varchar2,
        retcode         out nocopy varchar2,
        p_demand_plan_id in number) is

-- Delete before arcsing in
-- i number := 0;
--

   /*Bug# 4345323 Used to store the plan type(LIABILITY or SOP or NULL(for DP)) */
   l_plan_type  VARCHAR2(255);

Begin


    /* Bug# 4345323 Get the plan type of the plan */
    SELECT plan_type
           INTO l_plan_type
           FROM msd_demand_plans
	   WHERE demand_plan_id = p_demand_plan_id;

    /* Bug# 4345323 Call validate_liability_plan if plan type is LIABILITY*/
    IF nvl(l_plan_type,'DP') = 'LIABILITY' THEN

         MSD_LIABILITY.validate_liability_plan (
         				  errbuf,
         				  retcode,
         				  p_demand_plan_id );

         RETURN;
    END IF;


    /* Make sure this plan is not being used. */
    Lock_Row(p_demand_plan_id);

    if ( g_ret_code = '2' ) then
      retcode := '2';
      return;
    end if;


    /* Set demand plan for session */
    msd_stripe_demand_plan.set_demand_plan(p_demand_plan_id);

    /* Build/Update  Stripe for demand plan */
    msd_stripe_demand_plan.stripe_demand_plan(errbuf,
                                              retcode,
                                              p_demand_plan_id);

    /* Only continue if no errors were reported. */
    if (retcode = '2') then
      return;
    end if;
    /* End Build Stripe */

    /* Print the debug statement if debug is on */
    if l_debug = 'Y' then
        debug_out( 'Entering Validate_Demand_Plan ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    --
    -- initialize
    --
    l_result := SUCCESS;
    g_ret_code := 0;
    --
    -- find demand plan
    --
    display_message('Demand Plan Validation Process ', SECTION);
    display_message(' ', HEADING);
    display_message('Demand Plan Definition Details', HEADING);
    display_message('------------------------------', HEADING);
    display_message('Demand Plan ID : ' || p_demand_plan_id, INFORMATION);
    -- get demand plan
    open get_dp (p_demand_plan_id);
    fetch get_dp into l_dp_rec;
    if get_dp%notfound then
        close get_dp;
        display_message('Demand Plan : ' || p_demand_plan_id || ' not found ', FATAL_ERROR);
        return;
    else
        display_message('Demand Plan Name : ' || l_dp_rec.demand_plan_name , INFORMATION);
    end if;
    close get_dp;
    --
    -- Validate that required dimensions defined for the plan.
    --
    chk_required_dim (p_demand_plan_id);
    --
    -- Validate that number of user dimensions defined for the plan are valid.
    --
    chk_usr_dim (p_demand_plan_id);
    --
    -- Validate that the dimensions defined for the plan are used.
    --
    chk_usd_dim (p_demand_plan_id);
    --
    -- Check all the dimensions, except time, have at least one valid hierarchy associated with it
    --   and no invalid hierarchy is associated
    --
    chk_dim_hier (p_demand_plan_id);
    --
    -- Check that dimensions, except time,  have level values
    --
    chk_dim_lvl_val (p_demand_plan_id );
    --
    -- Validate that input parameters  are unique
    --
    chk_input_param (p_demand_plan_id);
    --
    -- Check scenario has related fact data
    --
    chk_fact_data (p_demand_plan_id);
    --
    -- Validate scenarios
    --
    chk_scenarios (p_demand_plan_id,
                   l_dp_rec.g_min_tim_lvl_id,
                   l_dp_rec.m_min_tim_lvl_id,
                   l_dp_rec.f_min_tim_lvl_id,
                   l_dp_rec.c_min_tim_lvl_id);
    --
    -- Validate output levels
    --
    chk_output_levels (p_demand_plan_id);
    chk_dup_dim_output_levels(p_demand_plan_id);

    chk_priority_scen_levels(p_demand_plan_id);
    --
    -- Verify Calendar and Time dimension
    --
    chk_time_data (p_demand_plan_id);
    --
    -- Validate Demand Plan Calendars data
    --
    chk_calendars (p_demand_plan_id, 1, l_dp_rec.g_min_tim_lvl_id);
    chk_calendars (p_demand_plan_id, 2, l_dp_rec.m_min_tim_lvl_id);
    chk_calendars (p_demand_plan_id, 3, l_dp_rec.f_min_tim_lvl_id);
    chk_calendars (p_demand_plan_id, 4, l_dp_rec.c_min_tim_lvl_id);
    --
    -- Validate Lowest Time Levels
    --
    chk_min_time  (l_dp_rec.g_min_tim_lvl_id,
                   l_dp_rec.m_min_tim_lvl_id,
                   l_dp_rec.f_min_tim_lvl_id,
                   l_dp_rec.c_min_tim_lvl_id);
    --
    -- Validate UOM conversion data
    --
    chk_uom_data (p_demand_plan_id );
    --
    -- Validate currency conversion data
    --
    chk_curr_data (p_demand_plan_id );
    --

    chk_scen_events(p_demand_plan_id);

    --Added for multiple composites enhancements
    --
    -- Validate whether composite groups has the same dimension
    --
    chk_composite_group_dimension (p_demand_plan_id);
    --

    --
    -- Validate whether composite groups has the same levels
    --
    chk_composite_group_level (p_demand_plan_id);
    --
    --Added for multiple composites enhancements

		/* Bug# 5248868
     * This procedure validates that whether price list data exists
     * for the price lists specified in the demand plan.
     * Note: Only time range validation is done
     */
    chk_price_list_data (p_demand_plan_id);

    --
    -- Validate Item Validation Org
    --
    chk_iv_org ( p_demand_plan_id , l_dp_rec.use_org_specific_bom_flag, l_dp_rec.stripe_stream_name, l_dp_rec.stripe_sr_level_pk);
    --

    --
    -- Validate the Organizations for ISO
    --
    chk_iso_org ( p_demand_plan_id );
    --

    display_message('End Validation Process.', SECTION);
    display_message('Exiting with :  ', l_result);
    --
    retcode := g_ret_code;
    -- update plan
    update_plan(p_demand_plan_id, g_ret_code);
    --

Exception
When EX_FATAL_ERROR then
    retcode := 2;
    errbuf := substr( sqlerrm, 1, 80);
when others then
    retcode := 2;
    errbuf := substr( sqlerrm, 1, 80);
End;

Procedure chk_required_dim (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_required_dim ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking for required dimensions ', SECTION);
    display_message('Dimension Name ', HEADING);
    display_message('-------------------------------- ', HEADING);
    --
    /* Check that Product and Time dimensions are defined */

    dummy := null;
    open get_dim(p_demand_plan_id, 'TIM', 'TIM');
    fetch get_dim into dummy;
    close get_dim;

    if dummy is null then
        -- Time dimension is not defined
        -- write_error('Time Dimension not defined');
        display_message('Time Dimension does not exist ' , ERROR);
    end if;

    dummy := null;
    open get_dim(p_demand_plan_id, 'PRD', 'PRD');
    fetch get_dim into dummy;
    close get_dim;

    if dummy is null then
        -- Product dimension is not defined
        -- write_error('Product Dimension not defined');
        display_message('Product Dimension is not defined ' , ERROR);
    end if;

    if ((nvl(l_dp_rec.enable_fcst_explosion, 'Y') = 'Y')
         and
        (l_dp_rec.use_org_specific_bom_flag='Y')) then
	-- For Dependent Demand ORG is a mandatory dimension
	    dummy := null;
    	open get_dim(p_demand_plan_id, 'ORG', 'ORG');
    	fetch get_dim into dummy;
    	close get_dim;

    	if dummy is null then
        	-- ORG dimension is not defined
        	-- write_error('Organization Dimension not defined');
        	display_message('Organization Dimension is not defined ' , ERROR);
    	end if;
    end if;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_required_dim ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;
End;

Procedure chk_usr_dim (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_usr_dim ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking user dimensions ', SECTION);
    display_message('Error Description', HEADING);
    display_message(rpad('-', 60, '-'), HEADING);
    --
    -- Check that there are at least three user dimesnions and maximum of four in total
    --
    open chk_user_dim( p_demand_plan_id);
    fetch chk_user_dim into l_cnt;
    close chk_user_dim;

    if l_cnt < 3 then
        -- write_error('Demand Plan must have at least three user dimensions');
        display_message('Demand Plan must have at least three user dimensions' , ERROR);
    elsif l_cnt > 4 then
        -- write_error('Demand Plan can not have more than four user dimensions');
        display_message('Demand Plan has more than four user dimensions' , ERROR);
    end if;

    --
    -- Check that there is only one user dimension collapsed.
    --
    l_cnt := 0;
    open chk_coll_dim(p_demand_plan_id);
    fetch chk_coll_dim into l_cnt;
    close chk_coll_dim;

    if l_cnt > 1 then
        display_message('Demand Plan only supports one collapsed dimension.' , ERROR);
    end if;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_usr_dim ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--

Procedure chk_usd_dim (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_usd_dim ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking used dimensions ', SECTION);
    display_message(rpad('Dimension Name', 31) || rpad('Error description', 40), HEADING);
    display_message(rpad('-', 30, '-') || ' ' ||  rpad('-', 50, '-'), HEADING);

    for l_token in chk_used_dim(p_demand_plan_id) loop
        display_message(rpad(l_token.dp_dimension_code, 31) || rpad('Not included in any input parameters.', 40), ERROR);
    end loop;


    if l_debug = 'Y' then
        debug_out( 'Exiting chk_usd_dim ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--

Procedure chk_dim_hier (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_dim_hier ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking for Dimensions with no hierarchy' , SECTION);
    display_message(rpad('Dimension Name', 31) || rpad('Type ', 11) || rpad('Error description', 40), HEADING);
    display_message(rpad('-', 30, '-') || ' ' || rpad('-', 10, '-') || ' ' ||  rpad('-', 50, '-'), HEADING);
    --
    for dim_usr_rec in get_usr_dim_with_no_hier( p_demand_plan_id)
    loop
        -- dimensions fetched here have no hierarchy
        display_message(rpad(dim_usr_rec.dp_dimension, 31) || rpad('USER', 11) ||
                         'has no associated hierarchy' , ERROR);
    end loop;
    --
    for dim_rec in get_dim_with_no_hier( p_demand_plan_id)
    loop
        -- dimensions fetched here have no hierarchy
        display_message(rpad(dim_rec.dimension_code, 31) || rpad('DIM', 11) ||
                             'has no associated hierarchy' , ERROR);
    end loop;
    --

    for c_rec in get_hier_collaps (p_demand_plan_id)
    loop
        display_message( rpad(c_rec.dp_dimension, 31) || 'does not exist as Dimension itself.', ERROR);
    end loop;
    --

    display_message('Checking for invalid hierarchies for the demand plan' , SECTION);
    display_message('Hierarchy Name', HEADING);
    display_message(rpad('-', 30, '-'), HEADING);
    --
    /* Check if there are any invalid hierarchies in the demand plan */
    for hier_rec in get_inval_hier(p_demand_plan_id)
    loop
        display_message(hier_rec.hierarchy_name , ERROR);
    end loop;
    --

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_dim_hier ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- Procedure to check dimension has level values
--
Procedure chk_dim_lvl_val (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_dim_lvl ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking for dimensions that do not have level values ' , SECTION);
    display_message(rpad('DIM', 6) || rpad('Hierarchy Name', 33) || rpad('Level Name', 33), HEADING);
    display_message(rpad('-', 5, '-') || rpad(' ', 32, '-') || rpad(' ', 32, '-'), HEADING);
    --


    /* Check that each dimension, except time,  has level values */
    for get_dim_no_lvl_rec in get_dim_no_lvl (p_demand_plan_id)
    loop
        display_message(rpad(get_dim_no_lvl_rec.dp_dimension_code, 5) || ' ' ||
                        rpad(get_dim_no_lvl_rec.hierarchy_name, 32)    || ' ' ||
                        rpad(get_dim_no_lvl_rec.level_name, 32) , ERROR);
    end loop;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_dim_lvl ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- Procedure to check unique input parameters
--
Procedure chk_input_param (p_demand_plan_id in number) is
lv_level_id1 number;
x_meaning varchar2(200);
x_name varchar2(300);
x_parameter_name varchar2(320);
x_is_dp_hier_level number;

cursor get_cs_name (p_cs_definition_id in number) is
select name
from msd_cs_definitions
where cs_definition_id = p_cs_definition_id;

/* Bug #5464757  */
Cursor COL_DIM_IN_PARA(P_PARA_TYPE in varchar2) is
 SELECT MDD.DIMENSION_CODE dim_code FROM  MSD.msd_dP_dimensions MDD
 where MDD.demand_plan_id =p_demand_plan_id
 and MDD.dimension_code<>MDD.dp_dimension_code
 AND MDD.DIMENSION_CODE NOT  IN
     (SELECT MCD.DIMENSION_CODE
      FROM MSD_CS_DEFN_DIM_DTLS MCD
      WHERE MCD.CS_DEFINITION_ID IN
             (select MCDS.CS_DEFINITION_ID
              FROM MSD_CS_DEFINITIONS MCDS
              WHERE MCDS.NAME = P_PARA_TYPE)
               and mcd.collect_flag='Y')
 AND MDD.DP_DIMENSION_CODE IN
     (SELECT MCD.DIMENSION_CODE
      FROM MSD_CS_DEFN_DIM_DTLS MCD
      WHERE MCD.CS_DEFINITION_ID IN
             (select MCDS.CS_DEFINITION_ID
              FROM MSD_CS_DEFINITIONS MCDS
              WHERE MCDS.NAME = P_PARA_TYPE)
               and mcd.collect_flag='Y')
Union All
 SELECT MDD.DP_DIMENSION_CODE dim_code FROM  MSD.msd_dP_dimensions MDD
 where MDD.demand_plan_id =p_demand_plan_id
 and MDD.dimension_code<>MDD.dp_dimension_code
 AND MDD.DP_DIMENSION_CODE NOT  IN
     (SELECT MCD.DIMENSION_CODE
      FROM MSD_CS_DEFN_DIM_DTLS MCD
      WHERE MCD.CS_DEFINITION_ID IN
             (select MCDS.CS_DEFINITION_ID
              FROM MSD_CS_DEFINITIONS MCDS
              WHERE MCDS.NAME = P_PARA_TYPE)
               and mcd.collect_flag='Y')
AND MDD.DIMENSION_CODE IN
     (SELECT MCD.DIMENSION_CODE
      FROM MSD_CS_DEFN_DIM_DTLS MCD
      WHERE MCD.CS_DEFINITION_ID IN
             (select MCDS.CS_DEFINITION_ID
              FROM MSD_CS_DEFINITIONS MCDS
              WHERE MCDS.NAME = P_PARA_TYPE)
               and mcd.collect_flag='Y');

Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_input_param ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Validating Input Parameters ' , SECTION);
    display_message( rpad('Parameter Type', 31) ||
                     rpad('Forecast By /Parameter Name',   31) ||
                     rpad('Condition', 31) , HEADING);
    display_message( rpad('-', 30, '-') || ' ' ||
                     rpad('-', 30, '-')  || ' ' ||
                     rpad('-', 30, '-'), HEADING);
    --
    /* Valdate input parameters */
    for param_rec in get_dupl_input_parameter(p_demand_plan_id)
    loop
        -- all records fetched are erroneous
        -- parameter_type, forecast_date_used must be unique for a demand plan
        display_message( rpad(param_rec.parameter_type, 31) ||
                         rpad(nvl(param_rec.forecast_date_used, param_rec.parameter_name), 30) ||
                         rpad('Duplicate Parameter.', 30),
                         ERROR);
    end loop;

    /* Check to see if a Parameter contains a level which is not
     * included in any attached hierachies.
     */

     for param_rec in get_inv_hier_prms(p_demand_plan_id)
     loop

        if (param_rec.level_id is null) then

          -- Use revision if an Input Scenario
          open get_cs_name(param_rec.cs_definition_id);
          fetch get_cs_name into x_name;
          close get_cs_name;

          if (x_name = 'MSD_INPUT_SCENARIO') then
             x_parameter_name := param_rec.revision;
          else
             x_parameter_name := param_rec.parameter_name;
          end if;

          --Find level id used in stream
          lv_level_id1 := get_level_id(param_rec.planning_server_view_name,
                                      get_level_column_name(param_rec.dimension_code,
                                                            param_rec.cs_definition_id),
                                      param_rec.date_clmn,
                                      param_rec.start_date,
                                      param_rec.end_date,
                                      param_rec.system_flag,
                                      param_rec.multiple_stream_flag,
				      x_parameter_name,
                                      param_rec.cs_definition_id,
                                      param_rec.level_id,
 				      param_rec.input_demand_plan_id,
                                      param_rec.input_scenario_id);

        else
          lv_level_id1 := param_rec.level_id;

        end if;


        if lv_level_id1 is not null and param_rec.dimension_code <> 'TIM' then
          -- all records fetched are erroneous

          begin

           open get_inv_hier_lvl_prms (p_demand_plan_id, lv_level_id1);
           fetch get_inv_hier_lvl_prms into x_is_dp_hier_level;
           close get_inv_hier_lvl_prms;

           if (x_is_dp_hier_level is null) then
             display_message( rpad(param_rec.description, 62) ||
                              rpad(msd_common_utilities.get_level_name(lv_level_id1), 28),
                              ERROR);
             display_message( rpad(' ', 62) ||
                              rpad('Not in DP Hierarchies.', 28),
                              INFORMATION);
            end if;

           exception when others then
           null;
           end;

        elsif lv_level_id1 is not null and param_rec.dimension_code = 'TIM' then
          -- find level id in msd dp calendars to see if it exists.

          begin

           open get_inv_hier_tim_prms(p_demand_plan_id, lv_level_id1);
           fetch get_inv_hier_tim_prms into x_meaning;
           close get_inv_hier_tim_prms;

           if (x_meaning is not null) then
             display_message( rpad(param_rec.description, 62) ||
                              rpad(x_meaning, 28),
                              ERROR);
             display_message( rpad(' ',62) ||
                              rpad('Not in DP Hierarchies.', 28),
                              INFORMATION);
           end if;

          exception when others
          then null;
          end;

        end if;
        lv_level_id1 := null;
        x_meaning := null;
        x_is_dp_hier_level := null;
        x_parameter_name := null;

      end loop;


    /* Additions. Check for multiple stream flag and whether the name is correct. */
    /* Sort through all parameters defined for this demand plan definition. */
    for param_rec in get_all_input_param (p_demand_plan_id)
    loop
        /* Bug #5464757: Error when ony one of the consituent dimension in collapsed dimension
              is not present in the parameter. */
        FOR COL_DIM IN COL_DIM_IN_PARA(param_rec.PARAMETER_TYPE_ID)
        loop
        display_message( rpad(param_rec.parameter_type, 31) ||
                         rpad(nvl(param_rec.forecast_date_used, param_rec.parameter_name), 20) ||
                         rpad('Collapse Dim: '|| COL_DIM.dim_code || ' is not in the parameter.' , 40),
                         ERROR);
        end loop;

        chk_ip_multiple(param_rec.parameter_type,
			param_rec.multiple_stream_flag,
			param_rec.parameter_name);
        chk_ip_allo_agg(param_rec.parameter_type,
				 param_rec.parameter_name,
				 param_rec.demand_plan_id,
				 param_rec.cs_definition_id,
				 param_rec.allo_agg_basis_stream_id);

        chk_cal_for_bucket (param_rec.start_date,
		            param_rec.demand_plan_id,
                            rpad(param_rec.parameter_type,31) || rpad(param_rec.parameter_name, 31) ||  'Start Date ');

        chk_cal_for_bucket (param_rec.end_date,
				 param_rec.demand_plan_id,
                            rpad(param_rec.parameter_type,31) || rpad(param_rec.parameter_name, 31) ||  'End Date ');

    end loop;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_input_param ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- Procedure to validate scenarios
--
Procedure chk_scenarios (p_demand_plan_id in number,
                         p_g_min_tim_lvl_id in number,
                         p_m_min_tim_lvl_id in number,
                         p_f_min_tim_lvl_id in number,
                         p_c_min_tim_lvl_id in number) is

   b_empty_scenario    BOOLEAN := TRUE;

   cursor c1(p_sc_id in number) is
   Select decode(output_period_type,
      	      9, 0,
              8, 1,
              7, 1,
              6, 1,
              5, 3,
              4, 3,
              3, 3,
              2, 2,
              1, 2,
              4)
   from msd_dp_scenarios md
   where md.scenario_id = p_sc_id;

   cursor c2 is
   select count(1)
     from msd_dp_calendars
    where demand_plan_id = p_demand_plan_id;

   cursor c3(p_cal_type in number) is
   select count(1)
     from msd_dp_calendars
    where demand_plan_id = p_demand_plan_id
      and calendar_type = p_cal_type;

   cursor c4(p_lvl_id in number) is
   Select decode(p_lvl_id,
      	      9, 0,
              8, 1,
              7, 1,
              6, 1,
              5, 3,
              4, 3,
              3, 3,
              2, 2,
              1, 2,
              4)
   from dual;

   x_cal_type number := 0;
   x_count number := 0;
   x_stream_defined number := 0;
   param_time_level_id number := 0;
   param_cal_type number := 0;

Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_scenarios ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Validating scenarios' , SECTION);
    display_message(rpad('Scenario Name', 31) || rpad('Error Description', 60), HEADING);
    display_message(rpad('-', 30, '-') || ' ' || rpad('-', 60, '-'), HEADING);
    --
    /* Validate Scenarios */
    FOR scen_rec IN get_scen (p_demand_plan_id) LOOP
      /* When code reaches this line, it means there is at least 1 scenario
	 associated with this Demand Plan. */
      IF (b_empty_scenario) THEN
         b_empty_scenario := FALSE;
      END IF;

      IF (scen_rec.forecast_based_on is not null) THEN
        -- verify there is input parameter defined for the scenario
        l_a_date := null;
        l_b_date := null;
        open get_input_param(p_demand_plan_id, scen_rec.forecast_based_on, scen_rec.parameter_name, scen_rec.forecast_date_used);

        fetch get_input_param into l_a_date, l_b_date;
        close get_input_param ;
        if l_a_date is null then
            -- there should be an associated input parameter
            display_message( rpad(scen_rec.scenario_name, 31) ||
			rpad('Input parameter not found for ', 60) , ERROR);
        else

            -- scenario's history date range must be well within input parameter's history date range
            if l_a_date > scen_rec.history_start_date then
                -- scenario's history start date must be later than the associated input parameter
                display_message( rpad(scen_rec.scenario_name , 31) ||
			rpad('History start date must be >= input parameter''s start date', 60) , ERROR);
            end if;
            --
            if l_b_date is not null and scen_rec.history_end_date is not null then
                if l_b_date < scen_rec.history_end_date then
                  -- scenario's history end date must be prior to the associated input parameter
                    display_message( rpad(scen_rec.scenario_name, 31) ||
			rpad('History end date must be <= input parameter''s end date.', 60) , ERROR);
                end if;
            end if;
            --
        end if;

     end if;
        --
        -- verify horizon date
        -- changed if statement.
        if ((scen_rec.history_end_date is not null) and
		(scen_rec.horizon_start_date <= scen_rec.history_end_date)) then
            -- horizon start date must be later than history_end_date
            display_message( rpad(scen_rec.scenario_name, 31) ||
			rpad('Horizon start date must be later than history end date.', 60) , ERROR);
        end if;
        --
        if nvl(scen_rec.publish_flag, 'N') = 'Y' then
            -- Verify it has required output levels
            l_cnt := 0;

            if (l_dp_rec.use_org_specific_bom_flag = 'Y') then
              open get_output_levels_org(l_dp_rec.demand_plan_id, scen_rec.scenario_id) ;
              fetch get_output_levels_org into l_cnt;
              close get_output_levels_org;
              if l_cnt <> 2 then
                  -- publishable scenario must have output levels....
                  display_message( rpad(scen_rec.scenario_name, 31) ||
		  		rpad('Must have output levels (Item or Prod. family) and Org.', 60) , ERROR);
              end if;
           else
              open get_output_levels(l_dp_rec.demand_plan_id, scen_rec.scenario_id) ;
              fetch get_output_levels into l_cnt;
              close get_output_levels;
              if l_cnt <> 1 then
                  -- publishable scenario must have output levels....
                  display_message( rpad(scen_rec.scenario_name, 31) ||
		  		rpad('Must have output levels (Item or Prod. family) and Org.', 60) , ERROR);
              end if;
           end if;

           -- verify forecast level
           if scen_rec.output_period_type not in (1,2,9) then
                  -- must be at day level
                  display_message( rpad(scen_rec.scenario_name, 31) ||
		     rpad('Only Man. Period, Man. Week, or Day can be published.', 60) , ERROR);
           end if;

        end if;
        --
        -- save max horizon date
        --
        if l_dp_max_date is null or l_dp_max_date < scen_rec.horizon_end_date then
            l_dp_max_date := scen_rec.horizon_end_date;
        end if;
        --
        -- save min. history date
        --
        if ((scen_rec.history_start_date is not null) and
		(l_dp_min_date is null or l_dp_min_date < scen_rec.history_start_date)) then
            l_dp_min_date := scen_rec.history_start_date;
        end if;


        if (scen_rec.history_start_date is not null) then
          chk_cal_for_bucket (scen_rec.history_start_date,
                              p_demand_plan_id,
                              rpad(scen_rec.scenario_name, 31) || 'History Start Date ');
        end if;

        if (scen_rec.history_end_date is not null) then
          chk_cal_for_bucket (scen_rec.history_end_date,
                              p_demand_plan_id,
                              rpad(scen_rec.scenario_name, 31) || 'History End Date ');
        end if;

        if (scen_rec.horizon_start_date is not null) then
          chk_cal_for_bucket (scen_rec.horizon_start_date,
                              p_demand_plan_id,
                              rpad(scen_rec.scenario_name, 31) || 'Horizon Start Date ');
        end if;

        if (scen_rec.horizon_end_date is not null) then
          chk_cal_for_bucket (scen_rec.horizon_end_date,
                              p_demand_plan_id,
                              rpad(scen_rec.scenario_name, 31) || 'Horizon End Date ');
        end if;

        /** Added for Multiple Time Hierarchies **/

        /** Check if Calendar is attached for Output Period Type **/

        if (scen_rec.output_period_type is not null) then
          open c1(scen_rec.scenario_id);
          fetch c1 into x_cal_type;
          close c1;

          if (x_cal_type = 0) then
            open c2;
            fetch c2 into x_count;
            close c2;
          else
            open c3(x_cal_type);
            fetch c3 into x_count;
            close c3;
          end if;

          if (x_count = 0) then
            display_message( rpad(scen_rec.scenario_name, 31) ||
				rpad('Calendar for Output Period type not attached to plan.', 60) , ERROR);
          end if;
         end if;


        /** Treat Day as a separate case **/
        if (scen_rec.output_period_type = 9) then
          if (p_g_min_tim_lvl_id is null) and
             (p_f_min_tim_lvl_id is null) and
             (p_m_min_tim_lvl_id is null) and
             (p_c_min_tim_lvl_id is null) then
            null;
          elsif((p_g_min_tim_lvl_id = 9) or
             (p_f_min_tim_lvl_id = 9) or
             (p_m_min_tim_lvl_id = 9) or
             (p_c_min_tim_lvl_id = 9)) then
            null;
          else
           display_message( rpad(scen_rec.scenario_name, 31) ||
				rpad('Output period type is less than minimum time level', 60) , ERROR);
          end if;
        elsif scen_rec.output_period_type is not null then
          if ((scen_rec.output_period_type between 6 and 8) and ((p_g_min_tim_lvl_id > scen_rec.output_period_type) and (p_g_min_tim_lvl_id <> 9)))
             or
             ((scen_rec.output_period_type between 3 and 5) and ((p_f_min_tim_lvl_id > scen_rec.output_period_type) and (p_f_min_tim_lvl_id <> 9)))
             or
              ((scen_rec.output_period_type between 1 and 2) and ((p_m_min_tim_lvl_id > scen_rec.output_period_type) and (p_m_min_tim_lvl_id <> 9)))
             or
              ((scen_rec.output_period_type between 10 and 13) and ((p_c_min_tim_lvl_id > scen_rec.output_period_type) and (p_c_min_tim_lvl_id <> 9))) then
           display_message( rpad(scen_rec.scenario_name, 31) ||
				rpad('Output period type is less than minimum time level', 60) , ERROR);

          end if;


        end if;

        /** Check if Output Period Type is in same calendar as Input Parameter **/
        if ((scen_rec.forecast_based_on is not null)
             and ((scen_rec.allocation_allowed_flag = 'N')
                   or
                  (scen_rec.allocation_allowed_flag='Y' and scen_rec.lowest_level_flag=x_stream_defined))) then

          if (scen_rec.collect_level_id is null) then

          /** If not, then check in fact tables for value **/
           param_time_level_id := get_level_id( scen_rec.view_name,
                                        get_level_column_name('TIM',scen_rec.cs_definition_id),
                                        scen_rec.date_planning_view_clmn,
                                        scen_rec.prm_start_date,
                                        scen_rec.prm_end_date,
                                        scen_rec.system_flag,
                                        scen_rec.multiple_stream_flag,
                                        scen_rec.parameter_name,
                                        scen_rec.cs_definition_id,
                                        scen_rec.collect_level_id,
                                        scen_rec.input_demand_plan_id,
                                        scen_rec.input_scenario_id);

          else

            param_time_level_id := scen_rec.collect_level_id;

          end if;

          open c4(param_time_level_id);
          fetch c4 into param_cal_type;
          close c4;

          if ((param_cal_type <> 0) and (x_cal_type <> 0) and (param_cal_type <> x_cal_type)) then
             display_message( rpad(scen_rec.scenario_name, 31) ||
  		rpad('Choose an Output Period Type in the same type ', 60) , WARNING);
             display_message( rpad(' ', 31) ||
  		rpad('of calendar as the Input Parameter''s Time Level.', 60) , INFORMATION);

          elsif ((param_time_level_id <> 9)
                  and (scen_rec.output_period_type <> 9)
                  and (param_time_level_id > scen_rec.output_period_type)) then

             display_message( rpad(scen_rec.scenario_name, 31) ||
  		rpad('Choose an Output Period Type at or above ', 60) , WARNING);
             display_message( rpad(' ', 31) ||
  		rpad('the Input Parameter''s Time Level.', 60) , INFORMATION);

          elsif ((param_time_level_id <> 9)
                  and (scen_rec.output_period_type = 9)) then
             display_message( rpad(scen_rec.scenario_name, 31) ||
  		rpad('Choose an Output Period Type at or above ', 60) , WARNING);
             display_message( rpad(' ', 31) ||
  		rpad('the Input Parameter''s Time Level.', 60) , INFORMATION);

        end if;
        end if;

        /* End Output Period Type Check */

        x_count := 0;
        x_cal_type := 0;
        param_time_level_id := null;
        param_cal_type := 0;

        /** End additions for Multiple Time Hierarchies **/

    END LOOP; -- End of FOR scen_rec loop

 -- If there is no scenario specified for the D.P. then generate warning message.
    IF (b_empty_scenario) THEN
       display_message(rpad(l_dp_rec.demand_plan_name,30) || ' ' ||
		       rpad('No scenario is specified for this Demand Plan',60), ERROR);
    END IF;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_scenarios ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- Validate output levels
--
Procedure chk_output_levels ( p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_otuput_levels ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message( 'Validating Output Levels' , SECTION);
    display_message( rpad('Scenario Name', 30) || ' ' || rpad('Level Name', 20) || ' ' ||
                    rpad('Dimension', 10) || 'Error Description' , HEADING);
    display_message( rpad('-', 30, '-') || ' ' || rpad('-', 20, '-') || ' ' ||
                    rpad('-', 9, '-') || ' '  || rpad('-' ,30, '-'), HEADING);
    --
    for c1_rec in get_inv_output_levels(p_demand_plan_id) loop
      --
      -- error in output levels
            display_message( rpad(c1_rec.scenario_name, 30) || ' ' ||
            rpad(c1_rec.level_name, 20) || ' ' || rpad(c1_rec.dimension_code, 10)
            || 'has no associated hierarchy.', ERROR);
    end loop;

    if l_debug = 'Y' then
        debug_out( 'Entering chk_output_levels ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;

Procedure chk_dup_dim_output_levels ( p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_dup_dim_otuput_levels ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message( 'Checking Duplicate Dimensions in Output Levels' , SECTION);
    display_message( rpad('Scenario Name', 30) || ' ' ||rpad('Dimension', 10) || 'Error Description' , HEADING);
    display_message( rpad('-', 30, '-') || ' ' || ' ' ||rpad('-', 9, '-') || ' '  || rpad('-' ,30, '-'), HEADING);
    --
    for c1_rec in get_dup_dim_output_levels(p_demand_plan_id) loop
      --
      -- error in output levels
            display_message( rpad(c1_rec.scenario_name, 30) || ' ' ||
            rpad(c1_rec.dimension_code, 10)
            || 'has more than one levels selected.', ERROR);
    end loop;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_dup_dim_output_levels ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- Validate Time Data
--
Procedure chk_time_data (p_demand_plan_id in number) is
  --
  cursor get_input_date (p_demand_plan_id in number) is
  select
    min(start_date), max(end_date)
  from
    msd_dp_parameters_cs_v
  where
    demand_plan_id = p_demand_plan_id;
  --
  l_min_1 date;
  l_max_1 date;
  --
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_time_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message( 'Validating Calendar properties' , SECTION);
    display_message( 'Error Description' , HEADING);
    display_message( rpad('-', 80, '-') , HEADING);
    /* verify calendar */

/* Removed for Multiple Time Hierarchies.
 *
 *    if l_dp_rec.calendar_type not in (
 *           MSD_COMMON_UTILITIES.GREGORIAN_CALENDAR,
 *           MSD_COMMON_UTILITIES.MANUFACTURING_CALENDAR,
 *           MSD_COMMON_UTILITIES.FISCAL_CALENDAR )
 *
 *   then
 *       -- invalid calendar
 *       display_message( 'Calendar is not a valid calendar' , ERROR);
 *   else
 */

        --
        -- Get min and max date from input parameters
        --
        open get_input_date (p_demand_plan_id);
        fetch get_input_date into l_min_1, l_max_1;
        close get_input_date;
        --
        if ((l_min_1 < l_dp_min_date) or (l_dp_min_date is null)) then
          l_dp_min_date := l_min_1;
        end if;
        --
        if ((l_max_1 > l_dp_max_date) or (l_dp_max_date is null)) then
          l_dp_max_date := l_max_1;
        end if;
        --
        -- Validate time dimension
        --
     for cal_rec in get_dp_cal(p_demand_plan_id) loop

       l_min_date := null;
       l_max_date := null;

       for c1_rec in get_tim(cal_rec.calendar_type, cal_rec.calendar_code,l_dp_min_date,l_dp_max_date) loop

          l_min_date := c1_rec.min_date ;
          l_max_date := c1_rec.max_date ;

        if l_min_date is null or l_max_date is null then
            -- error time dimesnion does not have values

            display_message('Time data not found in ' || cal_rec.op_cal_code, ERROR);
        end if;
        --
        if l_min_date > l_dp_min_date then
            -- time dimension does not have data for history_start_date
            display_message( cal_rec.op_cal_code || ' does not have data for history start date ' ||
                              to_char(l_dp_min_date, 'DD-Mon-YYYY'), ERROR);
        end if;
        --
        if l_max_date <  l_dp_max_date then
            -- time dimension does not have data for history_start_date
            display_message( cal_rec.op_cal_code || ' does not have data for the last horizon date ' ||
                              to_char(l_dp_max_date, 'DD-Mon-YYYY'), ERROR);
        end if;
        --
       end loop;
     end loop;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_time_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- check for UOM conversion data
--
Procedure chk_uom_data (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_uom_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

   display_message( 'Validating UOM properties' , SECTION);
   IF (l_dp_rec.base_uom IS NULL) THEN
      display_message( 'Base UOM has not been defined.', ERROR);
   ELSE
      -- UOM Conversion data
       open uom_conv (l_dp_rec.base_uom);
       fetch uom_conv into l_cnt;
       close uom_conv;

       if l_cnt = 0 then
           -- UOM conversion not collected
           display_message( 'UOM conversion rate not defined.', ERROR);
       end if;
   END IF;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_uom_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
-- Check for currency conversion data
--
Procedure chk_curr_data (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_curr_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    -- currency conversion data
    if fnd_profile.value('MSD_CURRENCY_CODE') is not null then
      open curr_conv (fnd_profile.value('MSD_CURRENCY_CODE'), l_dp_min_date , l_dp_max_date);
      fetch curr_conv into l_cnt;
      close curr_conv;
      --
      if l_cnt = 0 then
          -- no currency conversion data
          display_message( 'Currency conversion data not found for ' || fnd_profile.value('MSD_CURRENCY_CODE'), WARNING);
      end if;
    end if;
    --

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_curr_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--

/* For each parameter defined within the demand plan definition check that
 * fact data exists in the Fact Table for the Parameter Name, Forecast Date,
 * and Data Range specified.
 */

PROCEDURE chk_fact_data (p_demand_plan_id IN NUMBER) IS

    /* Cursor used to check the Fact Data */
    Type FACT_DATA_TYPE is REF CURSOR;
    --
    c_fact_data 	FACT_DATA_TYPE;
    --
    /* Fact Data Table Name */
    l_source    	VARCHAR2(30);
    l_ps_view_name      VARCHAR2(30);

    /* Date Column Name in Fact Table */
    l_date_col  	VARCHAR2(30);

    /* Start Date of Parameter History */
    l_start_date 	VARCHAR2(200);

    /* End Date of Parameter History */
    l_end_date   	VARCHAR2(200);

    /* Designator Column Name in Fact Table. */
    l_name      	VARCHAR2(300);

    /* Dynamic SQL string used to check fact data. */
    l_stmt      	VARCHAR2(2000);

    /* Number of rows fetched from Fact Data during check. */
    l_count     	NUMBER;

    /* String printed to output to identify each Parameter being tested. */
    l_output    	VARCHAR2(2000);

    /* Index of character being printed for error messages. */
    i                   NUMBER;

    /* Find out whether stream is local or not. Used for Checking
     * which rows are deleted...for Net Change
     */
     cursor get_stream_type(p_cs_definition_id number) is
     select cs_type
       from msd_cs_definitions
      where cs_definition_id = p_cs_definition_id;

    /* Stream type for Custom Stream */
    x_stream_type varchar2(30);

    /* Find the collect level id for time */
    cursor get_col_lvl_id(p_cs_definition_id in number, p_dim_code in varchar2) is
    select collect_level_id
    from msd_cs_defn_dim_dtls
    where cs_definition_id = p_cs_definition_id
    and dimension_code = p_dim_code;

    /* Translate Time Level Id into Time Column in MSD_TIME */
    cursor tim_lvl_id_2_clmn (p_lvl_id in number) is
    select decode(p_lvl_id,
                            '1', 'WEEK_END_DATE ',
                            '2', 'MONTH_END_DATE ',
                            '3', 'MONTH_END_DATE ',
                            '4', 'QUARTER_END_DATE ',
                            '5', 'YEAR_END_DATE ',
                            '6', 'MONTH_END_DATE ',
                            '7', 'QUARTER_END_DATE ',
                            '8', 'YEAR_END_DATE ',
                            '9', 'DAY',
                           '10', 'WEEK_END_DATE ',
                           '11', 'MONTH_END_DATE ',
                           '12', 'QUARTER_END_DATE ',
                           '13', 'YEAR_END_DATE ',
                           'DAY ')
     from dual;

     /* Map the Time Level Id to the calendar type */
     /* If day then any calendar is fine */
     /* This is handled with the last case. we return column name */

     cursor tim_lvl_id_2_cal_type (p_time_level_id in number) is
     select decode (p_time_level_id,
               1, '2',
               2, '2',
               3, '3',
               4, '3',
               5, '3',
               6, '1',
               7, '1',
               8, '1',
               10, '4',
               11, '4',
               12, '4',
               13, '4',
               'tim.calendar_type')
      from dual;

    time_level_id number;
    time_level_column varchar2(100);
    time_cal_type varchar2(100);

BEGIN

    if l_debug = 'Y' then
        debug_out( 'Entering chk_fact_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;


    /* Titles for each Parameter in the Log File */
    display_message( 'Validating Fact Data', SECTION);
    display_message( rpad('Parameter Type', 24) || rpad('Forecast Date', 20) ||
                     'Start Date End Date  Error Description', HEADING);
    display_message( rpad('-', 23, '-') || ' ' || rpad('-', 19, '-') || ' ' ||
                     '---------- --------- -------------------------', HEADING);
    --
    /* Loop through each parameter defined in the Demand Plan */
    FOR c_input_rec IN get_all_input_param (p_demand_plan_id) LOOP
    --
        /* Re-initializing variables */
        l_output 	:= NULL;
        l_source 	:= NULL;
	l_ps_view_name  := NULL;
        l_name		:= NULL;
        l_date_col      := NULL;

        /* Retrieve Value for Fact View and Desginator Column Name */
          open get_ps_view_name (c_input_rec.cs_definition_id, p_demand_plan_id);
	  fetch get_ps_view_name into l_source, l_ps_view_name;
  	  close get_ps_view_name;

          l_name := get_desig_clmn_name(c_input_rec.cs_definition_id);

        /* Retrieve Value for Date Column Name */
        l_date_col 	:= c_input_rec.date_planning_view_clmn;

        /* Prepare String Output for Log File */
        /* Parameter Type, Date Type,  Start Date, End Date */
        /* The Desginator is displayed later in a following line. */
        l_output 	:= RPAD(c_input_rec.parameter_type, 24) ||
                    	   RPAD(nvl(nvl(c_input_rec.forecast_date_used, l_date_col),' '), 20) ||
                           TO_CHAR(c_input_rec.start_date, 'dd-mm-yyyy') || ' ' ||
                           TO_CHAR(c_input_rec.end_date, 'dd-mm-yyyy');

	/* Check if the user specified a view in the Parameters Tab to Override */
        IF c_input_rec.view_name IS NOT NULL THEN
          l_source 	:= c_input_rec.view_name;
          l_ps_view_name := c_input_rec.view_name;
        END IF;

	/******************************************************************************
	 * Only check for fact data if the Fact Table, Date Column, and Designator
         * Column (if necesary) exists.
	 *
	 * (1) The Planning Server View must be NOT NULL.
	 * (2) The Planning Server Date Column must be NOT NULL.
	 * (3) If the Parameter has multiple streams then the Planning Server Designator
	 *     Column must be NOT NULL.
	 * (4) If any one of the above cases fail and the Parameter is of type 'Input Scenario',
	 *     then continue with the check.
	 *
         *     Structure of the Dynamic SQL String is as follows for Streams not using
	 *     Custom Stream Fact Tables:
	 *
         *     SELECT 	count(1)
	 *     FROM 	"User Defined Planning Server View Name"
         *     WHERE 	"User Defined Server View Date Column" IS BETWEEN "Start Date" AND "End Date"
	 *
	 *
         *     Structure of the Dynamic SQL String is as follows for Streams using Custom Stream Fact Tables:
	 *
         *     SELECT 	count(1)
	 *     FROM 	"Custom Stream Planning Server View Name"
         *     WHERE 	"Custom Stream Planning Server View Date Column" IS BETWEEN "Start Date" AND "End Date"
	 *     AND	Custom_Stream_Definition = "Parameter Custom Stream Definition"
	 *
	 *     Structure of the Dynamic SQL String is as follows for Input Scenario Streams
	 *
	 *     SELECT   count(1)
	 *     FROM     msd_dp_scenario_entries
	 *     WHERE    tim_lvl_val_to   IS BETWEEN "Start Date" AND "End Date"
	 *     AND	scenario_id = input_scenario_id
         *     AND	...
         **************************************************************************************/

        IF (	((l_source 	IS NOT NULL)  AND
                 (l_date_col 	IS NOT NULL)  AND
                 (
                  (nvl(c_input_rec.multiple_stream_flag,'N') = 'Y' AND l_name IS NOT NULL)
               	    OR
                  (nvl(c_input_rec.multiple_stream_flag,'N') <>  'Y')
                 )
                )
           OR
                 (c_input_rec.parameter_type_id in ('MSD_INPUT_SCENARIO'))) THEN
          BEGIN

  	    /* History Start Date and End Date */
            l_start_date := 'TO_DATE(''' || TO_CHAR(c_input_rec.start_date,  'ddmmyyyy') || ''', ''ddmmyyyy'')';
            l_end_date 	 := 'TO_DATE(''' || TO_CHAR(c_input_rec.end_date,  'ddmmyyyy') || ''', ''ddmmyyyy'')';

	    /* Select, FROM portions of Dynamic Statement */
            l_stmt 	 := 'SELECT COUNT(*) FROM ' || l_source || ' src WHERE ';

            /* For Streams other than Input Scenario use Generic Where clause */
            IF (c_input_rec.parameter_type_id NOT IN ('MSD_INPUT_SCENARIO')) THEN
              l_stmt 	 := l_stmt || 'src.' || l_date_col ||
                           ' BETWEEN ' || l_start_date || ' AND ' || l_end_date || ' AND ROWNUM < 5';

              /* For multiple streams check designator */
	      IF (nvl(c_input_rec.multiple_stream_flag,'N') = 'Y') THEN
                l_stmt   := l_stmt || ' AND src.' || l_name || ' = ''' || replace(c_input_rec.parameter_name, '''', '''''') || '''';
              END IF;

	      /* For Streams Defined using Custom Stream Fact Tables */
              IF (c_input_rec.system_flag = 'C') then
		l_stmt   := l_stmt || ' AND src.cs_definition_id = ' || c_input_rec.cs_definition_id;
	      END IF;

              /* Add demand plan id if included for striping. */

              if ((l_dp_rec.stripe_stream_name is not null) or (l_dp_rec.stripe_sr_level_pk is not null)) then
                if ((c_input_rec.system_flag = 'I') OR (c_input_rec.cs_type in ('SOURCE','STAGE'))) then
                   l_stmt	  := l_stmt || ' AND src.demand_plan_id = ' || p_demand_plan_id;
                end if;
              end if;

              /* Included for Net Change */
              open get_stream_type(c_input_rec.cs_definition_id);
              fetch get_stream_type into x_stream_type;
              close get_stream_type;

	      /* Find Time level id column */
	      open get_col_lvl_id(c_input_rec.cs_definition_id, 'TIM');
              fetch get_col_lvl_id into time_level_id;
              close get_col_lvl_id;

              if (time_level_id is null) then

                 time_level_id := get_level_id( l_ps_view_name,
                                        get_level_column_name('TIM',c_input_rec.cs_definition_id),
                                        l_date_col,
                                        c_input_rec.start_date,
                                        c_input_rec.end_date,
                                        c_input_rec.system_flag,
                                        c_input_rec.multiple_stream_flag,
                                        c_input_rec.parameter_name,
                                        c_input_rec.cs_definition_id,
                                        9,
                                        -999,
                                        -999);

              end if;

              /* Translate TIme level id into Time Column */
              open tim_lvl_id_2_clmn (time_level_id);
              fetch tim_lvl_id_2_clmn into time_level_column;
              close tim_lvl_id_2_clmn;

	      /* Translate Time Level Id to Calendar Type */
              open tim_lvl_id_2_cal_type(time_level_id);
              fetch tim_lvl_id_2_cal_type into time_cal_type;
              close tim_lvl_id_2_cal_type;

              If (x_stream_type <> 'LOCAL') then
                l_stmt  := l_stmt || ' AND src.action_code <> ''D''';
              End IF;

              /* BUG 2419958 : Add clause to check that data exists in msd_time_v too.
               * Retrieve the end_date and level_id to find out a row in time and fact that match.
               */
                l_stmt   := l_stmt || ' AND EXISTS (select 1 from msd_time tim where src.';
                l_stmt   := l_stmt || l_date_col || ' = tim.' || nvl(time_level_column, 'DAY');

                l_stmt   := l_stmt || ' and (tim.calendar_type, tim.calendar_code) in (select mdc.calendar_type, mdc.calendar_code from msd_dp_calendars mdc where mdc.demand_plan_id = ' ||  p_demand_plan_id || ')';
                l_stmt   := l_stmt || ' and ' || time_cal_type || ' = tim.calendar_type)';


            ELSE
              /* Special case for Input Scenario.
               * Checks for the Following :
	       * (1) Scenario entry exists for Demand Plan Id, Scenario Id, Revision specified.
               * (2) Range of Date in One Entry exists for Parameter's Date Range
               */

	      /* Checks for Input Scenario */
              l_stmt 	 := l_stmt || ' src.time_lvl_val_to BETWEEN ' || l_start_date || ' AND ' || l_end_date;
              l_stmt 	 := l_stmt || ' AND src.scenario_id  = ' || NVL(c_input_rec.input_scenario_id, -999);
              l_stmt 	 := l_stmt || ' AND src.demand_plan_id  = ' || NVL(c_input_rec.input_demand_plan_id, -999);
              l_stmt 	 := l_stmt || ' AND src.revision  = ''' || NVL(c_input_rec.revision, -999) || '''';

	      -- Performance enhancement if plan is LOB enabled.
	      if ((l_dp_rec.stripe_stream_name is not null)
		   or
                  (l_dp_rec.stripe_sr_level_pk is not null)) then

		  l_stmt := l_stmt || ' AND src.stripe_demand_plan_id = ' || p_demand_plan_id;
              end if;

              l_stmt 	 := l_stmt || ' AND ROWNUM < 2';

            END IF;

            /* Print the debug statement if debug is on */
            if l_debug = 'Y' then
              debug_out( l_stmt);
            end if;

            OPEN c_fact_data FOR l_stmt;
            FETCH c_fact_data INTO l_count;
            CLOSE c_fact_data;
            IF l_count = 0 THEN
               display_message(l_output || ' fact data does not exist'      , WARNING);
               IF nvl(c_input_rec.multiple_stream_flag,'N') = 'Y' THEN
                  display_message(' (' ||  replace(c_input_rec.parameter_name, '''', ''''''), INFORMATION);
               END IF;
            END IF;

          EXCEPTION
          WHEN OTHERS THEN
            IF c_fact_data%ISOPEN THEN
                CLOSE c_fact_data;
            END IF;
            display_message(l_output || ' fact data check failed.', ERROR);
            --
            debug_out( substr(sqlerrm,  1 , 90) );
            debug_out( substr(sqlerrm,  91, 90) );

            i := 1;
            while i<= length(l_stmt) loop
              debug_out( substr(l_stmt, i, 90)  );
	      i := i+90;
            end loop;
            --
          END;
        ELSE
            display_message(l_output || ' fact data check not done', WARNING);
            display_message('Source View Name : ' || nvl(l_source, 'Missing'), INFORMATION);
            display_message('Date Column Name : ' || nvl(l_date_col, 'Missing'), INFORMATION);
            display_message('Designator Column Name : ' || l_name, INFORMATION);
            display_message('Multiple Stream Flag : ' || nvl(c_input_rec.multiple_stream_flag,'N'), INFORMATION);
        END IF;
    END LOOP;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_fact_data ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

END chk_fact_data;
--
Procedure update_plan(p_demand_plan_id in number, p_ret_code in number) is
Begin
    --

    if l_debug = 'Y' then
        debug_out( 'Entering update_plan ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    if nvl(p_ret_code, '1') <> '0' and nvl(p_ret_code, '2') <> '1' then
        update msd_demand_plans
        set valid_flag = '1'
        where demand_plan_id = p_demand_plan_id;
    else
        --
        update msd_demand_plans
        set valid_flag = '0'
        where demand_plan_id = p_demand_plan_id;
    end if;
    --

    if l_debug = 'Y' then
        debug_out( 'Exiting update_plan ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--
Procedure chk_ip_multiple(p_parameter_type in varchar2, p_multiple_flag in varchar2, p_parameter_name in varchar2) is
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_ip_multiple ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

   if ((p_multiple_flag = 'Y') and (p_parameter_name is null)) then
      /* Display error */
      display_message( rpad(p_parameter_type, 31) ||
                         rpad(nvl(p_parameter_name,' '), 30) ||
                         rpad('Name required with multiple stream ', 30),
                         ERROR);
   elsif ((p_multiple_flag = 'N') and (p_parameter_name is not null)) then
      /* Display error */
     display_message( rpad(p_parameter_type, 31) ||
                         rpad(p_parameter_name, 30) ||
                         rpad('Name undefined without multiple stream ', 30),
                         ERROR);
   elsif (p_parameter_name is not null) then
      null;
   end if;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_ip_multiple ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;
--


Procedure chk_ip_allo_agg(p_parameter_type in varchar2, p_parameter_name in varchar2, p_demand_plan_id in number, p_cs_def_id in number, p_stream_id in number) is
   l_token number;
Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_ip_allo_agg ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

   /* The number of columns that can use Allo/Agg */
   open param_cs_wgt(p_cs_def_id);
   fetch param_cs_wgt into l_token;
   close param_cs_wgt;

   /* The Allo/Agg stream is not defined and is not Usable */
   if ((p_stream_id is null) and (l_token = 0)) then
     /* Nothing defined, nothing usable, nothing to check. */
     RETURN;
   /* The Allo/Agg stream is defined but is not Usable */
   elsif ((p_stream_id is not null) and (l_token = 0)) then
     /* The user cannot see unusable values. Don't show that this data exists. */
     RETURN;
     /*
      *  display_message( rpad(p_parameter_type, 31) ||
      *                   rpad(p_parameter_name, 30) ||
      *                   rpad('Allocation/Aggregation Stream not needed.', 50),
      *                       WARNING);
      */
   /* The Allo/Agg Stream is not defined but is Usable */
   elsif ((p_stream_id is null) and (l_token > 0)) then
     display_message( rpad(p_parameter_type, 31) ||
                         rpad(p_parameter_name, 30) ||
                         rpad('Allocation/Aggregation Stream should be defined.', 50),
                         ERROR);
   /* The Allo/Agg Stream is defined and is Usable */
   else
     /* check if parameter is valid. */
     open get_one_param(p_demand_plan_id, p_stream_id);
     fetch get_one_param into l_token;
     close get_one_param;
     if (l_token = 0) then
            /* Display error that the chosen allo_agg_basis_stream_name is invalid. */
            display_message( rpad(p_parameter_type, 31) ||
                         rpad(p_parameter_name, 30) ||
                         rpad('Allocation Aggregation Stream is not Defined as a Parameter', 65),
                         ERROR);
     end if;
   end if;

    if l_debug = 'Y' then
        debug_out( 'Exiting chk_ip_allo_agg ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;

Procedure chk_scen_events( p_demand_plan_id in number) is
  cursor c is
    select mev.event_name, mev.event_id, mep.product_lvl_id, mep.product_lvl_name, mep.product_lvl_val
      from msd_event_products_v mep, msd_events_v mev
    where
      mep.event_id in ((select mdse.event_id
                        from msd_dp_scenario_events mdse, msd_dp_scenarios b
                        where mdse.demand_plan_id = p_demand_plan_id
                        and mdse.scenario_id = b.scenario_id
                        and b.enable_flag = 'Y')
                        union
                       (select mde.event_id
                        from msd_dp_events_v mde
                        where mde.demand_plan_id = p_demand_plan_id))
    and
      0 = (select count(1) from msd_npi_related_products_v mnrp where mnrp.seq_id = mep.seq_id)
    and
      mep.event_id = mev.event_id
    and mev.event_type_id = '3';

Begin

  if l_debug = 'Y' then
      debug_out( 'Entering chk_scen_events ' || to_char(sysdate, 'hh24:mi:ss'));
  end if;

  display_message( 'Validating All Events contained in Demand Plan Definition', SECTION);
  display_message( rpad('Event Name', 15) || rpad('Product Level Name', 24) ||
                   rpad('Product Level Value', 24) || rpad('Description', 30), HEADING);
  display_message( '-----------------------------------------------------------------------------', HEADING);
  for token in c
  loop
    display_message(rpad(token.event_name, 24) || rpad(token.product_lvl_name, 20) || rpad(token.product_lvl_val, 20) || rpad('No Base Product for NPI', 30),ERROR);
  end loop;

  if l_debug = 'Y' then
      debug_out( 'Exiting chk_scen_events ' || to_char(sysdate, 'hh24:mi:ss'));
  end if;

End CHK_SCEN_EVENTS;

procedure chk_calendars (p_demand_plan_id in number,
                         p_calendar_type  in number,
                         p_lowest_lvl_id  in varchar2) is

l_stmt varchar2(2000);
l_start_date varchar2(2000) := 'TO_DATE(''' || TO_CHAR(l_dp_min_date,  'ddmmyyyy') || ''', ''ddmmyyyy'')';
l_end_date varchar2(2000) := 'TO_DATE(''' || TO_CHAR(l_dp_max_date,  'ddmmyyyy') || ''', ''ddmmyyyy'')';
p_date_clmn varchar2(100);
x_calendar_type varchar2(80);
x_period_type varchar2(80);
x_period_value date;
l_num_cal_codes number;

cursor c4 is
select 1
from msd_dp_calendars
where calendar_type = p_calendar_type
and demand_plan_id = p_demand_plan_id;

CURSOR c1 IS
SELECT count(1)
  FROM msd_dp_calendars
 WHERE demand_plan_id = p_demand_plan_id
   AND calendar_type = p_calendar_type;

type c_cal_type is ref cursor;
c_cal_data c_cal_type;
num_cal_codes number;
x_count number := 0;

CURSOR c2 IS
select decode(p_lowest_lvl_id,
                            '1', ' WEEK_END_DATE ',
                            '2', ' MONTH_END_DATE ',
                            '3', ' MONTH_END_DATE ',
                            '4', ' QUARTER_END_DATE ',
                            '5', ' YEAR_END_DATE ',
                            '6', ' MONTH_END_DATE ',
                            '7', ' QUARTER_END_DATE ',
                            '8', ' YEAR_END_DATE ',
                            '9', ' DAY',
                           '10', ' WEEK_END_DATE ',
                           '11', ' MONTH_END_DATE ',
                           '12', ' QUARTER_END_DATE ',
                           '13', ' YEAR_END_DATE ',
                           ' DAY ')
  from dual;

CURSOR get_meaning_1 (p_lookup_type in varchar2, p_lookup_code in varchar2) IS
select meaning
from fnd_lookup_values_vl
where lookup_type = p_lookup_type
and lookup_code = p_lookup_code;

CURSOR get_meaning_2 (p_lookup_type in varchar2, p_lookup_code in number) IS
select meaning
from fnd_lookup_values_vl
where lookup_type = p_lookup_type
and lookup_code = to_char(p_lookup_code);

begin

  if l_debug = 'Y' then
      debug_out( 'Entering chk_calendars ' || to_char(sysdate, 'hh24:mi:ss'));
  end if;

/* Get the Description fors Output */

  open get_meaning_1('MSD_CALENDAR_TYPE', to_char(p_calendar_type));
  fetch get_meaning_1 into x_calendar_type;
  if (get_meaning_1%NOTFOUND) then
    x_calendar_type := 'UNDEFINED';
  end if;
  close get_meaning_1;

  open get_meaning_2('MSD_PERIOD_TYPE', p_lowest_lvl_id);
  fetch get_meaning_2 into x_period_type;
  if (get_meaning_2%NOTFOUND) then
    x_period_type := 'UNDEFINED';
  end if;
  close get_meaning_2;


/* Only continue checking if the Minimum time level is specified. */
if (p_lowest_lvl_id is null) then
  open c1;
  fetch c1 into l_num_cal_codes;
  close c1;
  if (l_num_cal_codes >= 1) then
    display_message('Lowest Time Level is not specified for '||x_calendar_type,ERROR);
  end if;
  return;
end if;



/* Check to see if any calendars have been attached for this type.
 * Only check if the minimum time level has been specified.
 */


open c4;
fetch c4 into num_cal_codes;
close c4;
if (num_cal_codes = 1) then
  num_cal_codes := 0;
else

  display_message( rpad(x_calendar_type, 40) || rpad (x_period_type, 20) || rpad('Calendar not chosen.', 63), WARNING);
  return;
end if;

/* Only continue check if the Calendar is not Gregorian. */
/* There will always be only one Gregorian Calendar attached. */
if (p_calendar_type = 1) then
 return;
end if;

open c1;
fetch c1 into num_cal_codes;
close c1;

open c2;
fetch c2 into p_date_clmn;
close c2;

l_stmt := 'SELECT ' || p_date_clmn;
l_stmt := l_stmt || ' from msd_time ';
l_stmt := l_stmt || ' where calendar_type = ' || p_calendar_type;
l_stmt := l_stmt || ' and calendar_code in ';
l_stmt := l_stmt || '(SELECT calendar_code FROM msd_dp_calendars';
l_stmt := l_stmt || ' WHERE demand_plan_id = ' || p_demand_plan_id;
l_stmt := l_stmt || ' AND calendar_type = ' || p_calendar_type || ')';
l_stmt := l_stmt || ' AND day between ' || l_start_date || ' and ' || l_end_date;
l_stmt := l_stmt || ' group by ' || p_date_clmn|| ' having count(distinct calendar_code || ' || p_date_clmn || ') < ' || num_cal_codes;

/* display_message (substr(l_stmt,1,90), WARNING);
 *  display_message (substr(l_stmt,91,180), WARNING);
 *  display_message (substr(l_stmt,181,270), WARNING);
 *  display_message (substr(l_stmt,271,360), WARNING);
 */

x_count := 0;

   if l_debug = 'Y' then
      debug_out( l_stmt);
   end if;

open c_cal_data for l_stmt;
loop

  fetch c_cal_data into x_period_value;
  exit when c_cal_data%NOTFOUND;

  if (x_count = 0) then
        display_message('   ' ||  'Validating All the ' || x_calendar_type || ' at ' || x_period_type || ' has same bucket start and end dates.', SECTION);
    display_message( '   ' || rpad('Calendar Type', 25) || rpad ('Period Type', 20) || rpad('Description', 63), HEADING);
    display_message( '-----------------------------------------------------------------------------', HEADING);

  end if;

  x_count := x_count + 1;


  if (x_count = 10) then
    exit;
  end if;

  display_message( '    ' || rpad(x_calendar_type, 25) || rpad (x_period_type, 20) || rpad(x_period_value || ' not matched.', 63), ERROR);
end loop;

close c_cal_data;

  if l_debug = 'Y' then
      debug_out( 'Exiting chk_calendars ' || to_char(sysdate, 'hh24:mi:ss'));
  end if;


EXCEPTION
WHEN OTHERS THEN
      debug_out( substr(sqlerrm,  91, 90) );
      x_count := 1;
            while x_count<= length(l_stmt) loop
        debug_out( substr(l_stmt, x_count, 90) );
	      x_count := x_count+90;
      end loop;
End chk_calendars;

--Added for multiple composites enhancements

--
-- check composite group has the same dimension
--
Procedure chk_composite_group_dimension (p_demand_plan_id in number) is
Begin

    if l_debug = 'Y' then
       debug_out( 'Entering chk_composite_group_dimension ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking for Composites having streams with different dimensions' , SECTION);
    display_message(rpad(rpad('Composite ', 11)||'Stream Name', 101) , HEADING);
    display_message(rpad('-', 10, '-') || ' ' || rpad('-', 100, '-')|| ' ' ||rpad('-', 3, '-') , HEADING);
    --
    FOR j IN chk_comp_group(p_demand_plan_id)
    LOOP
      display_message( rpad(j.composite_group_code , 10) ||rpad(j.description, 100) , WARNING);
    END LOOP;

    if l_debug = 'Y' then
       debug_out( 'Entering chk_composite_group_dimension ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

END chk_composite_group_dimension;

--
-- check composite group has the same level
--
Procedure chk_composite_group_level (p_demand_plan_id in number) is
  lv_level_id1        msd_levels.level_id%TYPE     := 0;
  lv_level_id2        msd_levels.level_id%TYPE     := 0;
  lv_date_column_name msd_cs_defn_column_dtls.planning_view_column_name%TYPE;
  lv_previous_stream  msd_cs_definitions.name%TYPE := '##'; --Previous stream verified
  lv_level_differ     Number                       :=2; --1-Yes and 2-No

Begin

    if l_debug = 'Y' then
       debug_out( 'Entering chk_composite_group_level ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking for Composites having streams with different dimension levels' , SECTION);
    display_message( rpad('Composite ', 11)|| rpad('Stream Name', 101) , HEADING);
    display_message( rpad('-', 10, '-')    || ' ' ||rpad('-', 100, '-'), HEADING);
    --
    FOR j IN chk_comp_group_lvl(p_demand_plan_id)
    LOOP

      IF (lv_previous_stream = j.name2 AND lv_level_differ = 2) OR
         (lv_previous_stream <> j.name2) THEN

        IF j.level_id1 = -1234 THEN

          --Derive the level id from the fact tables if the level id's are not defined
          --in the stream definition(for eg.,Input Scenario)
          lv_level_id1 := get_level_id(j.view_name1,
                                      get_level_column_name(j.dim1_code,j.cs_id1),
                                      j.date_clmn1,
                                      j.start_date1,
                                      j.end_date1,
                                      j.system_flag1,
                                      j.multi_stream_flag1,
                                      j.param1,
                                      j.cs_id1,
                                      j.level_id1,
                                      j.input_demand_plan_id1,
                                      j.input_scenario_id1);
        ELSE
          lv_level_id1 := j.level_id1;
        END IF;

        IF j.level_id2 = -9999 THEN
          --Derive the level id from the fact tables if the level id's are not defined
          --in the stream definition(for eg.,Input Scenario)
          lv_level_id2 := get_level_id(j.view_name2,
                                      get_level_column_name(j.dim2_code,j.cs_id2),
                                      j.date_clmn2,
                                      j.start_date2,
                                      j.end_date2,
                                      j.system_flag2,
                                      j.multi_stream_flag2,
                                      j.param2,
                                      j.cs_id2,
                                      j.level_id2,
                                      j.input_demand_plan_id2,
                                      j.input_scenario_id2);
        ELSE
          lv_level_id2 := j.level_id2;
        END IF;

        --Level is not matching or level id is null
        IF ( (j.level_id1  <>  j.level_id2 AND
              j.level_id1  <> -1234        AND
              j.level_id2  <> -9999)       OR
             (nvl(lv_level_id1,-1234) <> nvl(lv_level_id2,-9999))) THEN

          display_message( rpad(j.composite_group_code, 10) ||rpad(j.description2, 100), WARNING);
          lv_level_differ    := 1;
        ELSE
          lv_level_differ    := 2;
        END IF;

        lv_previous_stream := j.name2;
        lv_level_id1 := 0;--resetting the level id's
        lv_level_id2 := 0;

      END IF;
    END LOOP;

    if l_debug = 'Y' then
       debug_out( 'Exiting chk_composite_group_level ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

END chk_composite_group_level;

--
-- Derives the level_id column name in the planning server view for a given
-- Dimension and stream
--
Function get_level_column_name (p_dim_code in varchar2,
                               p_cs_id in number)
return Varchar2 is

  lv_level_column_name msd_cs_defn_column_dtls.planning_view_column_name%TYPE;

Begin
  OPEN  get_lvl_column_name(p_dim_code,p_cs_id);
  FETCH get_lvl_column_name INTO lv_level_column_name;
  CLOSE get_lvl_column_name;
  RETURN lv_level_column_name;
END get_level_column_name;

--
-- Derives the level_id from the fact table
--
Function get_level_id (p_view_name          in varchar2,
                       p_View_level_col     in varchar2,
                       p_view_date_col      in varchar2,
                       p_start_date         in date,
                       p_end_date           in date,
                       p_system_flag        in Varchar2,
                       p_multi_stream_flag  in Varchar2,
                       p_parameter_name     in Varchar2,
                       p_cs_id              in Number,
                       p_call_source        in Number,
		       p_input_demand_plan_id in Number,
		       p_input_scenario_id in Number)
return Number is
  lv_level_id        msd_levels.level_id%TYPE;
  lv_sql_stmt        Varchar2(2000);
  lv_start_date      Varchar2(100);
  lv_end_date        Varchar2(100);
  lv_name      	VARCHAR2(300);--Designator Column Name in Fact Table.

  /* Index of character being printed for error messages. */
  i                   NUMBER;

  TYPE get_level_typ IS REF CURSOR;
  get_level          get_level_typ;  -- declare cursor variable

  /* Added to check if custom stream is Input Scenario */
  cursor get_cs_name (p_cs_definition_id in number) is
  select name
    from msd_cs_definitions
   where cs_definition_id = p_cs_definition_id;

  x_name varchar2(100);
  x_input_scenario varchar2(100) := 'MSD_INPUT_SCENARIO';

Begin

  lv_level_id := p_call_source;

  lv_name := get_desig_clmn_name(p_cs_id);

  open get_cs_name ( p_cs_id );
  fetch get_cs_name into x_name;
  close get_cs_name;

  lv_start_date := 'TO_DATE(''' || TO_CHAR(p_start_date,  'DD-MON-YYYY') || ''', ''DD-MON-YYYY'')';
  lv_end_date 	 := 'TO_DATE(''' || TO_CHAR(p_end_date,  'DD-MON-YYYY') || ''', ''DD-MON-YYYY'')';

  /* Input Scenario is a special case.
   * The demand plan and scenario are needed to access the index;
   * thats why they are added as filters.
   */

  if (x_name = x_input_scenario) AND
     p_input_demand_plan_id is not null AND
     p_input_scenario_id is not null AND
     lv_name is not null AND
     p_parameter_name is not null then

   lv_sql_stmt :=   'SELECT decode('||p_View_level_col || ',0,null,' || p_View_level_col || ')'
                 ||' FROM  '||p_view_name
                 ||' WHERE '||p_view_date_col||' >= '||lv_start_date
                 ||' AND   '||p_view_date_col||' <= '||lv_end_date
                 ||' AND   rownum < 2';

    lv_sql_stmt := lv_sql_stmt || ' AND demand_plan_id = ' || p_input_demand_plan_id;
    lv_sql_stmt := lv_sql_stmt || ' AND scenario_id = ' || p_input_scenario_id;
    lv_sql_stmt := lv_sql_stmt
                     ||' AND ' || lv_name || ' = '''|| replace( p_parameter_name, '''', '''''' )|| '''';

  else

    lv_sql_stmt :=   'SELECT '||p_View_level_col
                   ||' FROM  '||p_view_name
                   ||' WHERE '||p_view_date_col||' >= '||lv_start_date
                   ||' AND   '||p_view_date_col||' <= '||lv_end_date
                   ||' AND   rownum < 2'
		   ||' AND action_code <> ''D''';

    --For multiple streams check designator
    IF (nvl(p_multi_stream_flag,'N') = 'Y') AND
        lv_name           IS NOT NULL       AND
        p_parameter_name  IS NOT NULL       THEN
      lv_sql_stmt := lv_sql_stmt
                     ||' AND ' || lv_name || ' = '''|| replace( p_parameter_name, '''', '''''' ) || '''';
    END IF;

    --For Streams Defined using Custom Stream Fact Tables
    IF (p_system_flag = 'C') THEN
      lv_sql_stmt := lv_sql_stmt
                     || ' AND cs_definition_id = ' || p_cs_id;
    END IF;

  END IF;


  IF p_View_level_col IS NOT NULL AND p_view_name IS NOT NULL THEN

    if l_debug = 'Y' then
       debug_out( lv_sql_stmt);
    end if;

    OPEN  get_level FOR  lv_sql_stmt;
    FETCH get_level INTO lv_level_id;
    CLOSE get_level;
  END IF;

  RETURN lv_level_id;

EXCEPTION
  WHEN OTHERS THEN
    IF get_level%ISOPEN THEN
      CLOSE get_level;
    END IF;

    display_message( ' fact data check failed for Multiple Composites.', WARNING);
            --
    debug_out( substr(sqlerrm,  1 , 90) );
    debug_out( substr(sqlerrm,  91, 90) );

    i := 1;
    while i<= length(lv_sql_stmt)
    loop
      debug_out( substr(lv_sql_stmt, i, 90));
      i := i+90;
    end loop;

    RETURN lv_level_id;
END get_level_id;

--Added for multiple composites enhancements


-- Added for checking lowest time levels
Procedure chk_min_time      (p_g_min_tim_lvl_id in number,
                             p_m_min_tim_lvl_id in number,
                             p_f_min_tim_lvl_id in number,
                             p_c_min_tim_lvl_id in number) is
begin

    if l_debug= 'Y' then
       debug_out( 'Entering  chk_min_time   ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    display_message('Checking lowest time levels', SECTION);
    display_message('Error Description', HEADING);
    display_message(rpad('-', 60, '-'), HEADING);

    if (9 in (p_g_min_tim_lvl_id,p_m_min_tim_lvl_id,p_f_min_tim_lvl_id,p_c_min_tim_lvl_id))
       and
    ((nvl(p_g_min_tim_lvl_id,9) <> 9)
      or (nvl(p_c_min_tim_lvl_id,9) <> 9)
      or (nvl(p_f_min_tim_lvl_id,9) <> 9)
      or (nvl(p_m_min_tim_lvl_id,9) <> 9)
    ) then
       display_message('If day is chosen as a lowest time level, others can only be day too.', ERROR);
    end if;

    if l_debug = 'Y' then
       debug_out( 'Exiting  chk_min_time   ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End chk_min_time;
-- End check lowest time levels.

/* Lock the row until demand plan validation completes */

Procedure Lock_Row(p_demand_plan_id in number) Is
  Counter NUMBER;
  CURSOR C IS
  SELECT demand_plan_name
  FROM msd_demand_plans
  WHERE demand_plan_id = p_demand_plan_id
  FOR UPDATE of demand_plan_name NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     return;
   end if;

   CLOSE C;

EXCEPTION
When APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION then
  IF (C% ISOPEN) THEN
    close C;
  END IF;
  display_message('Cannot obtain a lock on this demand plan.', ERROR);
  return;
END Lock_Row;

function get_desig_clmn_name (p_cs_id in number) return VARCHAR2 IS

    CURSOR get_str_name (p_id NUMBER) IS
    SELECT planning_view_column_name
    FROM   msd_cs_defn_column_dtls_v
    WHERE  cs_definition_id = p_id
    AND    identifier_type = 'CSIDEN';

    x_str_name varchar2(30);

BEGIN

    open get_str_name (p_cs_id);
    fetch get_str_name into x_str_name;
    close get_str_name;

    if (x_str_name is null) then
      x_str_name := 'CS_NAME';
    end if;

    return x_str_name;
end;

--
-- Procedure to check that Item Validation is Collected and
-- exists in level values.
--
Procedure chk_iv_org (p_demand_plan_id in number, p_iv_flag in varchar2, p_stripe_stream_name in varchar2, p_stripe_sr_level_pk in varchar2) is

cursor get_no_iv_org is
select instance_code
  from msc_apps_instances
 where validation_org_id is null;

cursor get_iv_org is
select to_char(instance_id), to_char(validation_org_id) sr_level_pk
  from msc_apps_instances
minus
select instance, sr_level_pk
  from msd_level_values_ds
 where demand_plan_id = p_demand_plan_id
   and level_id = 7;


Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_iv_org ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    if (p_iv_flag = 'N') then

      display_message('Checking Item Validation Settings ' , SECTION);
      display_message(rpad('-', 5, '-') || rpad(' ', 64, '-'), HEADING);
      --

      -- Check to see if Item validation Org is setup for each instance.
      for get_no_iv_org_rec in get_no_iv_org
      loop
          display_message(rpad(get_no_iv_org_rec.instance_code, 5) || ' ' ||
                          rpad('Item Validation Org not collected in this Instance.', 64), WARNING);
      end loop;

      if ((p_stripe_stream_name is not null) or (p_stripe_sr_level_pk is not null)) then
        for get_iv_org_rec in get_iv_org
        loop
          display_message(rpad('Not all Item Validation Orgs found in Demand Partition.', 64), WARNING);
          exit;
        end loop;
      end if;

      if l_debug = 'Y' then
          debug_out( 'Exiting chk_iv_org ' || to_char(sysdate, 'hh24:mi:ss'));
      end if;
    end if;

End;

Procedure chk_iso_org (p_demand_plan_id in number)
is

cursor is_plan_lob (p_demand_plan_id number)
is
select stripe_level_id,build_stripe_stream_name
from msd_demand_plans
where demand_plan_id = p_demand_plan_id;

cursor invalid_internal_orgs (p_demand_plan_id number)
is
select mdio.sr_organization_id, mlv.level_value
from msd_dp_iso_organizations mdio,
    -- msd_level_values_ds geo,
     msd_level_values_ds org,
     msd_level_values mlv
where mdio.demand_plan_id = p_demand_plan_id
and mdio.demand_plan_id = org.demand_plan_id
and mdio.sr_instance_id = org.instance
--and geo.level_id = 15
--and geo.system_attribute1 = 'I'
and org.sr_level_pk = mdio.sr_organization_id
and org.level_id = 7
--and org.instance = geo.instance
--and org.demand_plan_id = geo.demand_plan_id
--and org.sr_level_pk = geo.sr_level_pk
and mlv.instance = org.instance
and mlv.sr_level_pk = org.sr_level_pk
and mlv.level_id = org.level_id;

Recinfo invalid_internal_orgs%ROWTYPE;
Rec_is_plan_lob is_plan_lob%ROWTYPE;

l_flag  BOOLEAN := FALSE;
l_flag1 BOOLEAN := FALSE;

Begin

    if l_debug = 'Y' then
        debug_out( 'Entering chk_iso_org ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

    open is_plan_lob(p_demand_plan_id);
     fetch is_plan_lob INTO Rec_is_plan_lob;
      if (is_plan_lob%NOTFOUND) then
        debug_out( 'Plan is not striped.The Internal organizations attached to plan (if any) will not be considered.');
      else
        l_flag := TRUE;
      end if;
    close is_plan_lob;

    if l_flag then

    display_message('Checking any Internal Organizations attached are also part of Plan Scope' , SECTION);
    display_message(rpad('Organization', 36) || rpad('Error description', 55) , HEADING);
    display_message(rpad('-', 35, '-') || ' ' || rpad('-', 55, '-') , HEADING);

    open invalid_internal_orgs (p_demand_plan_id);
    loop
    fetch invalid_internal_orgs INTO Recinfo;

      if (invalid_internal_orgs%NOTFOUND) then

         if l_flag1 then
          null;
         else
          debug_out( 'None of the Internal Organizations attached are included in plan scope');
         end if;

         exit;

      else

        l_flag1 := TRUE;
        display_message( rpad(Recinfo.level_value , 36) || rpad('This internal organization already exists in the plan.', 55)  , WARNING);


      end if;
    end loop;

    close invalid_internal_orgs;

    end if;


    if l_debug = 'Y' then
          debug_out( 'Exiting chk_iso_org ' || to_char(sysdate, 'hh24:mi:ss'));
    end if;

End;

   /* Bug# 5248868
    * This procedure validates that whether price list data exists
    * for the price lists specified in the demand plan.
    * Note: Only time range validation is done
    */
   PROCEDURE chk_price_list_data 	(p_demand_plan_id IN NUMBER)
   IS

      /*
       * Get all the price lists specified in the price list tab of the
       * demand plan.
       */
      CURSOR c_get_price_lists
      IS
         SELECT
            price_list_name
         FROM
            msd_dp_price_lists
         WHERE
            demand_plan_id = p_demand_plan_id;

      /*
       * Get all the scenarios to which price lists are attached
       */
      CURSOR c_get_scen_with_price_lists
      IS
         SELECT
            scenario_id,
            scenario_name,
            horizon_start_date,
            horizon_end_date,
            price_list_name
         FROM
            msd_dp_scenarios
         WHERE
                demand_plan_id = p_demand_plan_id
            AND price_list_name IS NOT NULL;

      /*
       * Get all the input parameters to which price lists are attached
       */
      CURSOR c_get_param_with_price_lists
      IS
         SELECT
            mdp.parameter_id,
            mdp.parameter_type_id,
            mdp.parameter_type,
            mdp.parameter_name,
            mdp.multiple_stream_flag,
            mdp.forecast_date_used,
            mdp.date_planning_view_clmn,
            mdp.start_date,
            mdp.end_date,
            mdp.price_list_name
         FROM
            msd_dp_parameters_cs_v mdp
         WHERE  mdp.demand_plan_id = p_demand_plan_id
            AND	mdp.parameter_type_id <> '7'
            AND nvl(mdp.stream_type,'ABCD') not in ('ARCHIVED','ARCHIVED_TIM','CALCULATED','PLACEHOLDER')
            AND mdp.price_list_name IS NOT NULL;

      X_MIN_DATE              DATE := to_date ('01-01-1000', 'DD-MM-YYYY');
      X_MAX_DATE              DATE := to_date ('01-01-4000', 'DD-MM-YYYY');

      x_price_list_data_found NUMBER := -1;

   BEGIN

      IF l_debug = 'Y' THEN
          debug_out( 'Entering chk_price_list_data ' || to_char(sysdate, 'hh24:mi:ss'));
      END IF;

      /* Titles for each Price list in the Log File */
      display_message( 'Validating Price List Data', SECTION);
      display_message( rpad('Price List Name', 24) || 'Start Date End Date   Error Description', HEADING);
      display_message( rpad('-', 23, '-') || ' ' || '---------- ---------- -----------------------------------', HEADING);

      /* Loop through for each price list specified in the price lists tab of the demand plan */
      FOR c_price_list_rec IN c_get_price_lists
      LOOP

         x_price_list_data_found := -1;

         BEGIN

            SELECT 1
               INTO x_price_list_data_found
               FROM dual
               WHERE EXISTS (SELECT 1
                                FROM msd_price_list_v
                                WHERE  price_list_name = c_price_list_rec.price_list_name
                                   AND (   (    nvl(start_date, X_MIN_DATE) <= l_dp_min_date
                                            AND nvl(end_date,   X_MAX_DATE) >= l_dp_min_date)
                                        OR (    nvl(start_date, X_MIN_DATE) >= l_dp_min_date
                                            AND nvl(end_date,   X_MAX_DATE) <= l_dp_max_date)
                                        OR (    nvl(start_date, X_MIN_DATE) <= l_dp_max_date
                                            AND nvl(end_date,   X_MAX_DATE) >= l_dp_max_date))
                                  AND rownum < 2);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_price_list_data_found := -1;

         END;

         IF (x_price_list_data_found = -1) THEN

             display_message( rpad(c_price_list_rec.price_list_name, 23) || ' ' ||
			            to_char(l_dp_min_date, 'DD-MM-YYYY') || ' ' ||
			            to_char(l_dp_max_date, 'DD-MM-YYYY') || ' ' ||
				      ' Price list data does not exist', WARNING);

         END IF;


      END LOOP;


      /* Titles for each Scenario with price list in the Log File */
      display_message( 'Validating Price List Data for Scenarios', SECTION);
      display_message( rpad ('Scenario Name', 18) || rpad('Price List Name', 18) || 'Start Date End Date   Error Description', HEADING);
      display_message( rpad('-', 17, '-') || ' ' || rpad('-', 17, '-') || ' ' || '---------- ---------- --------------------------------', HEADING);

      /* Loop through for each scenario for which price list is specified */
      FOR c_scn_with_pls IN c_get_scen_with_price_lists
      LOOP

         x_price_list_data_found := -1;

         BEGIN

            SELECT 1
               INTO x_price_list_data_found
               FROM dual
               WHERE EXISTS (SELECT 1
                                FROM msd_price_list_v
                                WHERE  price_list_name = c_scn_with_pls.price_list_name
                                   AND (   (    nvl(start_date, X_MIN_DATE) <= c_scn_with_pls.horizon_start_date
                                            AND nvl(end_date,   X_MAX_DATE) >= c_scn_with_pls.horizon_start_date)
                                        OR (    nvl(start_date, X_MIN_DATE) >= c_scn_with_pls.horizon_start_date
                                            AND nvl(end_date,   X_MAX_DATE) <= c_scn_with_pls.horizon_end_date)
                                        OR (    nvl(start_date, X_MIN_DATE) <= c_scn_with_pls.horizon_end_date
                                            AND nvl(end_date,   X_MAX_DATE) >= c_scn_with_pls.horizon_end_date))
                                  AND rownum < 2);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_price_list_data_found := -1;

         END;

         IF (x_price_list_data_found = -1) THEN

             display_message(                   rpad(c_scn_with_pls.scenario_name, 17) || ' ' ||
                                              rpad(c_scn_with_pls.price_list_name, 17) || ' ' ||
			      to_char(c_scn_with_pls.horizon_start_date, 'DD-MM-YYYY') || ' ' ||
			        to_char(c_scn_with_pls.horizon_end_date, 'DD-MM-YYYY') || ' ' ||
				           ' Price list data does not exist', WARNING);

         END IF;

      END LOOP;


      /* Titles for each Parameter with price list in the Log File */
      display_message( 'Validating Price List Data for Input Parameters', SECTION);
      display_message( rpad ('Parameter Name', 18) || rpad('Price List Name', 18) || 'Start Date End Date   Error Description', HEADING);
      display_message( rpad('-', 17, '-') || ' ' || rpad('-', 17, '-') || ' ' || '---------- ---------- --------------------------------', HEADING);

      /* Loop through for each parameter for which price list is specified */
      FOR c_param_with_pls IN c_get_param_with_price_lists
      LOOP

         x_price_list_data_found := -1;

         BEGIN

            SELECT 1
               INTO x_price_list_data_found
               FROM dual
               WHERE EXISTS (SELECT 1
                                FROM msd_price_list_v
                                WHERE  price_list_name = c_param_with_pls.price_list_name
                                   AND (   (    nvl(start_date, X_MIN_DATE) <= c_param_with_pls.start_date
                                            AND nvl(end_date,   X_MAX_DATE) >= c_param_with_pls.start_date)
                                        OR (    nvl(start_date, X_MIN_DATE) >= c_param_with_pls.start_date
                                            AND nvl(end_date,   X_MAX_DATE) <= c_param_with_pls.end_date)
                                        OR (    nvl(start_date, X_MIN_DATE) <= c_param_with_pls.end_date
                                            AND nvl(end_date,   X_MAX_DATE) >= c_param_with_pls.end_date))
                                  AND rownum < 2);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x_price_list_data_found := -1;

         END;

         IF (x_price_list_data_found = -1) THEN

             display_message(                   rpad(c_param_with_pls.parameter_type, 17) || ' ' ||
                                              rpad(c_param_with_pls.price_list_name, 17) || ' ' ||
			      to_char(c_param_with_pls.start_date, 'DD-MM-YYYY') || ' ' ||
			        to_char(c_param_with_pls.end_date, 'DD-MM-YYYY') || ' ' ||
				           ' Price list data does not exist', WARNING);

             IF nvl(c_param_with_pls.multiple_stream_flag,'N') = 'Y' THEN
                  display_message(' (' ||  replace(c_param_with_pls.parameter_name, '''', '''''') ||
                                  '):' || nvl(nvl(c_param_with_pls.forecast_date_used, c_param_with_pls.date_planning_view_clmn),' '), INFORMATION);
             ELSE
                  display_message(' :' || nvl(nvl(c_param_with_pls.forecast_date_used, c_param_with_pls.date_planning_view_clmn),' '), INFORMATION);
             END IF;

         END IF;


      END LOOP;

      IF l_debug = 'Y' THEN
         debug_out( 'Exiting chk_price_list_data ' || to_char(sysdate, 'hh24:mi:ss'));
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         show_message('    Exiting chk_price_list_data with ERROR - ');
         show_message(substr( sqlerrm, 1, 80));

   END chk_price_list_data;

End;

/
