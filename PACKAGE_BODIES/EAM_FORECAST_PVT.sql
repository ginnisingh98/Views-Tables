--------------------------------------------------------
--  DDL for Package Body EAM_FORECAST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_FORECAST_PVT" AS
/* $Header: EAMVFORB.pls 120.19.12010000.2 2008/11/20 10:56:46 vmec ship $ */
    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'EAM_FOREACST_PVT';
    G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    G_FILE_NAME CONSTANT VARCHAR2(30) := 'EAMVFORB.pls';
  -- TODO: Propagate OA required parameters back to the top level
  -- extract_forecast ....eg api_version, status...is this required?

--------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   Historical_WO_Costs                                                  --
--                                                                        --
-- DESCRIPTION                                                            --
--   This API is part of the backend support for Maintenance and          --
--   Budgeting project.                                                   --
--                                                                        --
--   This API determines the historical cost and account information of a --
--   work order and passes the record back to the calling program.        --
--                                                                        --
--   It is called from the Maintenance and Budgeting engine, to detemine  --
--   costs of Historical Type Forecats. The calling program will insert   --
--   values passed by this API into EAM_FORECASTS_CEBBA table.            --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 12                                           --
--                                                                        --
-- HISTORY:                                                               --
--    04/20/05     Anju Gupta       Created                               --
----------------------------------------------------------------------------

PROCEDURE Get_HistoricalCosts (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_id      IN  NUMBER,
                     p_organization_id  IN  NUMBER,
                     p_wip_entity_id    IN  NUMBER,
                     p_account_from     IN  VARCHAR2,
                     p_account_to       IN  VARCHAR2,
                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,


                     x_hist_cost_tbl      OUT NOCOPY eam_wo_relations_tbl_type,
                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2) IS

 l_api_name    CONSTANT       VARCHAR2(30) := 'Get_HistoricalCosts';
 l_api_version CONSTANT       NUMBER       := 1.0;

 l_msg_count                 NUMBER := 0;
 l_msg_data                  VARCHAR2(8000) := '';


 l_stmt_num                  NUMBER   := 0;
 l_error_num                 NUMBER   := 0;
 l_err_code                  VARCHAR2(240) := '';
 l_err_msg                   VARCHAR2(240) := '';

 l_forecast_rec              eam_forecast_rec_type;
 l_def_eam_cost_element_id   NUMBER := 0;
 l_cnt                       NUMBER := 0;

 CURSOR c_efcebba (p_def_eam_cost_element_id number) IS

 SELECT
   wepb.period_set_name,
   wepb.period_name,
   wepb.acct_period_id,
   wepb.operations_dept_id,
   cdv.operation_seq_num,
   wepb.maint_cost_category,
   wepb.owning_dept_id,
   cdv.reference_account,
   decode(cdv.cost_element,
          'Material', 1,
          'Resource', 3,
          'Material Overhead', 2,
          'Outside Processing', 5,
          'Overhead', 4) mfg_cost_element,
   decode(nvl(cdv.resource_seq_num, -1),
             -1, 3,
             decode((SELECT resource_type
                    FROM bom_resources br, wip_operation_resources wor
                    WHERE br.resource_id = wor.resource_id
                    AND wor.wip_ENTITY_ID = cdv.wip_entity_id
                    AND wor.operation_seq_num = cdv.operation_seq_num
                    AND wor.resource_seq_num = cdv.resource_seq_num),
                    1, 1, 2, 2, p_def_eam_cost_element_id)
                    ) as txn_type,
   oap.period_start_date,
   oap.period_num,
   oap.period_year,
   (cdv.base_transaction_value)as value
   FROM cst_distribution_lite_v cdv, wip_eam_period_balances wepb, org_acct_periods oap,
   mfg_lookups mf
   WHERE cdv.operation_seq_num is not null
   and mf.lookup_type = 'CST_ACCOUNTING_LINE_TYPE'
   and mf.lookup_code in (7,8)
   and mf.meaning = cdv.line_type_name
   AND wepb.wip_entity_id = cdv.wip_entity_id
   AND wepb.operation_seq_num  = cdv.operation_seq_num
   AND wepb.acct_period_id = cdv.acct_period_id
   AND oap.acct_period_id = cdv.acct_period_id
   AND oap.organization_id = cdv.organization_id
   AND cdv.wip_entity_id = p_wip_entity_id
   --AND cdv.organization_id = p_organization_id	Bug#5632148
   AND (p_account_from is null or
        cdv.reference_account in (
            SELECT code_combination_id from gl_code_combinations glcc
            where fnd_flex_ext.get_segs('SQLGL', 'GL#',
glcc.chart_of_accounts_id, glcc.code_combination_id) >= p_account_from
            AND fnd_flex_ext.get_segs('SQLGL', 'GL#', glcc.chart_of_accounts_id,
glcc.code_combination_id) <= p_account_to))
UNION ALL
SELECT
   oap.period_set_name,
   oap.period_name,
   oap.acct_period_id,
   null,
   cdv.operation_seq_num,
   ep.def_maint_cost_category,
   wdj.owning_department,
   cdv.reference_account,
   decode(cdv.cost_element,
          'Material', 1,
          'Resource', 3,
          'Material Overhead', 2,
          'Outside Processing', 5,
          'Overhead', 4) mfg_cost_element,
   null txn_type,
   oap.period_start_date,
   oap.period_num,
   oap.period_year,
   (cdv.base_transaction_value) value
   FROM cst_distribution_lite_v cdv, org_acct_periods oap, wip_discrete_jobs wdj,
   wip_eam_parameters ep, mfg_lookups mf
   WHERE ep.organization_id = cdv.organization_id
   and cdv.wip_entity_id = wdj.wip_entity_id
   and cdv.organization_id = wdj.organization_id
   and cdv.operation_seq_num is null
   and mf.lookup_type = 'CST_ACCOUNTING_LINE_TYPE'
   and mf.lookup_code in (7,8)
   and mf.meaning = cdv.line_type_name
   AND oap.acct_period_id = cdv.acct_period_id
   AND oap.organization_id = cdv.organization_id
   AND cdv.wip_entity_id = p_wip_entity_id
   --AND cdv.organization_id = p_organization_id	Bug#5632148
   AND (p_account_from is null or
        cdv.reference_account in (
            SELECT code_combination_id from gl_code_combinations glcc
            where fnd_flex_ext.get_segs('SQLGL', 'GL#',
glcc.chart_of_accounts_id, glcc.code_combination_id) >= p_account_from
            AND fnd_flex_ext.get_segs('SQLGL', 'GL#', glcc.chart_of_accounts_id,
glcc.code_combination_id) <= p_account_to));

begin

    -------------------------------------------------------------------------
    -- Establish savepoint
    -------------------------------------------------------------------------

    SAVEPOINT HistoricalCosts_PVT;

    -------------------------------------------------------------------------
    -- standard call to check for call compatibility
    -------------------------------------------------------------------------
    IF NOT fnd_api.compatible_api_call (
                              l_api_version,
                              p_api_version,
                              l_api_name,
                              G_PKG_NAME ) then

         RAISE fnd_api.g_exc_unexpected_error;

    END IF;

   ---------------------------------------------------------------------------
   -- Initialize message list if p_init_msg_list is set to TRUE
   ---------------------------------------------------------------------------

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;


    -------------------------------------------------------------------------
    -- initialize api return status to success
    -------------------------------------------------------------------------

      l_stmt_num := 10;
      x_return_status := fnd_api.g_ret_sts_success;


    -------------------------------------------------------------------------
    /*-- Determine the dates for the periods of interest
    -------------------------------------------------------------------------

      select oap.period_start_date
      into l_period_from
      from org_acct_periods oap
      where organization_id = p_org_id
      and acct_period_id = p_acct_period_from;

      select nvl(oap.period_close_date, oap.SCHEDULE_CLOSE_DATE)
      into l_period_to
      from org_acct_periods oap
      where organization_id = p_org_id
      and acct_period_id = p_acct_period_to; */

    -------------------------------------------------------------------------
    -- Get the Default EAM cost element id for this organization
    -------------------------------------------------------------------------
    l_stmt_num := 20;

    SELECT def_eam_cost_element_id
    INTO l_def_eam_cost_element_id
    FROM wip_eam_parameters
    WHERE organization_id = p_organization_id;

    -------------------------------------------------------------------------
    -- Initialize common variables
    -------------------------------------------------------------------------

     l_stmt_num := 30;

     l_forecast_rec.WIP_ENTITY_ID        :=  p_wip_entity_id;
     l_forecast_rec.ORGANIZATION_ID      :=  p_organization_id;
     l_forecast_rec.forecast_id          :=  p_forecast_id;

     l_forecast_rec.LAST_UPDATE_DATE     :=  sysdate;
     l_forecast_rec.LAST_UPDATED_BY      :=  p_user_id;
     l_forecast_rec.CREATION_DATE        :=  sysdate;
     l_forecast_rec.CREATED_BY           :=  p_user_id;
     l_forecast_rec.LAST_UPDATE_LOGIN    :=  p_user_id;
     l_forecast_rec.REQUEST_ID           :=  p_request_id;
     l_forecast_rec.PROGRAM_APPLICATION_ID   := p_prog_app_id;
     l_forecast_rec.PROGRAM_ID           :=  p_prog_id;
     l_forecast_rec.PROGRAM_UPDATE_DATE  := sysdate;

    l_cnt := 1;

    -------------------------------------------------------------------------
    -- Get the Historical Cost Information for the Work Order
    -------------------------------------------------------------------------

     l_stmt_num := 40;


    FOR c_efcebba_rec IN c_efcebba (l_def_eam_cost_element_id)
    LOOP


            l_forecast_rec.PERIOD_SET_NAME      :=  c_efcebba_rec.period_set_name;
            l_forecast_rec.PERIOD_NAME          :=  c_efcebba_rec.period_name;

            l_forecast_rec.ACCT_PERIOD_ID       :=  c_efcebba_rec.acct_period_id;
            l_forecast_rec.OPERATIONS_DEPT_ID   :=  c_efcebba_rec.operations_dept_id;
            l_forecast_rec.OPERATION_SEQ_NUM    :=  c_efcebba_rec.operation_seq_num;
            l_forecast_rec.MAINT_COST_CATEGORY  :=  c_efcebba_rec.maint_cost_category;
            l_forecast_rec.OWNING_DEPT_ID       :=  c_efcebba_rec.owning_dept_id;
            l_forecast_rec.ACCT_VALUE           :=  c_efcebba_rec.value;
            l_forecast_rec.TXN_TYPE             :=  c_efcebba_rec.txn_type;


            l_forecast_rec.PERIOD_START_DATE    :=  c_efcebba_rec.period_start_date;
            l_forecast_rec.CCID                 :=  c_efcebba_rec.reference_account;
            l_forecast_rec.MFG_COST_ELEMENT_ID  :=  c_efcebba_rec.mfg_cost_element;
            l_forecast_rec.PERIOD_YEAR          :=  c_efcebba_rec.period_year;
            l_forecast_rec.PERIOD_NUM           :=  c_efcebba_rec.period_num;

                x_hist_cost_tbl(l_cnt) := l_forecast_rec;

                l_cnt := l_cnt + 1;

    END LOOP;

        l_stmt_num := 50;

    ---------------------------------------------------------------------------
    -- Standard Call to get message count and if count = 1, get message info
    ---------------------------------------------------------------------------

    FND_MSG_PUB.Count_And_Get (
        p_count     => x_msg_count,
        p_data      => x_msg_data );

   EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );
      --
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
        THEN
         fnd_msg_pub.add_exc_msg
           (  'EAM_HistoricalCosts_PVT'
              , 'Get_HistoricalCosts : l_stmt_num - '||to_char(l_stmt_num)
              );

     END IF;
        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
             );


end Get_HistoricalCosts;

procedure delete_work_order(p_forecast_id IN number, p_wip_id IN number)IS

BEGIN
delete from eam_forecast_wdj where
forecast_id = p_forecast_id
AND wip_entity_id = p_wip_id;

delete from eam_forecast_wo
where forecast_id = p_forecast_id
AND wip_entity_id = p_wip_id;

delete from eam_forecast_wor
where forecast_id = p_forecast_id
AND wip_entity_id = p_wip_id;

delete from eam_forecast_wro
where forecast_id = p_forecast_id
AND wip_entity_id = p_wip_id;

delete from eam_forecast_wedi
where forecast_id = p_forecast_id
AND wip_entity_id = p_wip_id;

delete from eam_forecast_cebba
where forecast_id = p_forecast_id
AND wip_entity_id = p_wip_id;

end delete_work_order;

procedure delete_forecast(p_forecast_id IN number)IS

BEGIN

delete from eam_forecasts where
forecast_id = p_forecast_id;

delete from eam_forecast_wdj where
forecast_id = p_forecast_id;

delete from eam_forecast_wo
where forecast_id = p_forecast_id;

delete from eam_forecast_wor
where forecast_id = p_forecast_id;

delete from eam_forecast_wro
where forecast_id = p_forecast_id;

delete from eam_forecast_wedi
where forecast_id = p_forecast_id;

delete from eam_forecast_cebba
where forecast_id = p_forecast_id;

end delete_forecast;

procedure delete_forecast_data(p_forecast_id IN number)IS

BEGIN

delete from eam_forecast_wdj where
forecast_id = p_forecast_id;

delete from eam_forecast_wo
where forecast_id = p_forecast_id;

delete from eam_forecast_wor
where forecast_id = p_forecast_id;

delete from eam_forecast_wro
where forecast_id = p_forecast_id;

delete from eam_forecast_wedi
where forecast_id = p_forecast_id;

delete from eam_forecast_cebba
where forecast_id = p_forecast_id;

end delete_forecast_data;

  procedure Generate_Forecast(
              errbuf           out NOCOPY varchar2,
              retcode          out NOCOPY varchar2,
              p_forecast_id    IN number) is

    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(8000) := '';
    l_return_status             VARCHAR2(2000);
    l_forecast_id               NUMBER;
  BEGIN

    delete_forecast_data(p_forecast_id);
    commit;

    Extract_Forecast(
        p_api_version => 1.0,
        p_commit => FND_API.G_TRUE,
        p_debug => 'N',

        p_forecast_id => p_forecast_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

   update eam_forecasts
   set completion_date = SYSDATE
   where forecast_id = p_forecast_id;


END Generate_Forecast;



  /* This is a private PROCEDURE that extracts a historical forecast */

  PROCEDURE debug(l_msg IN VARCHAR2, l_level IN NUMBER := 1)IS
  l_n NUMBER;
  l_log_level         CONSTANT NUMBER := fnd_log.g_current_runtime_level;
  l_uLog              CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
  l_sLog              CONSTANT BOOLEAN := l_uLog AND fnd_log.level_statement >= l_log_level;

  BEGIN
  IF(l_level >= 1)
  THEN
    IF( l_sLog ) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
         'eam.plsql.EAM_FORECAST_PVT.extract_forecast',l_msg);
  --	dbms_OUTPUT.put_line('DEBUG:: ' || l_msg);
	l_n := 1;
    END IF;
  END IF;
  END debug;


  FUNCTION get_asset_cursor(p_forecast_rec eam_forecasts%rowtype)
    RETURN forecast_asset_cursor_type
  IS

  BEGIN
    return get_asset_cursor(p_forecast_rec.organization_id,
                      p_forecast_rec.asset_num_from,
                      p_forecast_rec.asset_num_to,
                      p_forecast_rec.asset_serial_num_from,
                      p_forecast_rec.asset_serial_num_to,
                      p_forecast_rec.asset_group_from,
                      p_forecast_rec.asset_group_to,
                      p_forecast_rec.area_from,
                      p_forecast_rec.area_to);
  END get_asset_cursor;


  FUNCTION get_wip_table(p_forecast_rec eam_forecasts%rowtype)
    RETURN wo_table_type
  IS
    --
    TYPE wo_cursor IS REF CURSOR;
    TYPE wo_table IS table of number index by binary_integer;
    l_wip_cursor wo_cursor;
    l_wip_table wo_table_type;
    l_start_date DATE;
    l_end_date DATE;
    l_asset_query BOOLEAN;



    -- worst case, historical must include asset information/query
    l_sql VARCHAR2(8010);


    l_sql_select VARCHAR2(1000);
    l_sql_from VARCHAR2(4500);
    l_sql_where VARCHAR2(2500);


  BEGIN
    debug('Getting wo table');
    --_OUTPUT.enable(1000000);
    -- Get the start date and end date information for the forecast

    l_asset_query := false;

    SELECT glp.start_date
    INTO l_start_date
    FROM gl_periods glp
    WHERE glp.period_name = p_forecast_rec.period_from
          AND glp.period_set_name = p_forecast_rec.period_set_name_from;

    debug('Start date is ' || l_start_date);

    SELECT glp.end_date
    INTO l_end_date
    FROM gl_periods glp
    WHERE glp.period_name = p_forecast_rec.period_to
          AND glp.period_set_name = p_forecast_rec.period_set_name_to;

    debug('End date is ' || l_end_date);

    l_sql_select := 'SELECT wdj.wip_entity_id ';
    l_sql_from   := 'FROM wip_discrete_jobs wdj ';
    l_sql_where  := 'WHERE ';

    debug('Select stmt: ' || l_sql_select);
    debug('FROM stmt: ' || l_sql_from);
    debug('WHERE stmt: ' || l_sql_where);



    IF p_forecast_rec.include_transacted = 'Y'
    THEN
            -- A historical forecast, must be driven by assets if transacted
            --flag has been checked
            l_sql_where := l_sql_where || ':organization_id IS NOT NULL ' ||
                'AND :creation_date IS NOT NULL ';


    ELSE
        --Default case, organization_id is first selection criteria
        l_sql_where := l_sql_where || 'wdj.organization_id = :organization_id ';
        IF p_forecast_rec.forecast_type = 4
        THEN
            l_sql_where := l_sql_where || 'AND wdj.creation_date >= :creation_date ';
        ELSE
            l_sql_where := l_sql_where || 'AND :creation_date IS NOT NULL ';
        END IF;
    END IF;

        --Add the PM criteria

        -- Use asset criteria only if specified, OR If include transacted
        IF (p_forecast_rec.asset_num_from IS NOT NULL OR
            p_forecast_rec.asset_num_to IS NOT NULL OR
            p_forecast_rec.asset_group_from IS NOT NULL OR
            p_forecast_rec.asset_group_to IS NOT NULL OR
            p_forecast_rec.asset_serial_num_from IS NOT NULL OR
            p_forecast_rec.asset_serial_num_to IS NOT NULL OR
            p_forecast_rec.include_transacted = 'Y') AND
            p_forecast_rec.forecast_type <> 4
        THEN
             l_sql_from := l_sql_from || ',(' ||
                        get_asset_query(p_forecast_rec) || ') assets ';
             l_sql_where := l_sql_where ||
                        'AND wdj.maintenance_object_id = assets.asset_id ' ||
                        'AND wdj.maintenance_object_type = assets.asset_type ';
             l_asset_query := true;
	-- Must be an eAM wip entry
	ELSE

             l_sql_where := l_sql_where ||
                        'AND wdj.maintenance_object_id IS NOT NULL ';
        END IF;

        IF p_forecast_rec.forecast_type IN(1,2,4)
        THEN


            IF p_forecast_rec.forecast_type = 2
            THEN
                l_sql_where := l_sql_where ||
                        'AND wdj.PM_SCHEDULE_ID IS NULL ';
            ELSE
                l_sql_where := l_sql_where ||
                        'AND wdj.PM_SCHEDULE_ID IS NOT NULL ';
            END IF;

        END IF;


        --Add start date and end date criteria

        l_sql_where := l_sql_where ||
                         'AND wdj.scheduled_completion_date >= :start_date ' ||
                         'AND wdj.scheduled_start_date <= :end_date ';

        -- WO Number Criteria

        IF p_forecast_rec.work_order_from IS NOT NULL AND
            p_forecast_rec.work_order_to IS NOT NULL
        THEN

            l_sql_from := l_sql_from ||
                ',wip_entities we ';
            l_sql_where := l_sql_where ||
            'AND wdj.wip_entity_id = we.wip_entity_id ' ||
            'AND we.wip_entity_name >= :wo_from ' ||
            'AND we.wip_entity_name <= :wo_to ';
        ELSE

            l_sql_where := l_sql_where ||
            'AND (:wo_from IS NULL OR :wo_to IS NULL) ';


        END IF;


        -- WO Type Criteria

        IF p_forecast_rec.work_order_type_from IS NOT NULL AND
            p_forecast_rec.work_order_type_to IS NOT NULL
        THEN

            l_sql_where := l_sql_where ||
            'AND wdj.work_order_type >= :wo_type_from ' ||
            'AND wdj.work_order_type <= :wo_type_to ';
        ELSE

            l_sql_where := l_sql_where ||
            'AND (:wo_type_from IS NULL OR :wo_type_to IS NULL) ';

        END IF;


        -- WAC criteria

        IF p_forecast_rec.wip_acct_class_from IS NOT NULL AND
            p_forecast_rec.wip_acct_class_to IS NOT NULL
        THEN
            l_sql_where := l_sql_where ||
            'AND wdj.class_code >= :wac_from ' ||
            'AND wdj.class_code <= :wac_to ';
        ELSE
            l_sql_where := l_sql_where ||
            'AND (:wac_from IS NULL OR :wac_to IS NULL) ';
        END IF;


        -- Activity Criteria

        IF p_forecast_rec.activity_from IS NOT NULL AND
            p_forecast_rec.activity_to IS NOT NULL
        THEN
            l_sql_from := l_sql_from ||
                ',mtl_system_items_b_kfv msi ';
            l_sql_where := l_sql_where ||
            'AND msi.organization_id = wdj.organization_id ' ||
            'AND msi.inventory_item_id = wdj.primary_item_id ' ||
            'AND msi.eam_item_type(+) = 2 ' ||
            'AND msi.concatenated_segments >= :activity_from ' ||
            'AND msi.concatenated_segments <= :activity_to ';
        ELSE
            l_sql_where := l_sql_where ||
            'AND (:activity_from IS NULL OR :activity_to IS NULL) ';
        END IF;


        -- Department criteria

        IF p_forecast_rec.department_from IS NOT NULL AND
            p_forecast_rec.department_to IS NOT NULL
        THEN
            l_sql_from := l_sql_from ||
                ',bom_departments bd ';
            l_sql_where := l_sql_where ||
            'AND bd.department_id (+) = wdj.owning_department ' ||
            'AND bd.department_code >= :department_from ' ||
            'AND bd.department_code <= :department_to ';
        ELSE
            l_sql_where := l_sql_where ||
            'AND (:department_from IS NULL OR :department_to IS NULL) ';
        END IF;

        -- Project criteria

        IF p_forecast_rec.project_from IS NOT NULL AND
            p_forecast_rec.project_to IS NOT NULL
        THEN
            l_sql_from := l_sql_from ||
                ',pa_projects pp ';
            l_sql_where := l_sql_where ||
            'AND pp.project_id (+) = wdj.project_id ' ||
            'AND pp.name >= :project_from ' ||
            'AND pp.name <= :project_to ';
        ELSE
            l_sql_where := l_sql_where ||
            'AND (:project_from IS NULL OR :project_to IS NULL) ';
        END IF;


        -- Concatenate the clauses

        l_sql := l_sql_select || l_sql_from || l_sql_where;

        debug('Inserting sql');
	/*
	dbms_output.put_line(SUBSTR(l_sql,1,250));
        dbms_output.put_line(SUBSTR(l_sql,250,250));
        dbms_output.put_line(SUBSTR(l_sql,500,250));
        dbms_output.put_line(SUBSTR(l_sql,750,250));
	*/

	IF l_asset_query = true
        THEN

          debug('Opening cursor');

         OPEN l_wip_cursor for l_sql USING

                      p_forecast_rec.organization_id,
                      p_forecast_rec.asset_num_from,
                      p_forecast_rec.asset_num_to,
                      p_forecast_rec.asset_serial_num_from,
                      p_forecast_rec.asset_serial_num_to,
                      p_forecast_rec.asset_group_from,
                      p_forecast_rec.asset_group_to,
                      p_forecast_rec.area_from,
                      p_forecast_rec.area_to,
                      p_forecast_rec.organization_id,
                      p_forecast_rec.asset_group_from,
                      p_forecast_rec.asset_group_to,

                      p_forecast_rec.organization_id,
                      p_forecast_rec.creation_date,
                      l_start_date,
                      l_end_date,
                      p_forecast_rec.work_order_from,
                      p_forecast_rec.work_order_to,
                      p_forecast_rec.work_order_type_from,
                      p_forecast_rec.work_order_type_to,
                      p_forecast_rec.wip_acct_class_from,
                      p_forecast_rec.wip_acct_class_to,
                      p_forecast_rec.activity_from,
                      p_forecast_rec.activity_to,
                      p_forecast_rec.department_from,
                      p_forecast_rec.department_to,
                      p_forecast_rec.project_from,
                      p_forecast_rec.project_to;



         FETCH l_wip_cursor BULK COLLECT INTO l_wip_table;


        ELSE
        --Otherwise, the asset criteria has already been used before calling
        --the pm engine

            debug('Opening non-transact cursor');

            OPEN l_wip_cursor for l_sql USING
                      p_forecast_rec.organization_id,
                      p_forecast_rec.creation_date,
                      l_start_date,
                      l_end_date,
                      p_forecast_rec.work_order_from,
                      p_forecast_rec.work_order_to,
                      p_forecast_rec.work_order_type_from,
                      p_forecast_rec.work_order_type_to,
                      p_forecast_rec.wip_acct_class_from,
                      p_forecast_rec.wip_acct_class_to,
                      p_forecast_rec.activity_from,
                      p_forecast_rec.activity_to,
                      p_forecast_rec.department_from,
                      p_forecast_rec.department_to,
                      p_forecast_rec.project_from,
                      p_forecast_rec.project_to;

         FETCH l_wip_cursor BULK COLLECT INTO l_wip_table;
         END IF;

         debug('DONE Getting wo table: ' || l_wip_table.COUNT );
        return l_wip_table;

  END get_wip_table;



  FUNCTION get_asset_cursor(p_organization_id IN NUMBER,p_asset_number_from IN VARCHAR2,
    p_asset_number_to IN VARCHAR2, p_serial_number_from IN VARCHAR2,
    p_serial_number_to IN VARCHAR2 , p_asset_group_from IN VARCHAR2,
    p_asset_group_to IN VARCHAR2 , p_area_from IN VARCHAR2, p_area_to IN VARCHAR2)
    RETURN forecast_asset_cursor_type
    IS
        l_asset_cursor forecast_asset_cursor_type;
        l_asset_query VARCHAR2(4010);
    BEGIN
        l_asset_query := get_asset_query(p_organization_id,
                      p_asset_number_from,
                      p_asset_number_to,
                      p_serial_number_from,
                      p_serial_number_to,
                      p_asset_group_from,
                      p_asset_group_to,
                      p_area_from,
                      p_area_to);
        /*
        dbms_output.put_line(SUBSTR(l_asset_query,1,250));
        dbms_output.put_line(SUBSTR(l_asset_query,250,250));
        dbms_output.put_line(SUBSTR(l_asset_query,500,250));
        dbms_output.put_line(SUBSTR(l_asset_query,750,250));
        dbms_output.put_line(SUBSTR(l_asset_query,1000,250));
        dbms_output.put_line(SUBSTR(l_asset_query,1250,250));
        dbms_output.put_line(SUBSTR(l_asset_query,1500,250));
        dbms_output.put_line(SUBSTR(l_asset_query,1750,250));
        dbms_output.put_line(SUBSTR(l_asset_query,2000,250));
        */
        debug('opening asset cursor',2);
        OPEN l_asset_cursor FOR l_asset_query USING p_organization_id, p_asset_number_from,
                                      p_asset_number_to, p_serial_number_from ,
                                      p_serial_number_to, p_asset_group_from ,
                                      p_asset_group_to  , p_area_from , p_area_to,
                                      p_organization_id, p_asset_group_from,
                                      p_asset_group_to;
        debug('done opening asset cursor',2);
        return l_asset_cursor;

    END get_asset_cursor;

  FUNCTION get_asset_query(p_forecast_rec eam_forecasts%rowtype)
    RETURN VARCHAR2
  IS

  BEGIN
    return get_asset_query(p_forecast_rec.organization_id,
                      p_forecast_rec.asset_num_from,
                      p_forecast_rec.asset_num_to,
                      p_forecast_rec.asset_serial_num_from,
                      p_forecast_rec.asset_serial_num_to,
                      p_forecast_rec.asset_group_from,
                      p_forecast_rec.asset_group_to,
                      p_forecast_rec.area_from,
                      p_forecast_rec.area_to);
  END get_asset_query;

  FUNCTION get_asset_query(p_organization_id IN NUMBER,p_asset_number_from IN VARCHAR2,
    p_asset_number_to IN VARCHAR2, p_serial_number_from IN VARCHAR2,
    p_serial_number_to IN VARCHAR2 , p_asset_group_from IN VARCHAR2,
    p_asset_group_to IN VARCHAR2 , p_area_from IN VARCHAR2, p_area_to IN VARCHAR2)
    RETURN VARCHAR2
    IS
        -- There are two running statements that will be joined in a union
        -- One is for serialized items with entries in cii, and the other is
        -- for non-serialized rebuildables, with entries in only msi.

        l_sql_query VARCHAR2(4010);

        l_sql_cii VARCHAR2(2000);
        l_sql_cii_select VARCHAR2(100);
        l_sql_cii_from VARCHAR2(200);
        l_sql_cii_where VARCHAR2(1700);



        l_sql_msi VARCHAR2(2000);
        l_sql_msi_select VARCHAR2(100);
        l_sql_msi_from VARCHAR2(200);
        l_sql_msi_where VARCHAR2(1700);

    BEGIN

        debug('Inside get_asset_query', 2);
        -- CII.instance_id as asset_id, serialized as type

        l_sql_cii_select := 'SELECT cii.instance_id as asset_id, 3 as asset_type ';

        --MSI.inventory_item_id as asset_id, nonserialized (2) as type

        l_sql_msi_select := 'SELECT msi.inventory_item_id as asset_id, 2 as asset_type ';


        l_sql_cii_from :=  'FROM csi_item_instances cii,' ||
                       'eam_org_maint_defaults eomd,' ||
                       'mtl_parameters mp ';

        l_sql_msi_from :=  'FROM mtl_parameters mp ';

        -- If asset group criteria is specified, join with msi kfv

        IF p_asset_group_from IS NOT NULL AND p_asset_group_to IS NOT NULL
        THEN
            l_sql_cii_from := l_sql_cii_from || ',mtl_system_items_b_kfv msi ';
            l_sql_msi_from := l_sql_msi_from || ',mtl_system_items_b_kfv msi ';
        ELSE
            l_sql_cii_from := l_sql_cii_from || ',mtl_system_items_b msi ';
            l_sql_msi_from := l_sql_msi_from || ',mtl_system_items_b msi ';
        END IF;

        debug('Inside get_asset_query 1', 2);
        -- Join with mtl_locations to get area if the area criteria is specified
        IF p_area_from IS NOT NULL AND p_area_to IS NOT NULL
        THEN
            l_sql_cii_from := l_sql_cii_from || ',mtl_eam_locations mel ';

            -- No asset area for non serialized rebuildables
        END IF;

        -- Add the mandatory where clauses
        debug('Inside get_asset_query 2', 2);
        l_sql_cii_where := 'WHERE ' ||
              'msi.eam_item_type in (1,3) ' ||
              'AND msi.inventory_item_id = cii.inventory_item_id ' ||
              'AND msi.organization_id = cii.last_vld_organization_id ' ||
              'AND msi.serial_number_control_code <> 1 ' ||
              'AND nvl(cii.active_start_date, sysdate-1) <= sysdate ' ||
              'AND nvl(cii.active_end_date, sysdate+1) >= sysdate ' ||
              'AND cii.instance_id = eomd.object_id (+) ' ||
              'AND eomd.object_type (+) = 50 ' ||
              'AND (eomd.organization_id is null or eomd.organization_id ' ||
              '= mp.maint_organization_id) ' ||
              --organization criteria
              'AND msi.organization_id = mp.organization_id ' ||
              'AND mp.maint_organization_id = :organization_id ';

        l_sql_msi_where := 'WHERE ' ||
              'msi.eam_item_type = 3 ' ||
              'AND msi.SERIAL_NUMBER_CONTROL_CODE = 1 ' ||
              'AND msi.organization_id = mp.organization_id ' ||
              'AND mp.maint_organization_id = :organization_id ';

        --  Add the where clause for asset numbers
        debug('Inside get_asset_query 3', 2);
        IF p_asset_number_from IS NOT NULL AND p_asset_number_to IS NOT NULL
        THEN
            l_sql_cii_where := l_sql_cii_where ||
            'AND cii.instance_number >= :asset_number_from ' ||
            'AND cii.instance_number <= :asset_number_to ';
        ELSE
            l_sql_cii_where := l_sql_cii_where ||
            'AND (:asset_number_from IS NULL OR :asset_number_to IS NULL) ';
        END IF;

        --  Add the where clause for asset serial numbers

        IF p_serial_number_from IS NOT NULL AND p_serial_number_to IS NOT NULL
        THEN
            l_sql_cii_where := l_sql_cii_where ||
            'AND cii.serial_number >= :serial_number_from ' ||
            'AND cii.serial_number <= :serial_number_to ';
        ELSE
            l_sql_cii_where := l_sql_cii_where ||
            'AND (:serial_number_from IS NULL OR :serial_number_to IS NULL) ';
        END IF;
        debug('Inside get_asset_query 4', 2);
        --  Add the where clause for asset groups

        IF p_asset_group_from IS NOT NULL AND p_asset_group_to IS NOT NULL
        THEN
            l_sql_cii_where := l_sql_cii_where ||
            'AND msi.concatenated_segments >= :asset_group_from ' ||
            'AND msi.concatenated_segments <= :asset_group_to ';
            l_sql_msi_where := l_sql_msi_where ||
            'AND msi.concatenated_segments >= :asset_group_from ' ||
            'AND msi.concatenated_segments <= :asset_group_to ';
        ELSE
            l_sql_cii_where := l_sql_cii_where ||
            'AND (:asset_group_from IS NULL OR :asset_group_to IS NULL) ';
            l_sql_msi_where := l_sql_msi_where ||
            'AND (:asset_group_from IS NULL OR :asset_group_to IS NULL) ';
        END IF;

        -- Add the where clause for asset area

        IF p_area_from IS NOT NULL AND p_area_to IS NOT NULL
        THEN
            l_sql_cii_where := l_sql_cii_where ||
            'AND mel.location_id = eomd.area_id ' ||
            'AND mel.location_codes >= :area_from ' ||
            'AND mel.location_codes <= :area_to ';
            -- If area is specified, completely ignore non-serialized rebuildables
            l_sql_msi := '';
        ELSE
            l_sql_cii_where := l_sql_cii_where ||
            'AND (:area_from IS NULL OR :area_to IS NULL) ';
        END IF;

        -- Add the sql segments together

        debug('Inside get_asset_query A', 2);
        l_sql_cii := l_sql_cii_select || l_sql_cii_from || l_sql_cii_where;
        l_sql_msi := l_sql_msi_select || l_sql_msi_from || l_sql_msi_where;

        debug('Inside get_asset_query B', 2);
        -- Include the non-serialized rebuildables?
        IF p_area_from IS NOT NULL AND p_area_to IS NOT NULL
        THEN
            l_sql_query := l_sql_cii;
        ELSE
            l_sql_query := l_sql_cii || ' UNION ALL ' || l_sql_msi;
        END IF;

        debug('Done with Inside get_asset_query', 2);
        -- Now bind the variables and open the cursor that retrieves all assets

        return l_sql_query;

    END get_asset_query;


  /* Loads the forecast criteria and branches on whether or not the forecast is
     historical or pm generated. */

  -- TODO: OA needs to update the forecast criteria with the request id

    PROCEDURE Extract_Forecast(
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,
                     p_forecast_id       IN  eam_forecasts.forecast_id%TYPE,
	                 x_return_status		OUT	NOCOPY VARCHAR2		  	,
	                 x_msg_count			OUT	NOCOPY NUMBER				,
	                 x_msg_data			OUT	NOCOPY VARCHAR2

    )
    IS

    l_api_name			CONSTANT VARCHAR2(30)	:= 'Extract_Forecast';
    l_api_version       CONSTANT NUMBER 		:= 1.0;
    l_return_status		VARCHAR2(1);

    v_forecast_rec eam_forecasts%ROWTYPE;


    begin
        -- Standard Start of API savepoint
   	    SAVEPOINT	Extract_Forecast_PVT;
   	    -- Standard call to check for call compatibility.
   	    IF NOT FND_API.Compatible_API_Call ( 	l_api_version       ,
    	        	    	    	    	    p_api_version       ,
    	        	    	    	    	    l_api_name 	    	,
			    	    	    	            G_PKG_NAME
	    )
        THEN
		    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

        IF FND_API.to_Boolean( p_init_msg_list ) THEN
		    FND_MSG_PUB.initialize;
	    END IF;
	    --  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

        SELECT * INTO v_forecast_rec
        FROM eam_forecasts
        WHERE forecast_id = p_forecast_id;

        -- Set profile so org is visible to pjm_projects

        EAM_COMMON_UTILITIES_PVT.
            set_profile('MFG_ORGANIZATION_ID', v_forecast_rec.organization_id);


        -- TODO: externalize lookup constants...best practice??
        IF v_forecast_rec.forecast_type <= 3 THEN
            debug('Extracting Historical Forecast');

            extract_historical_forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => v_forecast_rec,


                p_user_id => v_forecast_rec.last_updated_by,
                p_request_id => v_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

            debug('DONE Extracting Historical Forecast');
            --extract_historical_forecast(v_forecast_rec);
        ELSE
            debug('Extracting FUTURE Forecast');
            extract_future_forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => v_forecast_rec,


                p_user_id => v_forecast_rec.last_updated_by,
                p_request_id => v_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);
           debug('DONE Extracting FUTURE Forecast');
        END IF;

        -- Set OUT values
            -- Remove non-positive transaction values as well as work orders
            -- that have no costs associated with them

	   -- delete all costs not within the horizon
	    delete from eam_forecast_cebba where forecast_id = p_forecast_id AND
	    period_start_date > (select start_date from gl_periods
		    where
		    period_set_name = v_forecast_rec.period_set_name_to
		    and period_name = v_forecast_rec.period_to);

	    -- delete all work orders that have zero costs associated
	    delete from eam_forecast_wdj where forecast_id = p_forecast_id and wip_entity_id
	    in
	    (select wip_entity_id from (select wip_entity_id, sum(acct_value) as total from
					eam_forecast_cebba where forecast_id = p_forecast_id
					group by wip_entity_id) where total = 0);

	    delete from eam_forecast_wdj where forecast_id = p_forecast_id and
	    wip_entity_id
	    not in
	    (select wip_entity_id from eam_forecast_cebba where forecast_id =
	     p_forecast_id);


	    -- Standard check of p_commit.
	    IF FND_API.To_Boolean( p_commit ) THEN
		    COMMIT WORK;
	    END IF;

	    -- Standard call to get message count and if count is 1, get message info.

        FND_MSG_PUB.Count_And_Get
        (  	p_count         	=>      x_msg_count     	,
            p_data          	=>      x_msg_data
	    );

        EXCEPTION
	    WHEN no_data_found THEN
            ROLLBACK TO Extract_Forecast_PVT;
		    x_return_status := FND_API.G_RET_STS_ERROR ;
		    FND_MSG_PUB.Count_And_Get
    	    (  	p_count         	=>      x_msg_count     	,
            	p_data          	=>      x_msg_data
		    );
        WHEN OTHERS THEN
		    ROLLBACK TO Extract_Forecast_PVT;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		    IF 	FND_MSG_PUB.Check_Msg_Level
			    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    THEN
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    	(	G_FILE_NAME 	    ,
				    G_PKG_NAME  	    ,
       			    l_api_name
	    		);
		    END IF;
		    FND_MSG_PUB.Count_And_Get
    		(  	p_count         =>      x_msg_count     	,
        		p_data          =>      x_msg_data
    		);

    end extract_forecast;


  -- Body definition (see forward declaration for more info)
  PROCEDURE extract_historical_forecast(
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,


                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)
  IS
    l_wip_table wo_table_type;
  begin

    --Get the list of work orders to copy

    l_wip_table := get_wip_table(p_forecast_rec);

    --copy_wdj_to_forecast(l_wip_table, p_forecast_id

    debug('Copying WDJ');
    Copy_WDJ_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WDJ');

    Copy_WO_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WO');

    Copy_WOR_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WOR');

    Copy_WRO_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WRO');

    Copy_WEDI_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WEDI');

    Copy_CEBBA_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying CEBBA');
  end extract_historical_forecast;

   -- Body definition (see forward declaration for more info)
  PROCEDURE extract_future_forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,


                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)
  IS
    pragma autonomous_transaction;
    l_asset_cursor forecast_asset_cursor_type;
    l_asset_id NUMBER;
    l_asset_type NUMBER;
    l_pm_group_id NUMBER;
    l_forecast_id NUMBER;
    l_forecast_DATE date;
    l_start_date DATE;
    l_end_date DATE;
    l_forecast_rec EAM_FORECASTS%ROWTYPE;
    l_count NUMBER;


  BEGIN


    SELECT glp.start_date
    INTO l_start_date
    FROM gl_periods glp
    WHERE glp.period_name = p_forecast_rec.period_from
          AND glp.period_set_name = p_forecast_rec.period_set_name_from;

    SELECT glp.end_date
    INTO l_end_date
    FROM gl_periods glp
    WHERE glp.period_name = p_forecast_rec.period_to
          AND glp.period_set_name = p_forecast_rec.period_set_name_to;

    select wip_job_schedule_interface_s.nextval into l_pm_group_id from dual;
    debug('Before get_asset_cursor', 2);
    l_asset_cursor := get_asset_cursor(p_forecast_rec);
    debug('Exit get_asset_cursor', 2);

    l_forecast_rec := p_forecast_rec;

    l_forecast_rec.creation_date := SYSDATE;

    debug('BEFORE PM ENGINE');

    LOOP

        FETCH l_asset_cursor INTO l_asset_id, l_asset_type;
          EXIT WHEN l_asset_cursor % NOTFOUND;

               debug('BEFORE PM ENGINE: GROUP ID: ' || l_pm_group_id ||
                ' ASSET_ID: ' || l_asset_ID || ' ASSET_TYPE: ' ||
                l_asset_TYPE);

               EAM_PM_ENGINE.do_forecast3(nonSched   => 'N',
                      startDate  => l_start_date,
                      endDate    => l_end_date,
                      orgID      => p_forecast_rec.organization_id,
                      userID     => p_forecast_rec.last_update_login,
                      objectID => l_asset_id,
                      objectType => l_asset_type,
                      setname_id  => -1,
                      combine_default => 'Y',
                      group_id => l_pm_group_id);

               debug('AFTER PM ENGINE: GROUP ID: ' || l_pm_group_id ||
                ' ASSET_ID: ' || l_asset_ID || ' ASSET_TYPE: ' ||
                l_asset_TYPE);
    END LOOP;

       delete from eam_forecasted_work_orders where
       group_id = l_pm_group_id and
       scheduled_start_date < l_start_date;

       --select count(*) into l_count from wip_discrete_jobs;

       --debug('BEFORE CONVERT, WDJ: ' || l_count);

       convert_work_orders(p_pm_group_id => l_pm_group_id,
                           p_return_status => x_return_status,
                           p_msg => x_msg_data);

       --debug('AFTER CONVERT, WDJ: ' || l_count);

       extract_autonomous_forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => l_forecast_rec,


                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);


     rollback;

  END extract_future_forecast;

PROCEDURE extract_autonomous_forecast(
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,


                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS

    l_wip_table wo_table_type;
  begin

    --Get the list of work orders to copy

    l_wip_table := get_wip_table(p_forecast_rec);

    --copy_wdj_to_forecast(l_wip_table, p_forecast_id

    debug('Copying WDJ AUTO: ' || l_wip_table.COUNT);

        Copy_WDJ_To_Forecast_auto(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WDJ AUTO: ' || l_wip_table.COUNT);
/*
    Copy_WO_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WO');

    Copy_WOR_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WOR');

    Copy_WRO_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WRO');

    Copy_WEDI_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WEDI');




    Copy_CEBBA_To_Forecast_auto(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => l_wip_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying CEBBA');
        */

END extract_autonomous_forecast;


PROCEDURE Copy_WDJ_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS

l_count NUMBER;

BEGIN
FORALL j IN p_wip_id_table.FIRST..p_wip_id_table.LAST

INSERT INTO EAM_FORECAST_WDJ (
   WIP_ENTITY_ID, ORGANIZATION_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, SOURCE_LINE_ID,
   SOURCE_CODE, DESCRIPTION, STATUS_TYPE,
   PRIMARY_ITEM_ID, FIRM_PLANNED_FLAG, JOB_TYPE,
   WIP_SUPPLY_TYPE, CLASS_CODE, MATERIAL_ACCOUNT,
   MATERIAL_OVERHEAD_ACCOUNT, RESOURCE_ACCOUNT, OUTSIDE_PROCESSING_ACCOUNT,
   MATERIAL_VARIANCE_ACCOUNT, RESOURCE_VARIANCE_ACCOUNT, OUTSIDE_PROC_VARIANCE_ACCOUNT,
   STD_COST_ADJUSTMENT_ACCOUNT, OVERHEAD_ACCOUNT, OVERHEAD_VARIANCE_ACCOUNT,
   SCHEDULED_START_DATE, DATE_RELEASED, SCHEDULED_COMPLETION_DATE,
   DATE_COMPLETED, DATE_CLOSED, START_QUANTITY,
   QUANTITY_COMPLETED, QUANTITY_SCRAPPED, NET_QUANTITY,
   BOM_REFERENCE_ID, ROUTING_REFERENCE_ID, COMMON_BOM_SEQUENCE_ID,
   COMMON_ROUTING_SEQUENCE_ID, BOM_REVISION, ROUTING_REVISION,
   BOM_REVISION_DATE, ROUTING_REVISION_DATE, LOT_NUMBER,
   ALTERNATE_BOM_DESIGNATOR, ALTERNATE_ROUTING_DESIGNATOR, COMPLETION_SUBINVENTORY,
   COMPLETION_LOCATOR_ID, MPS_SCHEDULED_COMPLETION_DATE, MPS_NET_QUANTITY,
   DEMAND_CLASS, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
   ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
   ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
   ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
   ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
   ATTRIBUTE14, ATTRIBUTE15, SCHEDULE_GROUP_ID,
   BUILD_SEQUENCE, LINE_ID, PROJECT_ID,
   TASK_ID, KANBAN_CARD_ID, OVERCOMPLETION_TOLERANCE_TYPE,
   OVERCOMPLETION_TOLERANCE_VALUE, END_ITEM_UNIT_NUMBER, PO_CREATION_TIME,
   PRIORITY, DUE_DATE, EST_SCRAP_ACCOUNT,
   EST_SCRAP_VAR_ACCOUNT, EST_SCRAP_PRIOR_QTY, DUE_DATE_PENALTY,
   DUE_DATE_TOLERANCE, COPRODUCTS_SUPPLY, PARENT_WIP_ENTITY_ID,
   ASSET_NUMBER, ASSET_GROUP_ID, REBUILD_ITEM_ID,
   REBUILD_SERIAL_NUMBER, MANUAL_REBUILD_FLAG, SHUTDOWN_TYPE,
   ESTIMATION_STATUS, REQUESTED_START_DATE, NOTIFICATION_REQUIRED,
   WORK_ORDER_TYPE, OWNING_DEPARTMENT, ACTIVITY_TYPE,
   ACTIVITY_CAUSE, TAGOUT_REQUIRED, PLAN_MAINTENANCE,
   PM_SCHEDULE_ID, LAST_ESTIMATION_DATE, LAST_ESTIMATION_REQ_ID,
   ACTIVITY_SOURCE, SERIALIZATION_START_OP, MAINTENANCE_OBJECT_ID,
   MAINTENANCE_OBJECT_TYPE, MAINTENANCE_OBJECT_SOURCE, MATERIAL_ISSUE_BY_MO,
   SCHEDULING_REQUEST_ID, ISSUE_ZERO_COST_FLAG, EAM_LINEAR_LOCATION_ID,
   ACTUAL_START_DATE,
   EXPEDITED, EXPECTED_HOLD_RELEASE_DATE, FORECAST_ID)

SELECT WIP_ENTITY_ID, ORGANIZATION_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, SOURCE_LINE_ID,
   SOURCE_CODE, DESCRIPTION, STATUS_TYPE,
   PRIMARY_ITEM_ID, FIRM_PLANNED_FLAG, JOB_TYPE,
   WIP_SUPPLY_TYPE, CLASS_CODE, MATERIAL_ACCOUNT,
   MATERIAL_OVERHEAD_ACCOUNT, RESOURCE_ACCOUNT, OUTSIDE_PROCESSING_ACCOUNT,
   MATERIAL_VARIANCE_ACCOUNT, RESOURCE_VARIANCE_ACCOUNT, OUTSIDE_PROC_VARIANCE_ACCOUNT,
   STD_COST_ADJUSTMENT_ACCOUNT, OVERHEAD_ACCOUNT, OVERHEAD_VARIANCE_ACCOUNT,
   SCHEDULED_START_DATE, DATE_RELEASED, SCHEDULED_COMPLETION_DATE,
   DATE_COMPLETED, DATE_CLOSED, START_QUANTITY,
   QUANTITY_COMPLETED, QUANTITY_SCRAPPED, NET_QUANTITY,
   BOM_REFERENCE_ID, ROUTING_REFERENCE_ID, COMMON_BOM_SEQUENCE_ID,
   COMMON_ROUTING_SEQUENCE_ID, BOM_REVISION, ROUTING_REVISION,
   BOM_REVISION_DATE, ROUTING_REVISION_DATE, LOT_NUMBER,
   ALTERNATE_BOM_DESIGNATOR, ALTERNATE_ROUTING_DESIGNATOR, COMPLETION_SUBINVENTORY,
   COMPLETION_LOCATOR_ID, MPS_SCHEDULED_COMPLETION_DATE, MPS_NET_QUANTITY,
   DEMAND_CLASS, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
   ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
   ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
   ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
   ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
   ATTRIBUTE14, ATTRIBUTE15, SCHEDULE_GROUP_ID,
   BUILD_SEQUENCE, LINE_ID, PROJECT_ID,
   TASK_ID, KANBAN_CARD_ID, OVERCOMPLETION_TOLERANCE_TYPE,
   OVERCOMPLETION_TOLERANCE_VALUE, END_ITEM_UNIT_NUMBER, PO_CREATION_TIME,
   PRIORITY, DUE_DATE, EST_SCRAP_ACCOUNT,
   EST_SCRAP_VAR_ACCOUNT, EST_SCRAP_PRIOR_QTY, DUE_DATE_PENALTY,
   DUE_DATE_TOLERANCE, COPRODUCTS_SUPPLY, PARENT_WIP_ENTITY_ID,
   ASSET_NUMBER, ASSET_GROUP_ID, REBUILD_ITEM_ID,
   REBUILD_SERIAL_NUMBER, MANUAL_REBUILD_FLAG, SHUTDOWN_TYPE,
   ESTIMATION_STATUS, REQUESTED_START_DATE, NOTIFICATION_REQUIRED,
   WORK_ORDER_TYPE, OWNING_DEPARTMENT, ACTIVITY_TYPE,
   ACTIVITY_CAUSE, TAGOUT_REQUIRED, PLAN_MAINTENANCE,
   PM_SCHEDULE_ID, LAST_ESTIMATION_DATE, LAST_ESTIMATION_REQ_ID,
   ACTIVITY_SOURCE, SERIALIZATION_START_OP, MAINTENANCE_OBJECT_ID,
   MAINTENANCE_OBJECT_TYPE, MAINTENANCE_OBJECT_SOURCE, MATERIAL_ISSUE_BY_MO,
   SCHEDULING_REQUEST_ID, ISSUE_ZERO_COST_FLAG, EAM_LINEAR_LOCATION_ID,
   ACTUAL_START_DATE,
   EXPEDITED, EXPECTED_HOLD_RELEASE_DATE,
   p_forecast_rec.forecast_id AS FORECAST_ID

   FROM WIP_DISCRETE_JOBS
   WHERE wip_entity_id = p_wip_id_table(j);

debug('COMPLETE WDJ COPY: ');

END  Copy_WDJ_To_Forecast;

PROCEDURE Copy_WDJ_To_Forecast_auto (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS


l_wdj_table wdj_table_type;
l_cebba_table cebba_table_type;


BEGIN
    Copy_WDJ_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => p_wip_id_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying WDJ');

select * bulk collect INTO l_wdj_table
from eam_forecast_wdj
where forecast_id = p_forecast_rec.forecast_id;
    Copy_CEBBA_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => p_wip_id_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying CEBBA');
select * bulk collect INTO l_cebba_table
from eam_forecast_cebba
where forecast_id = p_forecast_rec.forecast_id;




debug(' Size of work order table ' || l_wdj_table.COUNT);
ROLLBACK;
insert_into_wdj_auto(l_wdj_table);
insert_into_cebba_auto(l_cebba_table);

END  Copy_WDJ_To_Forecast_auto;

PROCEDURE insert_into_wdj_auto(p_wdj_table wdj_table_type)
IS
pragma autonomous_transaction;
BEGIN
    debug(' Size of work order table BEFORE ' || p_wdj_table.COUNT);
    FORALL i IN p_wdj_table.First..p_wdj_table.last
        insert into eam_forecast_wdj values p_wdj_table(i);
    commit;
    debug(' Size of work order table AFTER ' || p_wdj_table.COUNT);
END insert_into_wdj_auto;

/*
PROCEDURE insert_into_wdj_auto(p_wdj_table wdj_table_type)
IS
pragma autonomous_transaction;
BEGIN
    debug(' Size of work order table BEFORE ' || p_wdj_table.COUNT);
    FOR i IN 1..p_wdj_table.last
    LOOP
    debug('inserting : ' || p_wdj_table(i).wip_entity_id);
INSERT INTO EAM_FORECAST_WDJ (
   WIP_ENTITY_ID, ORGANIZATION_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, SOURCE_LINE_ID,
   SOURCE_CODE, DESCRIPTION, STATUS_TYPE,
   PRIMARY_ITEM_ID, FIRM_PLANNED_FLAG, JOB_TYPE,
   WIP_SUPPLY_TYPE, CLASS_CODE, MATERIAL_ACCOUNT,
   MATERIAL_OVERHEAD_ACCOUNT, RESOURCE_ACCOUNT, OUTSIDE_PROCESSING_ACCOUNT,
   MATERIAL_VARIANCE_ACCOUNT, RESOURCE_VARIANCE_ACCOUNT, OUTSIDE_PROC_VARIANCE_ACCOUNT,
   STD_COST_ADJUSTMENT_ACCOUNT, OVERHEAD_ACCOUNT, OVERHEAD_VARIANCE_ACCOUNT,
   SCHEDULED_START_DATE, DATE_RELEASED, SCHEDULED_COMPLETION_DATE,
   DATE_COMPLETED, DATE_CLOSED, START_QUANTITY,
   QUANTITY_COMPLETED, QUANTITY_SCRAPPED, NET_QUANTITY,
   BOM_REFERENCE_ID, ROUTING_REFERENCE_ID, COMMON_BOM_SEQUENCE_ID,
   COMMON_ROUTING_SEQUENCE_ID, BOM_REVISION, ROUTING_REVISION,
   BOM_REVISION_DATE, ROUTING_REVISION_DATE, LOT_NUMBER,
   ALTERNATE_BOM_DESIGNATOR, ALTERNATE_ROUTING_DESIGNATOR, COMPLETION_SUBINVENTORY,
   COMPLETION_LOCATOR_ID, MPS_SCHEDULED_COMPLETION_DATE, MPS_NET_QUANTITY,
   DEMAND_CLASS, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
   ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
   ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
   ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
   ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
   ATTRIBUTE14, ATTRIBUTE15, SCHEDULE_GROUP_ID,
   BUILD_SEQUENCE, LINE_ID, PROJECT_ID,
   TASK_ID, KANBAN_CARD_ID, OVERCOMPLETION_TOLERANCE_TYPE,
   OVERCOMPLETION_TOLERANCE_VALUE, END_ITEM_UNIT_NUMBER, PO_CREATION_TIME,
   PRIORITY, DUE_DATE, EST_SCRAP_ACCOUNT,
   EST_SCRAP_VAR_ACCOUNT, EST_SCRAP_PRIOR_QTY, DUE_DATE_PENALTY,
   DUE_DATE_TOLERANCE, COPRODUCTS_SUPPLY, PARENT_WIP_ENTITY_ID,
   ASSET_NUMBER, ASSET_GROUP_ID, REBUILD_ITEM_ID,
   REBUILD_SERIAL_NUMBER, MANUAL_REBUILD_FLAG, SHUTDOWN_TYPE,
   ESTIMATION_STATUS, REQUESTED_START_DATE, NOTIFICATION_REQUIRED,
   WORK_ORDER_TYPE, OWNING_DEPARTMENT, ACTIVITY_TYPE,
   ACTIVITY_CAUSE, TAGOUT_REQUIRED, PLAN_MAINTENANCE,
   PM_SCHEDULE_ID, LAST_ESTIMATION_DATE, LAST_ESTIMATION_REQ_ID,
   ACTIVITY_SOURCE, SERIALIZATION_START_OP, MAINTENANCE_OBJECT_ID,
   MAINTENANCE_OBJECT_TYPE, MAINTENANCE_OBJECT_SOURCE, MATERIAL_ISSUE_BY_MO,
   SCHEDULING_REQUEST_ID, ISSUE_ZERO_COST_FLAG, EAM_LINEAR_LOCATION_ID,
   ACTUAL_START_DATE,
   EXPEDITED, EXPECTED_HOLD_RELEASE_DATE, FORECAST_ID)

   VALUES(
   p_wdj_table(i).WIP_ENTITY_ID, p_wdj_table(i).ORGANIZATION_ID, p_wdj_table(i).LAST_UPDATE_DATE,
   p_wdj_table(i).LAST_UPDATED_BY, p_wdj_table(i).CREATION_DATE, p_wdj_table(i).CREATED_BY,
   p_wdj_table(i).LAST_UPDATE_LOGIN, p_wdj_table(i).REQUEST_ID, p_wdj_table(i).PROGRAM_APPLICATION_ID,
   p_wdj_table(i).PROGRAM_ID, p_wdj_table(i).PROGRAM_UPDATE_DATE, p_wdj_table(i).SOURCE_LINE_ID,
   p_wdj_table(i).SOURCE_CODE, p_wdj_table(i).DESCRIPTION, p_wdj_table(i).STATUS_TYPE,
   p_wdj_table(i).PRIMARY_ITEM_ID, p_wdj_table(i).FIRM_PLANNED_FLAG, p_wdj_table(i).JOB_TYPE,
   p_wdj_table(i).WIP_SUPPLY_TYPE, p_wdj_table(i).CLASS_CODE, p_wdj_table(i).MATERIAL_ACCOUNT,
   p_wdj_table(i).MATERIAL_OVERHEAD_ACCOUNT, p_wdj_table(i).RESOURCE_ACCOUNT, p_wdj_table(i).OUTSIDE_PROCESSING_ACCOUNT,
   p_wdj_table(i).MATERIAL_VARIANCE_ACCOUNT, p_wdj_table(i).RESOURCE_VARIANCE_ACCOUNT, p_wdj_table(i).OUTSIDE_PROC_VARIANCE_ACCOUNT,
   p_wdj_table(i).STD_COST_ADJUSTMENT_ACCOUNT, p_wdj_table(i).OVERHEAD_ACCOUNT, p_wdj_table(i).OVERHEAD_VARIANCE_ACCOUNT,
   p_wdj_table(i).SCHEDULED_START_DATE, p_wdj_table(i).DATE_RELEASED, p_wdj_table(i).SCHEDULED_COMPLETION_DATE,
   p_wdj_table(i).DATE_COMPLETED, p_wdj_table(i).DATE_CLOSED, p_wdj_table(i).START_QUANTITY,
   p_wdj_table(i).QUANTITY_COMPLETED, p_wdj_table(i).QUANTITY_SCRAPPED, p_wdj_table(i).NET_QUANTITY,
   p_wdj_table(i).BOM_REFERENCE_ID, p_wdj_table(i).ROUTING_REFERENCE_ID, p_wdj_table(i).COMMON_BOM_SEQUENCE_ID,
   p_wdj_table(i).COMMON_ROUTING_SEQUENCE_ID, p_wdj_table(i).BOM_REVISION, p_wdj_table(i).ROUTING_REVISION,
   p_wdj_table(i).BOM_REVISION_DATE, p_wdj_table(i).ROUTING_REVISION_DATE, p_wdj_table(i).LOT_NUMBER,
   p_wdj_table(i).ALTERNATE_BOM_DESIGNATOR, p_wdj_table(i).ALTERNATE_ROUTING_DESIGNATOR, p_wdj_table(i).COMPLETION_SUBINVENTORY,
   p_wdj_table(i).COMPLETION_LOCATOR_ID, p_wdj_table(i).MPS_SCHEDULED_COMPLETION_DATE, p_wdj_table(i).MPS_NET_QUANTITY,
   p_wdj_table(i).DEMAND_CLASS, p_wdj_table(i).ATTRIBUTE_CATEGORY, p_wdj_table(i).ATTRIBUTE1,
   p_wdj_table(i).ATTRIBUTE2, p_wdj_table(i).ATTRIBUTE3, p_wdj_table(i).ATTRIBUTE4,
   p_wdj_table(i).ATTRIBUTE5, p_wdj_table(i).ATTRIBUTE6, p_wdj_table(i).ATTRIBUTE7,
   p_wdj_table(i).ATTRIBUTE8, p_wdj_table(i).ATTRIBUTE9, p_wdj_table(i).ATTRIBUTE10,
   p_wdj_table(i).ATTRIBUTE11, p_wdj_table(i).ATTRIBUTE12, p_wdj_table(i).ATTRIBUTE13,
   p_wdj_table(i).ATTRIBUTE14, p_wdj_table(i).ATTRIBUTE15, p_wdj_table(i).SCHEDULE_GROUP_ID,
   p_wdj_table(i).BUILD_SEQUENCE, p_wdj_table(i).LINE_ID, p_wdj_table(i).PROJECT_ID,
   p_wdj_table(i).TASK_ID, p_wdj_table(i).KANBAN_CARD_ID, p_wdj_table(i).OVERCOMPLETION_TOLERANCE_TYPE,
   p_wdj_table(i).OVERCOMPLETION_TOLERANCE_VALUE, p_wdj_table(i).END_ITEM_UNIT_NUMBER, p_wdj_table(i).PO_CREATION_TIME,
   p_wdj_table(i).PRIORITY, p_wdj_table(i).DUE_DATE, p_wdj_table(i).EST_SCRAP_ACCOUNT,
   p_wdj_table(i).EST_SCRAP_VAR_ACCOUNT, p_wdj_table(i).EST_SCRAP_PRIOR_QTY, p_wdj_table(i).DUE_DATE_PENALTY,
   p_wdj_table(i).DUE_DATE_TOLERANCE, p_wdj_table(i).COPRODUCTS_SUPPLY, p_wdj_table(i).PARENT_WIP_ENTITY_ID,
   p_wdj_table(i).ASSET_NUMBER, p_wdj_table(i).ASSET_GROUP_ID, p_wdj_table(i).REBUILD_ITEM_ID,
   p_wdj_table(i).REBUILD_SERIAL_NUMBER, p_wdj_table(i).MANUAL_REBUILD_FLAG, p_wdj_table(i).SHUTDOWN_TYPE,
   p_wdj_table(i).ESTIMATION_STATUS, p_wdj_table(i).REQUESTED_START_DATE, p_wdj_table(i).NOTIFICATION_REQUIRED,
   p_wdj_table(i).WORK_ORDER_TYPE, p_wdj_table(i).OWNING_DEPARTMENT, p_wdj_table(i).ACTIVITY_TYPE,
   p_wdj_table(i).ACTIVITY_CAUSE, p_wdj_table(i).TAGOUT_REQUIRED, p_wdj_table(i).PLAN_MAINTENANCE,
   p_wdj_table(i).PM_SCHEDULE_ID, p_wdj_table(i).LAST_ESTIMATION_DATE, p_wdj_table(i).LAST_ESTIMATION_REQ_ID,
   p_wdj_table(i).ACTIVITY_SOURCE, p_wdj_table(i).SERIALIZATION_START_OP, p_wdj_table(i).MAINTENANCE_OBJECT_ID,
   p_wdj_table(i).MAINTENANCE_OBJECT_TYPE, p_wdj_table(i).MAINTENANCE_OBJECT_SOURCE, p_wdj_table(i).MATERIAL_ISSUE_BY_MO,
   p_wdj_table(i).SCHEDULING_REQUEST_ID, p_wdj_table(i).ISSUE_ZERO_COST_FLAG, p_wdj_table(i).EAM_LINEAR_LOCATION_ID,
   p_wdj_table(i).ACTUAL_START_DATE,
   p_wdj_table(i).EXPEDITED, p_wdj_table(i).EXPECTED_HOLD_RELEASE_DATE, p_wdj_table(i).FORECAST_ID);
   END LOOP;
    commit;
   EXCEPTION

   WHEN OTHERS THEN
    RAISE;
    debug(' Size of work order table AFTER ' || p_wdj_table.COUNT);
END insert_into_wdj_auto;
*/
PROCEDURE Copy_CEBBA_To_Forecast_auto (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS


l_cebba_table cebba_table_type;

BEGIN
    Copy_CEBBA_To_Forecast(
                p_api_version => p_api_version,
                p_commit => p_commit,
                p_validation_level => p_validation_level,
                p_init_msg_list => p_init_msg_list,

                p_debug => p_debug,

                p_forecast_rec => p_forecast_rec,
                p_wip_id_table => p_wip_id_table,

                p_user_id => p_forecast_rec.last_updated_by,
                p_request_id => p_forecast_rec.request_id,
                p_prog_id => 1,
                p_prog_app_id => 1,
                p_login_id => 1,


                x_return_status => x_return_status,
                x_msg_count => x_msg_count,
                x_msg_data => x_msg_data);

        debug('DONE Copying CEBBA');
select * bulk collect INTO l_cebba_table
from eam_forecast_cebba
where forecast_id = p_forecast_rec.forecast_id;
ROLLBACK;

insert_into_cebba_auto(l_cebba_table);

END  Copy_CEBBA_To_Forecast_auto;


PROCEDURE insert_into_cebba_auto(p_cebba_table cebba_table_type)
IS
pragma autonomous_transaction;
BEGIN
    FORALL i IN p_cebba_table.First..p_cebba_table.last
        insert into eam_forecast_cebba values p_cebba_table(i);
    commit;
END insert_into_cebba_auto;


PROCEDURE Copy_WOR_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS

BEGIN

FORALL j IN p_wip_id_table.FIRST..p_wip_id_table.LAST

INSERT INTO EAM_FORECAST_WOR (
   WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
   ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, RESOURCE_ID,
   UOM_CODE, BASIS_TYPE, USAGE_RATE_OR_AMOUNT,
   ACTIVITY_ID, SCHEDULED_FLAG, ASSIGNED_UNITS,
   AUTOCHARGE_TYPE, STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS,
   APPLIED_RESOURCE_VALUE, START_DATE, COMPLETION_DATE,
   ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
   ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
   ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
   ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
   ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
   ATTRIBUTE15, RELIEVED_RES_COMPLETION_UNITS, RELIEVED_RES_SCRAP_UNITS,
   RELIEVED_RES_COMPLETION_VALUE, RELIEVED_RES_SCRAP_VALUE, RELIEVED_VARIANCE_VALUE,
   TEMP_RELIEVED_VALUE, RELIEVED_RES_FINAL_COMP_UNITS, DEPARTMENT_ID,
   PHANTOM_FLAG, PHANTOM_OP_SEQ_NUM, PHANTOM_ITEM_ID,
   SCHEDULE_SEQ_NUM, SUBSTITUTE_GROUP_NUM, REPLACEMENT_GROUP_NUM,
   PRINCIPLE_FLAG, SETUP_ID, PARENT_RESOURCE_SEQ,
   BATCH_ID, RELIEVED_RES_UNITS, RELIEVED_RES_VALUE,
   MAXIMUM_ASSIGNED_UNITS, FIRM_FLAG, GROUP_SEQUENCE_ID,
   GROUP_SEQUENCE_NUMBER, ACTUAL_START_DATE, ACTUAL_COMPLETION_DATE,
   PROJECTED_COMPLETION_DATE, FORECAST_ID)



SELECT WIP_ENTITY_ID, OPERATION_SEQ_NUM, RESOURCE_SEQ_NUM,
   ORGANIZATION_ID, REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, RESOURCE_ID,
   UOM_CODE, BASIS_TYPE, USAGE_RATE_OR_AMOUNT,
   ACTIVITY_ID, SCHEDULED_FLAG, ASSIGNED_UNITS,
   AUTOCHARGE_TYPE, STANDARD_RATE_FLAG, APPLIED_RESOURCE_UNITS,
   APPLIED_RESOURCE_VALUE, START_DATE, COMPLETION_DATE,
   ATTRIBUTE_CATEGORY, ATTRIBUTE1, ATTRIBUTE2,
   ATTRIBUTE3, ATTRIBUTE4, ATTRIBUTE5,
   ATTRIBUTE6, ATTRIBUTE7, ATTRIBUTE8,
   ATTRIBUTE9, ATTRIBUTE10, ATTRIBUTE11,
   ATTRIBUTE12, ATTRIBUTE13, ATTRIBUTE14,
   ATTRIBUTE15, RELIEVED_RES_COMPLETION_UNITS, RELIEVED_RES_SCRAP_UNITS,
   RELIEVED_RES_COMPLETION_VALUE, RELIEVED_RES_SCRAP_VALUE, RELIEVED_VARIANCE_VALUE,
   TEMP_RELIEVED_VALUE, RELIEVED_RES_FINAL_COMP_UNITS, DEPARTMENT_ID,
   PHANTOM_FLAG, PHANTOM_OP_SEQ_NUM, PHANTOM_ITEM_ID,
   SCHEDULE_SEQ_NUM, SUBSTITUTE_GROUP_NUM, REPLACEMENT_GROUP_NUM,
   PRINCIPLE_FLAG, SETUP_ID, PARENT_RESOURCE_SEQ,
   BATCH_ID, RELIEVED_RES_UNITS, RELIEVED_RES_VALUE,
   MAXIMUM_ASSIGNED_UNITS, FIRM_FLAG, GROUP_SEQUENCE_ID,
   GROUP_SEQUENCE_NUMBER, ACTUAL_START_DATE, ACTUAL_COMPLETION_DATE,
   PROJECTED_COMPLETION_DATE,p_forecast_rec.forecast_id AS FORECAST_ID

   FROM WIP_OPERATION_RESOURCES
   WHERE wip_entity_id = p_wip_id_table(j);


debug('COMPLETE WOR COPY');

END  Copy_WOR_To_Forecast;


PROCEDURE Copy_WRO_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS

BEGIN

FORALL j IN p_wip_id_table.FIRST..p_wip_id_table.LAST


INSERT INTO EAM_FORECAST_WRO (
   INVENTORY_ITEM_ID, ORGANIZATION_ID, WIP_ENTITY_ID,
   OPERATION_SEQ_NUM, REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, COMPONENT_SEQUENCE_ID,
   DEPARTMENT_ID, WIP_SUPPLY_TYPE, DATE_REQUIRED,
   REQUIRED_QUANTITY, QUANTITY_ISSUED, QUANTITY_PER_ASSEMBLY,
   COMMENTS, SUPPLY_SUBINVENTORY, SUPPLY_LOCATOR_ID,
   MRP_NET_FLAG, MPS_REQUIRED_QUANTITY, MPS_DATE_REQUIRED,
   SEGMENT1, SEGMENT2, SEGMENT3,
   SEGMENT4, SEGMENT5, SEGMENT6,
   SEGMENT7, SEGMENT8, SEGMENT9,
   SEGMENT10, SEGMENT11, SEGMENT12,
   SEGMENT13, SEGMENT14, SEGMENT15,
   SEGMENT16, SEGMENT17, SEGMENT18,
   SEGMENT19, SEGMENT20, ATTRIBUTE_CATEGORY,
   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
   ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
   ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
   ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
   ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
   RELIEVED_MATL_COMPLETION_QTY, RELIEVED_MATL_SCRAP_QUANTITY, RELIEVED_MATL_FINAL_COMP_QTY,
   QUANTITY_ALLOCATED, QUANTITY_BACKORDERED, QUANTITY_RELIEVED,
   COSTED_QUANTITY_ISSUED, COSTED_QUANTITY_RELIEVED, AUTO_REQUEST_MATERIAL,
   RELEASED_QUANTITY, SUGGESTED_VENDOR_NAME, VENDOR_ID,
   UNIT_PRICE, BASIS_TYPE,
   COMPONENT_YIELD_FACTOR, PRIMARY_COMPONENT_ID,FORECAST_ID)



SELECT INVENTORY_ITEM_ID, ORGANIZATION_ID, WIP_ENTITY_ID,
   OPERATION_SEQ_NUM, REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
   LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, COMPONENT_SEQUENCE_ID,
   DEPARTMENT_ID, WIP_SUPPLY_TYPE, DATE_REQUIRED,
   REQUIRED_QUANTITY, QUANTITY_ISSUED, QUANTITY_PER_ASSEMBLY,
   COMMENTS, SUPPLY_SUBINVENTORY, SUPPLY_LOCATOR_ID,
   MRP_NET_FLAG, MPS_REQUIRED_QUANTITY, MPS_DATE_REQUIRED,
   SEGMENT1, SEGMENT2, SEGMENT3,
   SEGMENT4, SEGMENT5, SEGMENT6,
   SEGMENT7, SEGMENT8, SEGMENT9,
   SEGMENT10, SEGMENT11, SEGMENT12,
   SEGMENT13, SEGMENT14, SEGMENT15,
   SEGMENT16, SEGMENT17, SEGMENT18,
   SEGMENT19, SEGMENT20, ATTRIBUTE_CATEGORY,
   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
   ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
   ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
   ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
   ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
   RELIEVED_MATL_COMPLETION_QTY, RELIEVED_MATL_SCRAP_QUANTITY, RELIEVED_MATL_FINAL_COMP_QTY,
   QUANTITY_ALLOCATED, QUANTITY_BACKORDERED, QUANTITY_RELIEVED,
   COSTED_QUANTITY_ISSUED, COSTED_QUANTITY_RELIEVED, AUTO_REQUEST_MATERIAL,
   RELEASED_QUANTITY, SUGGESTED_VENDOR_NAME, VENDOR_ID,
   UNIT_PRICE, BASIS_TYPE, COMPONENT_YIELD_FACTOR,
   PRIMARY_COMPONENT_ID,
   p_forecast_rec.forecast_id AS FORECAST_ID

   FROM WIP_REQUIREMENT_OPERATIONS
   WHERE wip_entity_id = p_wip_id_table(j);
debug('COMPLETE WRO COPY');

END  Copy_WRO_To_Forecast;



PROCEDURE Copy_WO_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS

BEGIN
debug('COPYING WO');
FORALL j IN p_wip_id_table.FIRST..p_wip_id_table.LAST

INSERT INTO EAM_FORECAST_WO (
   WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
   REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
   CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
   REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
   PROGRAM_UPDATE_DATE, OPERATION_SEQUENCE_ID, STANDARD_OPERATION_ID,
   DEPARTMENT_ID, DESCRIPTION, SCHEDULED_QUANTITY,
   QUANTITY_IN_QUEUE, QUANTITY_RUNNING, QUANTITY_WAITING_TO_MOVE,
   QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
   FIRST_UNIT_START_DATE, FIRST_UNIT_COMPLETION_DATE, LAST_UNIT_START_DATE,
   LAST_UNIT_COMPLETION_DATE, PREVIOUS_OPERATION_SEQ_NUM, NEXT_OPERATION_SEQ_NUM,
   COUNT_POINT_TYPE, BACKFLUSH_FLAG, MINIMUM_TRANSFER_QUANTITY,
   DATE_LAST_MOVED, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
   ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
   ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
   ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
   ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
   ATTRIBUTE14, ATTRIBUTE15, WF_ITEMTYPE,
   WF_ITEMKEY, OPERATION_YIELD, OPERATION_YIELD_ENABLED,
   PRE_SPLIT_QUANTITY, OPERATION_COMPLETED, SHUTDOWN_TYPE,
   X_POS, Y_POS, PREVIOUS_OPERATION_SEQ_ID,
   SKIP_FLAG, LONG_DESCRIPTION, DISABLE_DATE,
   CUMULATIVE_SCRAP_QUANTITY, RECOMMENDED, PROGRESS_PERCENTAGE,
   WSM_OP_SEQ_NUM, ACTUAL_START_DATE, ACTUAL_COMPLETION_DATE,
    WSM_BONUS_QUANTITY, EMPLOYEE_ID,
   PROJECT_COMPLETION_DATE, WSM_UPDATE_QUANTITY_TXN_ID, WSM_UPDATE_QUANTITY_COMPLETED,
   LOWEST_ACCEPTABLE_YIELD, FORECAST_ID)


SELECT WIP_ENTITY_ID, OPERATION_SEQ_NUM, ORGANIZATION_ID,
   REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY,
   CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN,
   REQUEST_ID, PROGRAM_APPLICATION_ID, PROGRAM_ID,
   PROGRAM_UPDATE_DATE, OPERATION_SEQUENCE_ID, STANDARD_OPERATION_ID,
   DEPARTMENT_ID, DESCRIPTION, SCHEDULED_QUANTITY,
   QUANTITY_IN_QUEUE, QUANTITY_RUNNING, QUANTITY_WAITING_TO_MOVE,
   QUANTITY_REJECTED, QUANTITY_SCRAPPED, QUANTITY_COMPLETED,
   FIRST_UNIT_START_DATE, FIRST_UNIT_COMPLETION_DATE, LAST_UNIT_START_DATE,
   LAST_UNIT_COMPLETION_DATE, PREVIOUS_OPERATION_SEQ_NUM, NEXT_OPERATION_SEQ_NUM,
   COUNT_POINT_TYPE, BACKFLUSH_FLAG, MINIMUM_TRANSFER_QUANTITY,
   DATE_LAST_MOVED, ATTRIBUTE_CATEGORY, ATTRIBUTE1,
   ATTRIBUTE2, ATTRIBUTE3, ATTRIBUTE4,
   ATTRIBUTE5, ATTRIBUTE6, ATTRIBUTE7,
   ATTRIBUTE8, ATTRIBUTE9, ATTRIBUTE10,
   ATTRIBUTE11, ATTRIBUTE12, ATTRIBUTE13,
   ATTRIBUTE14, ATTRIBUTE15, WF_ITEMTYPE,
   WF_ITEMKEY, OPERATION_YIELD, OPERATION_YIELD_ENABLED,
   PRE_SPLIT_QUANTITY, OPERATION_COMPLETED, SHUTDOWN_TYPE,
   X_POS, Y_POS, PREVIOUS_OPERATION_SEQ_ID,
   SKIP_FLAG, LONG_DESCRIPTION, DISABLE_DATE,
   CUMULATIVE_SCRAP_QUANTITY, RECOMMENDED, PROGRESS_PERCENTAGE,
   WSM_OP_SEQ_NUM, ACTUAL_START_DATE, ACTUAL_COMPLETION_DATE,
   WSM_BONUS_QUANTITY, EMPLOYEE_ID, PROJECTED_COMPLETION_DATE,
   WSM_UPDATE_QUANTITY_TXN_ID, WSM_COSTED_QUANTITY_COMPLETED, LOWEST_ACCEPTABLE_YIELD, p_forecast_rec.forecast_id AS FORECAST_ID

   FROM WIP_OPERATIONS
   WHERE wip_entity_id = p_wip_id_table(j);
    debug('COMPLETE');
        EXCEPTION

	    WHEN no_data_found THEN
            --ROLLBACK TO Extract_Forecast_PVT;
		    x_return_status := FND_API.G_RET_STS_ERROR ;
		    FND_MSG_PUB.Count_And_Get
    	    (  	p_count         	=>      x_msg_count     	,
            	p_data          	=>      x_msg_data
		    );
            RAISE FND_API.G_EXC_ERROR;
        WHEN OTHERS THEN
            debug('EXCEPTION');
		    --ROLLBACK TO Extract_Forecast_PVT;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		    IF 	FND_MSG_PUB.Check_Msg_Level
			    (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		    THEN
    	    	FND_MSG_PUB.Add_Exc_Msg
    	    	(	G_FILE_NAME 	    ,
				    G_PKG_NAME  	    ,
       			    'Copy_WO_To_Forecast'
	    		);
		    END IF;
		    FND_MSG_PUB.Count_And_Get
    		(  	p_count         =>      x_msg_count     	,
        		p_data          =>      x_msg_data
    		);
            RAISE FND_API.G_EXC_ERROR;


END  Copy_WO_To_Forecast;


PROCEDURE Copy_CEBBA_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS




l_current_wo NUMBER;
l_hist_cost_tbl eam_wo_relations_tbl_type;



BEGIN

-- Historical Costs

IF p_forecast_rec.forecast_type <> 4

THEN
    debug('CEBBA');
  for i in 1..p_wip_id_table.last loop

    l_current_wo := p_wip_id_table(i);
    debug('Current wo is: ' || l_current_wo);

    Get_HistoricalCosts(
        p_api_version => p_api_version,
     --   p_commit => p_commit,
    --    p_validation_level => p_validation_level,
   --     p_init_msg_list => p_init_msg_list,
        p_debug => p_debug,


        p_forecast_id => p_forecast_rec.forecast_id,
        p_organization_id => p_forecast_rec.organization_id,
        p_wip_entity_id => l_current_wo,
	p_account_from => p_forecast_rec.account_from,
	p_account_to => p_forecast_rec.account_to,

        p_user_id => p_user_id,
        p_request_id => p_request_id,
        p_prog_id => p_prog_id,
        p_prog_app_id => p_prog_app_id,
        p_login_id => p_login_id,

        x_hist_cost_tbl => l_hist_cost_tbl,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

      debug('Current wo is: ' || l_current_wo || ' GOT COST: ' || x_return_status);
      IF l_hist_cost_tbl IS NOT NULL AND l_hist_cost_tbl.count > 0
      THEN
        debug('Count is: ' || l_hist_cost_tbl.count, 2);
        for k in 1.. l_hist_cost_tbl.last loop
             debug('Current wo is: ' || l_current_wo || ' INSERTING COST ', 2);

                   debug(l_hist_cost_tbl(k).PERIOD_SET_NAME);
                   debug(l_hist_cost_tbl(k).PERIOD_NAME);
                   debug(l_hist_cost_tbl(k).ACCT_PERIOD_ID);
                   debug(l_hist_cost_tbl(k).WIP_ENTITY_ID);
                   debug(l_hist_cost_tbl(k).ORGANIZATION_ID);
                   debug(l_hist_cost_tbl(k).OPERATIONS_DEPT_ID);
                   debug(l_hist_cost_tbl(k).OPERATION_SEQ_NUM);
                   debug(l_hist_cost_tbl(k).MAINT_COST_CATEGORY);
                   debug(l_hist_cost_tbl(k).OWNING_DEPT_ID);
                   debug(l_hist_cost_tbl(k).ACCT_VALUE);
                   debug(l_hist_cost_tbl(k).PERIOD_START_DATE);
                   debug(l_hist_cost_tbl(k).LAST_UPDATE_DATE);
                   debug(l_hist_cost_tbl(k).LAST_UPDATED_BY);
                   debug(l_hist_cost_tbl(k).CREATION_DATE);
                   debug(l_hist_cost_tbl(k).CREATED_BY);
                   debug(l_hist_cost_tbl(k).LAST_UPDATE_LOGIN);
                   debug(l_hist_cost_tbl(k).REQUEST_ID);
                   debug(l_hist_cost_tbl(k).PROGRAM_APPLICATION_ID);
                   debug(l_hist_cost_tbl(k).PROGRAM_ID);
                   debug(l_hist_cost_tbl(k).PROGRAM_UPDATE_DATE);
                   debug(l_hist_cost_tbl(k).FORECAST_ID);
                   debug(l_hist_cost_tbl(k).CCID);
                   debug(l_hist_cost_tbl(k).MFG_COST_ELEMENT_ID);
                   debug(l_hist_cost_tbl(k).PERIOD_YEAR);
                   debug(l_hist_cost_tbl(k).PERIOD_NUM);


            INSERT INTO EAM_FORECAST_CEBBA (
                PERIOD_SET_NAME, PERIOD_NAME, ACCT_PERIOD_ID,
                WIP_ENTITY_ID, ORGANIZATION_ID, OPERATIONS_DEPT_ID,
                OPERATION_SEQ_NUM, MAINT_COST_CATEGORY, OWNING_DEPT_ID,
                ACCT_VALUE, PERIOD_START_DATE, LAST_UPDATE_DATE,
                LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
                LAST_UPDATE_LOGIN, REQUEST_ID, PROGRAM_APPLICATION_ID,
                PROGRAM_ID, PROGRAM_UPDATE_DATE, FORECAST_ID,
                CCID, MFG_COST_ELEMENT_ID, PERIOD_YEAR,
                PERIOD_NUM)
            VALUES(l_hist_cost_tbl(k).PERIOD_SET_NAME,
                   l_hist_cost_tbl(k).PERIOD_NAME,
                   l_hist_cost_tbl(k).ACCT_PERIOD_ID,
                   l_hist_cost_tbl(k).WIP_ENTITY_ID,
                   l_hist_cost_tbl(k).ORGANIZATION_ID,
                   l_hist_cost_tbl(k).OPERATIONS_DEPT_ID,
                   l_hist_cost_tbl(k).OPERATION_SEQ_NUM,
                   l_hist_cost_tbl(k).MAINT_COST_CATEGORY,
                   l_hist_cost_tbl(k).OWNING_DEPT_ID,
                   l_hist_cost_tbl(k).ACCT_VALUE,
                   l_hist_cost_tbl(k).PERIOD_START_DATE,
                   l_hist_cost_tbl(k).LAST_UPDATE_DATE,
                   l_hist_cost_tbl(k).LAST_UPDATED_BY,
                   l_hist_cost_tbl(k).CREATION_DATE,
                   l_hist_cost_tbl(k).CREATED_BY,
                   l_hist_cost_tbl(k).LAST_UPDATE_LOGIN,
                   l_hist_cost_tbl(k).REQUEST_ID,
                   l_hist_cost_tbl(k).PROGRAM_APPLICATION_ID,
                   l_hist_cost_tbl(k).PROGRAM_ID,
                   l_hist_cost_tbl(k).PROGRAM_UPDATE_DATE,
                   l_hist_cost_tbl(k).FORECAST_ID,
                   l_hist_cost_tbl(k).CCID,
                   l_hist_cost_tbl(k).MFG_COST_ELEMENT_ID,
                   l_hist_cost_tbl(k).PERIOD_YEAR,
                   l_hist_cost_tbl(k).PERIOD_NUM);
               debug('Current wo is: ' || l_current_wo || ' DOnE INSERTING COST ', 2);
       end loop;
       END IF;

    end loop;

   ELSE
FORALL j IN p_wip_id_table.FIRST..p_wip_id_table.LAST

   INSERT INTO EAM_FORECAST_CEBBA (
   PERIOD_SET_NAME, PERIOD_NAME, ACCT_PERIOD_ID,
   WIP_ENTITY_ID, ORGANIZATION_ID, OPERATIONS_DEPT_ID,
   OPERATION_SEQ_NUM, MAINT_COST_CATEGORY, OWNING_DEPT_ID,
   ACCT_VALUE, PERIOD_START_DATE, LAST_UPDATE_DATE,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,CCID,
   TXN_TYPE,  MFG_COST_ELEMENT_ID, FORECAST_ID,
   PERIOD_YEAR,PERIOD_NUM)

   SELECT PERIOD_SET_NAME, PERIOD_NAME, ACCT_PERIOD_ID,
   WIP_ENTITY_ID, ORGANIZATION_ID, OPERATIONS_DEPT_ID,
   OPERATIONS_SEQ_NUM, MAINT_COST_CATEGORY, OWNING_DEPT_ID,
   ACCT_VALUE, PERIOD_START_DATE, LAST_UPDATE_DATE ,
   LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,  ACCOUNT_ID,
   TXN_TYPE, MFG_COST_ELEMENT_ID, p_forecast_rec.forecast_id as forecast_id,
   1 as period_year, 1 as period_type


   FROM CST_EAM_BALANCE_BY_ACCOUNTS
   WHERE wip_entity_id = p_wip_id_table(j);

   END IF;

debug('COMPLETE COST COPY');

END  Copy_CEBBA_To_Forecast;

PROCEDURE Copy_WEDI_To_Forecast (
                     p_api_version      IN  NUMBER,
                     p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                     p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                     p_debug            IN  VARCHAR2 ,

                     p_forecast_rec     IN  eam_forecasts%ROWTYPE,
                     p_wip_id_table     IN  wo_table_type,

                     --p_acct_period_from IN  NUMBER,
                     --p_acct_period_to   IN  NUMBER,

                     p_user_id          IN  NUMBER,
                     p_request_id       IN  NUMBER,
                     p_prog_id          IN  NUMBER,
                     p_prog_app_id      IN  NUMBER,
                     p_login_id         IN  NUMBER,

                     x_return_status      OUT NOCOPY  VARCHAR2,
                     x_msg_count          OUT NOCOPY  NUMBER,
                     x_msg_data           OUT NOCOPY  VARCHAR2)IS

BEGIN

debug('WeDI');
FORALL j IN p_wip_id_table.FIRST..p_wip_id_table.LAST

INSERT INTO EAM_FORECAST_WEDI (
   DESCRIPTION, PURCHASING_CATEGORY_ID, DIRECT_ITEM_SEQUENCE_ID,
   OPERATION_SEQ_NUM, DEPARTMENT_ID, WIP_ENTITY_ID,
   ORGANIZATION_ID, SUGGESTED_VENDOR_NAME, SUGGESTED_VENDOR_ID,
   SUGGESTED_VENDOR_SITE, SUGGESTED_VENDOR_SITE_ID, SUGGESTED_VENDOR_CONTACT,
   SUGGESTED_VENDOR_CONTACT_ID, SUGGESTED_VENDOR_PHONE, SUGGESTED_VENDOR_ITEM_NUM,
   UNIT_PRICE, AUTO_REQUEST_MATERIAL, REQUIRED_QUANTITY,
   UOM, NEED_BY_DATE, ATTRIBUTE_CATEGORY,
   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
   ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
   ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
   ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
   ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
   CREATED_BY, CREATION_DATE, LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN, LAST_UPDATED_BY, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID,
   FORECAST_ID)

SELECT DESCRIPTION, PURCHASING_CATEGORY_ID, DIRECT_ITEM_SEQUENCE_ID,
   OPERATION_SEQ_NUM, DEPARTMENT_ID, WIP_ENTITY_ID,
   ORGANIZATION_ID, SUGGESTED_VENDOR_NAME, SUGGESTED_VENDOR_ID,
   SUGGESTED_VENDOR_SITE, SUGGESTED_VENDOR_SITE_ID, SUGGESTED_VENDOR_CONTACT,
   SUGGESTED_VENDOR_CONTACT_ID, SUGGESTED_VENDOR_PHONE, SUGGESTED_VENDOR_ITEM_NUM,
   UNIT_PRICE, AUTO_REQUEST_MATERIAL, REQUIRED_QUANTITY,
   UOM, NEED_BY_DATE, ATTRIBUTE_CATEGORY,
   ATTRIBUTE1, ATTRIBUTE2, ATTRIBUTE3,
   ATTRIBUTE4, ATTRIBUTE5, ATTRIBUTE6,
   ATTRIBUTE7, ATTRIBUTE8, ATTRIBUTE9,
   ATTRIBUTE10, ATTRIBUTE11, ATTRIBUTE12,
   ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15,
   CREATED_BY, CREATION_DATE, LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN, LAST_UPDATED_BY, PROGRAM_APPLICATION_ID,
   PROGRAM_ID, PROGRAM_UPDATE_DATE, REQUEST_ID,
   p_forecast_rec.forecast_id AS FORECAST_ID

   FROM WIP_EAM_DIRECT_ITEMS
   WHERE wip_entity_id = p_wip_id_table(j);

debug('COMPLETE WEDI COPY');

END  Copy_WEDI_To_Forecast;


  PROCEDURE Populate_Test_Data(p_forecast_id IN NUMBER)
  IS
    l_msg_count                 NUMBER := 0;
    l_msg_data                  VARCHAR2(8000) := '';
    l_return_status             VARCHAR2(2000);

  BEGIN

    Generate_Forecast(l_msg_data, l_msg_count,p_forecast_id);



  END Populate_Test_Data;




FUNCTION getForecastXml(p_forecast_id NUMBER)return CLOB IS


l_xml XMLType;
l_forecast_id NUMBER;
l_sql VARCHAR2(32767);
l_organization_id NUMBER;
c_no_flag CONSTANT VARCHAR2(1) := 'N';
c_pm_no_msg CONSTANT VARCHAR2(6) := 'Non-PM';
c_pm_yes_msg CONSTANT VARCHAR2(2) := 'PM';



BEGIN


l_forecast_id := p_forecast_id;

-- get the organization id of the forecast
select organization_id into l_organization_id
from eam_forecasts
where forecast_id = l_forecast_id;

EAM_COMMON_UTILITIES_PVT.
            set_profile('MFG_ORGANIZATION_ID', l_organization_id);

l_sql := '

SELECT /*+ ordered use_nl(efc job msi entity msn loc msi2 bd hou.hao hou.haotl
glcc) */
 XMLELEMENT("Forecast", XMLATTRIBUTES(ef.forecast_id AS "id"),
XMLAGG(XMLELEMENT("WorkOrder", XMLATTRIBUTES(efc.wip_entity_id),
XMLForest(
        (SELECT (XMLAgg(
            XMLELEMENT( "COST", null,
                    xmlforest(
                    periods.period_name as period,
                    NVL(costs.cost, 0) AS VALUE
                    )
                     )
                     ORDER BY periods.start_date
                     )
                     )
            FROM

             (SELECT glp.period_name, glp.start_date, ef2.forecast_id
             FROM gl_periods glp, gl_periods glp2, gl_periods glp3, eam_forecasts ef2
             WHERE
             glp.start_date >= glp2.start_date
             AND glp.end_date <= glp3.end_date
             AND glp.period_type = glp2.period_type
             AND glp.period_set_name = glp2.period_set_name
             AND glp2.period_set_name = ef2.period_set_name_from
             AND glp2.period_name = ef2.period_from
             AND glp3.period_set_name = ef2.period_set_name_to
             AND glp3.period_name = ef2.period_to
             )periods,

            (SELECT cebba.wip_entity_id , ef3.forecast_id, cebba.ccid, cebba.period_name AS period_name,SUM(cebba.acct_value) AS cost
             FROM eam_forecast_cebba cebba, eam_forecasts ef3
             WHERE cebba.forecast_id = ef3.forecast_id
             GROUP BY cebba.wip_entity_id, cebba.ccid, cebba.period_name, ef3.forecast_id
             ) costs

            WHERE
            periods.forecast_id = ef.forecast_id
            AND periods.forecast_id = costs.forecast_id (+)
            AND periods.period_name = costs.period_name(+)
            AND efc.wip_entity_id = costs.wip_entity_id (+)
            AND efc.ccid          = costs.ccid (+)



       )AS ACCOUNT_COSTS,

       entity.wip_entity_name AS NAME,
	   glcc.concatenated_segments AS ACCOUNT,
       DECODE(NVL(job.plan_maintenance, :1), :2, :3, :4) AS SOURCE,
       hou.name AS ORGANIZATION,
       job.asset_number AS ASSET,
       msi.concatenated_segments AS ASSETGROUP,
       msi2.concatenated_segments AS Activity,
       loc.location_codes AS AREA,
       job.work_order_type AS WOTYPE,
       bd.department_code AS DEPARTMENT,
       job.class_code AS CLASS,
       pjm_project.all_proj_idtonum(job.project_id) AS PROJECT
)
)))
FROM
  (
  SELECT /*+ no_merge */
        DISTINCT cebba.wip_entity_id,
                 cebba.ccid,
                 cebba.forecast_id AS id
          FROM   eam_forecast_cebba cebba
         WHERE   cebba.forecast_id = :6) efc,
  eam_forecast_wdj job, mtl_system_items_kfv msi,
  eam_forecasts ef, wip_entities entity,
  mtl_serial_numbers msn,
  mtl_eam_locations loc, mtl_system_items_kfv msi2,
  bom_departments bd, hr_organization_units hou,
  gl_code_combinations_kfv glcc


WHERE
  efc.id = ef.forecast_id AND
  job.wip_entity_id = efc.wip_entity_id AND
  entity.wip_entity_id (+) = job.wip_entity_id AND
  glcc.code_combination_id = efc.ccid AND
  entity.entity_type (+) = DECODE(job.status_type,12,7,6)  AND
  (msi.inventory_item_id  = job.asset_group_id OR
  msi.inventory_item_id = job.rebuild_item_id) AND
  msi.organization_id  = job.organization_id AND
  msn.inventory_item_id (+) = job.asset_group_id AND
  msn.current_organization_id(+) = job.organization_id AND
  msn.serial_number(+) = job.asset_number AND
  loc.location_id (+) = msn.eam_location_id AND
  msi2.inventory_item_id (+) = job.primary_item_id AND
  msi2.organization_id (+) = job.organization_id AND
  bd.department_id (+) = job.owning_department AND
  hou.organization_id = job.organization_id AND
  ef.forecast_id = :5
  GROUP BY ef.forecast_ID';





execute immediate l_sql into l_xml using c_no_flag, c_no_flag,
c_pm_no_msg, c_pm_yes_msg, l_forecast_id, l_forecast_id;

  return l_xml.getClobVal();



END getForecastXml;

procedure convert_work_orders(p_pm_group_id number,
                                 p_return_status OUT NOCOPY VARCHAR2,
                                 p_msg OUT NOCOPY VARCHAR2) IS
    l_group_id		NUMBER;
    l_forecast_id	NUMBER;
    l_old_flag		VARCHAR2(1);
    l_req_id		NUMBER;

    -- parameters needed for the WO wrapper API call
    l_eam_wo_tbl              eam_process_wo_pub.eam_wo_tbl_type;
    l_eam_wo_relations_tbl     eam_process_wo_pub.eam_wo_relations_tbl_type;
    l_eam_op_tbl              eam_process_wo_pub.eam_op_tbl_type;
    l_eam_op_network_tbl       eam_process_wo_pub.eam_op_network_tbl_type;
    l_eam_res_tbl              eam_process_wo_pub.eam_res_tbl_type;
    l_eam_res_inst_tbl         eam_process_wo_pub.eam_res_inst_tbl_type;
    l_eam_sub_res_tbl          eam_process_wo_pub.eam_sub_res_tbl_type;
    l_eam_res_usage_tbl        eam_process_wo_pub.eam_res_usage_tbl_type;
    l_eam_mat_req_tbl          eam_process_wo_pub.eam_mat_req_tbl_type;
    l_eam_direct_item_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_eam_counter_prop_tbl     EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_out_eam_wo_tbl            eam_process_wo_pub.eam_wo_tbl_type;
    l_out_eam_wo_relations_tbl  eam_process_wo_pub.eam_wo_relations_tbl_type;
    l_out_eam_op_tbl            eam_process_wo_pub.eam_op_tbl_type;
    l_out_eam_op_network_tbl    eam_process_wo_pub.eam_op_network_tbl_type;
    l_out_eam_res_tbl           eam_process_wo_pub.eam_res_tbl_type;
    l_out_eam_res_inst_tbl      eam_process_wo_pub.eam_res_inst_tbl_type;
    l_out_eam_sub_res_tbl       eam_process_wo_pub.eam_sub_res_tbl_type;
    l_out_eam_res_usage_tbl     eam_process_wo_pub.eam_res_usage_tbl_type;
    l_out_eam_mat_req_tbl       eam_process_wo_pub.eam_mat_req_tbl_type;
    l_out_eam_direct_item_tbl      EAM_PROCESS_WO_PUB.eam_direct_items_tbl_type;
    l_out_eam_wo_comp_tbl         EAM_PROCESS_WO_PUB.eam_wo_comp_tbl_type;
    l_out_eam_wo_quality_tbl      EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type;
    l_out_eam_meter_reading_tbl   EAM_PROCESS_WO_PUB.eam_meter_reading_tbl_type;
    l_out_eam_wo_comp_rebuild_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_rebuild_tbl_type;
    l_out_eam_wo_comp_mr_read_tbl EAM_PROCESS_WO_PUB.eam_wo_comp_mr_read_tbl_type;
    l_out_eam_op_comp_tbl         EAM_PROCESS_WO_PUB.eam_op_comp_tbl_type;
    l_out_eam_request_tbl         EAM_PROCESS_WO_PUB.eam_request_tbl_type;
    l_out_eam_counter_prop_tbl    EAM_PROCESS_WO_PUB.eam_counter_prop_tbl_type;

    l_return_status     VARCHAR2(1);
    l_msl_count         NUMBER;
    l_message_text      VARCHAR2(256);
    l_msl_text      VARCHAR2(256);
    l_entity_index      NUMBER;
    l_entity_id         VARCHAR2(100);
    l_message_type      VARCHAR2(100);

    l_api_name			CONSTANT VARCHAR2(30)	:= 'convert_work_orders';

    l_module            varchar2(200) ;
    l_log_level         CONSTANT NUMBER := fnd_log.g_current_runtime_level;
    l_uLog              CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level ;
    l_sLog              CONSTANT BOOLEAN := l_uLog AND fnd_log.level_statement >= l_log_level;

    -- This cursor returns all necessary fields to call the WO API.modified for ib
    -- Query changed for performance reasons.
    CURSOR c1 IS
    SELECT meaa.asset_activity_id, fw.pm_schedule_id, fw.action_type,
  fw.wip_entity_id, fw.wo_status, ewsv.system_status, fw.cycle_id, fw.seq_id,
  meaa.maintenance_object_type, meaa.maintenance_object_id,
  msi.inventory_item_id, msi.eam_item_type, fw.scheduled_start_date,
  fw.scheduled_completion_date, fw.organization_id organization_id,
  fw.pm_base_meter_reading
   from eam_forecasted_work_orders fw, mtl_eam_asset_activities meaa,
   eam_wo_statuses_v ewsv, csi_item_instances cii, mtl_system_items_b msi
 where group_id = l_group_id and
  fw.activity_association_id = meaa.activity_association_id and
  ewsv.status_id=fw.wo_status and meaa.maintenance_object_type = 3 and
  meaa.maintenance_object_id = cii.instance_id and cii.inventory_item_id =
  msi.inventory_item_id and cii.last_vld_organization_id = msi.organization_id
union all
SELECT meaa.asset_activity_id, fw.pm_schedule_id, fw.action_type,
 fw.wip_entity_id, fw.wo_status, ewsv.system_status, fw.cycle_id, fw.seq_id,
 meaa.maintenance_object_type, meaa.maintenance_object_id,
 meaa.maintenance_object_id, 3, fw.scheduled_start_date,
 fw.scheduled_completion_date, fw.organization_id organization_id,
 fw.pm_base_meter_reading
from eam_forecasted_work_orders fw, mtl_eam_asset_activities meaa,
 eam_wo_statuses_v ewsv
where group_id = l_group_id and fw.activity_association_id =
 meaa.activity_association_id and ewsv.status_id=fw.wo_status and
 meaa.maintenance_object_type = 2 ;

/*
   CURSOR c1 IS
   SELECT meaa.asset_activity_id, pm_schedule_id, action_type, fw.wip_entity_id, fw.wo_status,ewsv.system_status,fw.cycle_id,fw.seq_id,maintenance_object_type, maintenance_object_id,
           meaa.inventory_item_id, default_eam_class wip_acct_class,meaa.eam_item_type,
           scheduled_start_date, scheduled_completion_date, meaa.organization_id
   from eam_forecasted_work_orders fw, mtl_eam_asset_activities_v meaa,
        wip_eam_parameters wep, mtl_system_items msi,eam_wo_statuses_v ewsv
   where group_id = l_group_id
    and wep.organization_id = meaa.organization_id
    and fw.activity_association_id = meaa.activity_association_id
    and meaa.inventory_item_id = msi.inventory_item_id
    and meaa.organization_id = msi.organization_id
    and ewsv.status_id=fw.wo_status;
*/

    sugg_rec c1%ROWTYPE;


    i number;

    -- counter for relationship table
    j number;
    l_output_dir VARCHAR2(512);
  BEGIN

    if (l_ulog) then
          l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
    end if;
    l_group_id := p_pm_group_id;
    l_eam_wo_tbl.delete;
    l_eam_wo_relations_tbl.delete;

    i := 1;

    debug('BEFORE LOOP EXPANDING WORK ORDERS');
    FOR sugg_rec in c1

    LOOP

    if(sugg_rec.action_type IN (2,6,7,1,4)) then
          debug('EXPANDING: ' || sugg_rec.action_type);
          l_eam_wo_tbl(i).plan_maintenance := 'Y';

          l_eam_wo_tbl(i).transaction_type := eam_process_wo_pub.G_OPR_CREATE;

          l_eam_wo_tbl(i).maintenance_object_source := 1; -- EAM
          l_eam_wo_tbl(i).maintenance_object_type := sugg_rec.maintenance_object_type;
          l_eam_wo_tbl(i).maintenance_object_id := sugg_rec.maintenance_object_id;
          l_eam_wo_tbl(i).class_code := null;  -- WO API will default WAC
          -- l_eam_wo_tbl(i).status_type := 1; -- unreleased

    	  --modified for bug 6715761
          l_eam_wo_tbl(i).status_type := 17; --sugg_rec.system_status;
	      l_eam_wo_tbl(i).user_defined_status_id := 17;--sugg_rec.wo_status;
          l_eam_wo_tbl(i).cycle_id := sugg_rec.cycle_id;
          l_eam_wo_tbl(i).seq_id := sugg_rec.seq_id;

          l_eam_wo_tbl(i).pm_schedule_id := sugg_rec.pm_schedule_id;
          l_eam_wo_tbl(i).asset_activity_id := sugg_rec.asset_activity_id;


          if(sugg_rec.scheduled_start_date is not null) then
            -- forward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_start_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_start_date;
            l_eam_wo_tbl(i).requested_start_date := sugg_rec.scheduled_start_date;
          else
            -- forward scheduling
            l_eam_wo_tbl(i).scheduled_start_date := sugg_rec.scheduled_completion_date;
            -- dummy value here, it will be over-written by the scheduler
            l_eam_wo_tbl(i).scheduled_completion_date := sugg_rec.scheduled_completion_date;
            l_eam_wo_tbl(i).due_date := sugg_rec.scheduled_completion_date;
          end if;

          l_eam_wo_tbl(i).organization_id := sugg_rec.organization_id;

          if(sugg_rec.eam_item_type = 1) then
            -- asset
            l_eam_wo_tbl(i).asset_group_id := sugg_rec.inventory_item_id;
          else
            -- rebuildable
            l_eam_wo_tbl(i).rebuild_item_id := sugg_rec.inventory_item_id;
          end if;

          -- common fields for all operations
          l_eam_wo_tbl(i).batch_id := p_pm_group_id;
          l_eam_wo_tbl(i).header_id := i;

          i := i + 1;
          j := j + 1;
      end if;


    end loop;

    /*
    delete from eam_forecasted_work_orders
    where group_id = l_group_id;
    */

    EAM_WORKORDER_UTIL_PKG.log_path(l_output_dir);
    debug('CALLING PROCCESS: ' || l_eam_wo_tbl.COUNT);

    eam_process_wo_pub.PROCESS_MASTER_CHILD_WO
         ( p_bo_identifier           => 'EAM'
         , p_init_msg_list           => TRUE
         , p_api_version_number      => 1.0
         , p_eam_wo_relations_tbl    => l_eam_wo_relations_tbl
         , p_eam_wo_tbl              => l_eam_wo_tbl

    -- dummy parameters as these are not used in PM
         , p_eam_op_tbl              => l_eam_op_tbl
         , p_eam_op_network_tbl      => l_eam_op_network_tbl
         , p_eam_res_tbl             => l_eam_res_tbl
         , p_eam_res_inst_tbl        => l_eam_res_inst_tbl
         , p_eam_sub_res_tbl         => l_eam_sub_res_tbl
         , p_eam_mat_req_tbl         => l_eam_mat_req_tbl
         , p_eam_direct_items_tbl    => l_eam_direct_item_tbl
	 , p_eam_res_usage_tbl       => l_eam_res_usage_tbl
	 , p_eam_wo_comp_tbl          => l_eam_wo_comp_tbl
	 , p_eam_wo_quality_tbl       => l_eam_wo_quality_tbl
	 , p_eam_meter_reading_tbl    => l_eam_meter_reading_tbl
	, p_eam_counter_prop_tbl    => l_eam_counter_prop_tbl
	 , p_eam_wo_comp_rebuild_tbl  => l_eam_wo_comp_rebuild_tbl
	 , p_eam_wo_comp_mr_read_tbl  => l_eam_wo_comp_mr_read_tbl
	 , p_eam_op_comp_tbl          => l_eam_op_comp_tbl
	 , p_eam_request_tbl          => l_eam_request_tbl
         , x_eam_direct_items_tbl    => l_out_eam_direct_item_tbl
	 , x_eam_res_usage_tbl       => l_eam_res_usage_tbl
         , x_eam_wo_tbl              => l_out_eam_wo_tbl
         , x_eam_wo_relations_tbl    => l_out_eam_wo_relations_tbl
         , x_eam_op_tbl              => l_out_eam_op_tbl
         , x_eam_op_network_tbl      => l_out_eam_op_network_tbl
         , x_eam_res_tbl             => l_out_eam_res_tbl
         , x_eam_res_inst_tbl        => l_out_eam_res_inst_tbl
         , x_eam_sub_res_tbl         => l_out_eam_sub_res_tbl
         , x_eam_mat_req_tbl         => l_out_eam_mat_req_tbl
         , x_eam_wo_comp_tbl          => l_out_eam_wo_comp_tbl
         , x_eam_wo_quality_tbl       => l_out_eam_wo_quality_tbl
         , x_eam_meter_reading_tbl    => l_out_eam_meter_reading_tbl
	 , x_eam_counter_prop_tbl    => l_out_eam_counter_prop_tbl
         , x_eam_wo_comp_rebuild_tbl  => l_out_eam_wo_comp_rebuild_tbl
         , x_eam_wo_comp_mr_read_tbl  => l_out_eam_wo_comp_mr_read_tbl
         , x_eam_op_comp_tbl          => l_out_eam_op_comp_tbl
         , x_eam_request_tbl          => l_out_eam_request_tbl

         , p_commit                  => 'N'
      --   , x_error_msl_tbl           OUT NOCOPY EAM_ERROR_MESSAGE_PVT.error_tbl_type
         , x_return_status           => p_return_status
         , x_msg_count               => l_msl_count
         , p_debug                   => NVL(fnd_profile.value('EAM_DEBUG'), 'N')
         , p_debug_filename          => 'convertwo.log'
         , p_output_dir              => l_output_dir
         );


    EAM_ERROR_MESSAGE_PVT.Get_Message(l_message_text, l_entity_index, l_entity_id, l_message_type);
       debug('Return status:' || p_return_status);
       debug('Error message:' || SUBSTRB(l_message_text,1,200));
    IF( l_slog ) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Return status:' || p_return_status);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'Error message:' || SUBSTRB(l_message_text,1,200));
    END IF;
  END convert_work_orders;


END;

/
