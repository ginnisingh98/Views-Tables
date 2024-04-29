--------------------------------------------------------
--  DDL for Package Body FEM_BI_DIMENSION_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BI_DIMENSION_UTILS_PKG" AS
/* $Header: fem_bi_dim_utils.plb 120.1.12010000.2 2010/02/03 18:50:40 ghall ship $ */

-------------------------------
-- Declare package constants --
-------------------------------

  -- Log Level Constants
  G_LOG_LEVEL_STATEMENT       constant number := FND_LOG.Level_Statement; --1--
  G_LOG_LEVEL_PROCEDURE       constant number := FND_LOG.Level_Procedure; --2--
  G_LOG_LEVEL_EVENT           constant number := FND_LOG.Level_Event;     --3--
  G_LOG_LEVEL_EXCEPTION       constant number := FND_LOG.Level_Exception; --4--
  G_LOG_LEVEL_ERROR           constant number := FND_LOG.Level_Error;     --5--
  G_LOG_LEVEL_UNEXPECTED      constant number := FND_LOG.Level_Unexpected;--6--

------------------------------
-- Declare package messages --
------------------------------
  G_GL_POST_201               constant varchar2(30) := 'FEM_GL_POST_201';
  G_GL_POST_202               constant varchar2(30) := 'FEM_GL_POST_202';
  G_GL_POST_203               constant varchar2(30) := 'FEM_GL_POST_203';
  G_GL_POST_206               constant varchar2(30) := 'FEM_GL_POST_206';
  G_GL_POST_215               constant varchar2(30) := 'FEM_GL_POST_215';

  G_BI_ATTR_NO_ATTRIBUTES_WRN constant varchar2(30) := 'FEM_BI_ATTR_NO_ATTRIBUTES_WRN';

  G_BI_ATTR_INVALID_DIMENSION constant varchar2(30) := 'FEM_BI_ATTR_INVALID_DIMENSION';
  G_BI_ATTR_REQ_STATUS        constant varchar2(30) := 'FEM_BI_ATTR_REQ_STATUS';
  G_BI_ATTR_REQ_SUB_FAILURE   constant varchar2(30) := 'FEM_BI_ATTR_REQ_SUB_FAILURE';
  G_BI_ATTR_REQ_SUB_SUCCESS   constant varchar2(30) := 'FEM_BI_ATTR_REQ_SUB_SUCCESS';

--------------------------------------
-- Declare package type definitions --
--------------------------------------

-------------------------------
-- Declare package variables --
-------------------------------

  -- FND_GLOBAL variables
  g_req_id                        number;
  g_user_id                       number;
  g_login_id                      number;

--------------------------------
-- Declare package exceptions --
--------------------------------

  -- Materialized View Does Not Exist Exception
  g_mv_notexists_exception        exception;
  pragma exception_init(g_mv_notexists_exception,-12003);

  -- Materialized View Exists Exception
  g_mv_exists_exception           exception;
  pragma exception_init(g_mv_exists_exception,-12006);

  -- Materialized View Create Exception
  g_mv_create_exception           exception;

-----------------------------------------------
-- Declare private procedures and functions --
-----------------------------------------------

FUNCTION Transformation (
  p_dimension_varchar_label       in varchar2
  ,p_build_mode                   in varchar2 := 'DEFERRED'
  ,p_refresh_mode                 in varchar2 := 'COMPLETE'
  ,p_enable_qrewrite              in varchar2 := 'N'
  ,p_next_extent                  in varchar2 := '2M'
  ,p_seed_db_link                 in varchar2 := null
) RETURN varchar2;

PROCEDURE Create_MV_Objects (
  p_attr_mv_name_prefix           in varchar2
  ,p_attr_query                   in long
  ,p_attr_vl_query_select         in long
  ,p_member_col                   in varchar2
  ,p_member_display_code_col      in varchar2
  ,p_member_name_col              in varchar2
  ,p_value_set_select             in varchar2
  ,p_data_tablespace              in varchar2
  ,p_index_tablespace             in varchar2
  ,p_storage                      in varchar2
  ,p_build_mode                   in varchar2
  ,p_refresh_mode                 in varchar2
  ,p_enable_qrewrite              in varchar2
);

PROCEDURE Get_Dim_Attribute_Sql (
  p_dimension_id                  in number
  ,p_attribute_table_name         in varchar2
  ,p_member_col                   in varchar2
  ,p_value_set_required_flag      in varchar2
  ,x_attrd_attr_select            out nocopy long
  ,x_attrn_attr_select            out nocopy long
  ,x_attrn_vl_attr_select         out nocopy long
);

PROCEDURE Get_Seed_Dim_Attribute_Sql (
  p_dimension_id                  in number
  ,p_attribute_table_name         in varchar2
  ,p_member_col                   in varchar2
  ,p_value_set_required_flag      in varchar2
  ,p_seed_db_link                 in varchar2
  ,x_attrd_attr_select            out nocopy long
  ,x_attrn_attr_select            out nocopy long
  ,x_attrn_vl_attr_select         out nocopy long
);

--------------------------------------------------------------------------------
--  Package bodies for functions/procedures
--------------------------------------------------------------------------------

-- Public Function and Procedure Bodies ---------------------------------------

/*===========================================================================+
 | PROCEDURE
 |   Run_Transformation
 |
 | DESCRIPTION
 |   Runs Attribute Transformation for all supported dimensions
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |   x_errbuf                   Standard Concurrent Program parameter
 |   x_retcode                  Standard Concurrent Program parameter
 |   p_dimension_varchar_label  Dimension Varchar Label
 |   p_seed_db_link             Seed DB Link (INTERNAL USE ONLY)
 +===========================================================================*/

PROCEDURE Run_Transformation (
  x_errbuf                        out nocopy varchar2
  ,x_retcode                      out nocopy varchar2
  ,p_dimension_varchar_label      in varchar2
  ,p_seed_db_link                 in varchar2 := null
) IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(100) := 'Run_Transformation';

  ---------------------
  -- Declare cursors --
  ---------------------
  cursor l_bi_attr_dims_csr is
    select *
    from fem_bi_attr_dimensions_v
    where dimension_varchar_label <> 'ALL'
    order by dimension_varchar_label;

  cursor l_child_requests_csr (p_parent_request_id number) is
    select *
    from fnd_concurrent_requests
    where parent_request_id = p_parent_request_id;

  -------------------
  -- Declare Types --
  -------------------
  type bi_attr_dims_table   is table of fem_bi_attr_dimensions_v%rowtype;
  type child_requests_table is table of fnd_concurrent_requests%rowtype;

  -----------------------
  -- Declare variables --
  -----------------------
  l_bi_attr_dims_tbl              bi_attr_dims_table;
  l_child_requests_tbl            child_requests_table;

  l_module_name                   varchar2(200);
  l_function_name                 varchar2(200);

  l_request_data                  varchar2(100);

  l_child_request_id              number;

  l_dimension_name                varchar2(80);

  l_phase                         varchar2(100);
  l_status                        varchar2(100);
  l_dev_phase                     varchar2(100);
  l_dev_status                    varchar2(100);
  l_message                       varchar2(500);

  l_dummy_number                  number;
  l_dummy_boolean                 boolean;

  l_completion_status             varchar2(30);

  l_warnings                      number := 0;
  l_errors                        number := 0;

  l_attr_trans_invalid_dim_err    exception;
  l_attr_trans_child_sub_failed   exception;

BEGIN

  l_module_name := G_MODULE||'.'||lower(l_api_name);
  l_function_name := G_PACKAGE_NAME||'.'||l_api_name;

  -------------------------------------------
  -- Start Procedure Logging and Messaging --
  -------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.begin'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  g_req_id := nvl(FND_GLOBAL.Conc_Request_ID,-1);
  g_user_id := nvl(FND_GLOBAL.User_ID,-1);
  g_login_id := nvl(FND_GLOBAL.Conc_Login_ID, FND_GLOBAL.Login_ID);

  ------------------------------
  -- Validate input parameter --
  ------------------------------
  begin
    select 1 into l_dummy_number
    from fem_bi_attr_dimensions_v
    where dimension_varchar_label = p_dimension_varchar_label;
  exception
    when no_data_found then
      raise l_attr_trans_invalid_dim_err;
    when others then
      raise;
  end;

  ----------------------
  -- Start Processing --
  ----------------------
  if (p_dimension_varchar_label <> 'ALL') then

    /***********************************************************************
      Individual execution does not use FND_CONC_GLOBAL
    ************************************************************************/

    -- Call Transformation
    l_completion_status := Transformation (
      p_dimension_varchar_label => p_dimension_varchar_label
      ,p_seed_db_link           => p_seed_db_link
    );

  else

    /***********************************************************************
      Batch execution uses FND_CONC_GLOBAL

      Read the value from REQUEST_DATA. If this is the first run of
      the program, then this value will be NULL. Thus, submitting
      child requests. Otherwise,the program is reawaken and REQUEST_DATA
      will be the value that we passed to SET_REQ_GLOBALS on the previous
      run.

      References for PL/SQL Concurrent Processing Recursive Calls
      -----------------------------------------------------------
      1. Chapter 21: PL/SQL APIs for Concurrent Processing,
        Oracle Applications Developers Guide,
      2. Note 221542.1: Sample Code for FND_SUBMIT and FND_REQUEST API's
      3. WSHDDSHB.pls
      4. cefcshfb.pls
    ************************************************************************/

    l_request_data := FND_CONC_GLOBAL.Request_Data;

    if l_request_data is null then

      /**********************************************************************
        Parent is initiated
      **********************************************************************/
      -- Get Dimension information
      open l_bi_attr_dims_csr;
      fetch l_bi_attr_dims_csr bulk collect into l_bi_attr_dims_tbl;
      close l_bi_attr_dims_csr;

      -- Run transformation for each dimension using a child process
      for i in 1..l_bi_attr_dims_tbl.LAST loop

        if (p_seed_db_link is not null) then

          l_child_request_id :=
            FND_REQUEST.Submit_Request (
              application  => G_FEM
              ,program     => 'FEM_BI_DIM_ATTR_TRANS'
              ,description => l_bi_attr_dims_tbl(i).dimension_name
              ,start_time  => NULL
              ,sub_request => TRUE
              ,argument1   => l_bi_attr_dims_tbl(i).dimension_varchar_label
              ,argument2   => p_seed_db_link
            );

        else

          l_child_request_id :=
            FND_REQUEST.Submit_Request (
              application  => G_FEM
              ,program     => 'FEM_BI_DIM_ATTR_TRANS'
              ,description => l_bi_attr_dims_tbl(i).dimension_name
              ,start_time  => NULL
              ,sub_request => TRUE
              ,argument1   => l_bi_attr_dims_tbl(i).dimension_varchar_label
            );

        end if;

        if l_child_request_id = 0 then

          -- If a request submission is failed, raise an exception
          l_dimension_name := l_bi_attr_dims_tbl(i).dimension_name;

          x_errbuf := FND_MESSAGE.Get;

          raise l_attr_trans_child_sub_failed;

        else

          FEM_ENGINES_PKG.User_Message (
            p_app_name  => G_FEM
            ,p_msg_name => G_BI_ATTR_REQ_SUB_SUCCESS
            ,p_token1   => 'DIMENSION'
            ,p_value1   => l_bi_attr_dims_tbl(i).dimension_name
            ,p_token2   => 'REQ_ID'
            ,p_value2   => to_char(l_child_request_id)
          );

          FEM_ENGINES_PKG.Tech_Message (
            p_severity  => G_LOG_LEVEL_STATEMENT
            ,p_module   => l_module_name||'.child_req_submission'
            ,p_app_name => G_FEM
            ,p_msg_name => G_BI_ATTR_REQ_SUB_SUCCESS
            ,p_token1   => 'DIMENSION'
            ,p_value1   => l_bi_attr_dims_tbl(i).dimension_name
            ,p_token2   => 'REQ_ID'
            ,p_value2   => to_char(l_child_request_id)
          );

        end if;

      end loop;

      --
      -- Put the program into the PAUSED status and indicate the end of
      -- initial execution
      --
      FND_CONC_GLOBAL.Set_Req_Globals (
        conc_status   => 'PAUSED'
        ,request_data => 'SUBMITTED'
      );

      l_completion_status := 'NORMAL';

    else -- if l_request_data is null then

      /**********************************************************************
        Parent is reawakened
      **********************************************************************/
      -- Get child process ids
      open l_child_requests_csr (g_req_id);
      fetch l_child_requests_csr bulk collect into l_child_requests_tbl;
      close l_child_requests_csr;

      for i in 1..l_child_requests_tbl.LAST loop

        l_status := NULL;
        l_dev_status := NULL;

        l_dummy_boolean :=
          FND_CONCURRENT.Get_Request_Status (
            request_id  => l_child_requests_tbl(i).request_id
            ,phase      => l_phase
            ,status     => l_status
            ,dev_phase  => l_dev_phase
            ,dev_status => l_dev_status
            ,message    => l_message
          );

        if l_dev_status = 'WARNING' then
          l_warnings:= l_warnings + 1;
        elsif l_dev_status <> 'NORMAL' then
          l_errors := l_errors + 1;
        end if;

        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_STATEMENT
          ,p_module   => l_module_name||'.child_req_status'
          ,p_app_name => G_FEM
          ,p_msg_name => G_BI_ATTR_REQ_STATUS
          ,p_token1   => 'DIMENSION'
          ,p_value1   => l_child_requests_tbl(i).description
          ,p_token2   => 'REQ_ID'
          ,p_value2   => to_char(l_child_requests_tbl(i).request_id)
          ,p_token3   => 'STATUS'
          ,p_value3   => l_status
        );

        FEM_ENGINES_PKG.User_Message (
          p_app_name  => G_FEM
          ,p_msg_name => G_BI_ATTR_REQ_STATUS
          ,p_token1   => 'DIMENSION'
          ,p_value1   => l_child_requests_tbl(i).description
          ,p_token2   => 'REQ_ID'
          ,p_value2   => to_char(l_child_requests_tbl(i).request_id)
          ,p_token3   => 'STATUS'
          ,p_value3   => l_status
        );

      end loop;

      if l_errors = 0  and l_warnings = 0 then

        -- If all dimensions transformations are successful
        l_completion_status := 'NORMAL';

      elsif (l_errors > 0) and (l_errors = l_child_requests_tbl.count) then

        -- If all dimensions transformations are failed
        l_completion_status := 'ERROR';

      else

        -- If some dimensions transformations are successful
        l_completion_status := 'WARNING';

      end if;

    end if; -- if l_request_data is null then

  end if; -- if p_dimension_varchar_label = 'ALL' then

  -----------------------------------------
  -- End Procedure Logging and Messaging --
  -----------------------------------------
  if l_completion_status = 'NORMAL' then

    x_retcode := '0';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_PROCEDURE
      ,p_module   => l_module_name||'.end'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_202
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_202
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

  elsif l_completion_status = 'WARNING' then

    x_retcode := '1';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_PROCEDURE
      ,p_module   => l_module_name||'.end'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_206
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_206
    );

  else

    x_retcode := '2';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_PROCEDURE
      ,p_module   => l_module_name||'.end'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

  end if;

EXCEPTION

  when l_attr_trans_invalid_dim_err then

    rollback;

    x_retcode := '2';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.invalid_dimension'
      ,p_app_name => G_FEM
      ,p_msg_name => G_BI_ATTR_INVALID_DIMENSION
      ,p_token1   => 'DIMENSION'
      ,p_value1   => p_dimension_varchar_label
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_BI_ATTR_INVALID_DIMENSION
      ,p_token1   => 'DIMENSION'
      ,p_value1   => p_dimension_varchar_label
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.invalid_dimension'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

  when l_attr_trans_child_sub_failed then

    rollback;

    x_retcode := '2';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.sub_failed'
      ,p_app_name => G_FEM
      ,p_msg_name => G_BI_ATTR_REQ_SUB_FAILURE
      ,p_token1   => 'DIMENSION'
      ,p_value1   => l_dimension_name
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_BI_ATTR_REQ_SUB_FAILURE
      ,p_token1   => 'DIMENSION'
      ,p_value1   => l_dimension_name
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.sub_failed'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

  when others then

    rollback;

    x_retcode := '2';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

END Run_Transformation;


/*===========================================================================+
 | PROCEDURE
 |   Get_Pago_Cal_Period_ID
 |
 | DESCRIPTION
 |   Returns the prior Calendar Period ID for the given Calendar Period.
 |
 |   The returned Calendar Period will have the same Calendar, Dimension Group,
 |   and Adjustment Period Flag value.
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |   p_cal_period_id            Calendar Period Id
 +===========================================================================*/

FUNCTION Get_Pago_Cal_Period_ID (
  p_cal_period_id                 in number
) RETURN number
IS

  l_pago_cal_period_id           number;

  cursor l_pago_cal_periods_csr (
    p_cal_period_id               in number
  ) is
    select cp2.cal_period_id
    from fem_cal_periods_b cp
    ,fem_cal_periods_attr cpa_adj
    ,fem_cal_periods_b cp2
    ,fem_cal_periods_attr cpa2_adj
    ,fem_dimensions_b dim
    ,fem_dim_attributes_b a
    ,fem_dim_attr_versions_b v
    where cp.cal_period_id = p_cal_period_id
    and dim.dimension_varchar_label = 'CAL_PERIOD'
    and a.dimension_id = dim.dimension_id
    and a.attribute_varchar_label = 'ADJ_PERIOD_FLAG'
    and v.attribute_id = a.attribute_id
    and v.default_version_flag = 'Y'
    and cpa_adj.attribute_id = a.attribute_id
    and cpa_adj.version_id = v.version_id
    and cpa_adj.cal_period_id = cp.cal_period_id
    and cpa2_adj.attribute_id = a.attribute_id
    and cpa2_adj.version_id = v.version_id
    and cpa2_adj.cal_period_id = cp2.cal_period_id
    and cp2.calendar_id = cp.calendar_id
    and cp2.dimension_group_id = cp.dimension_group_id
    and cpa2_adj.dim_attribute_varchar_member = cpa_adj.dim_attribute_varchar_member
    and cp2.cal_period_id < cp.cal_period_id
    order by cp2.cal_period_id desc;

BEGIN

  open l_pago_cal_periods_csr (p_cal_period_id);

  fetch l_pago_cal_periods_csr
  into l_pago_cal_period_id;

  close l_pago_cal_periods_csr;

  return l_pago_cal_period_id;

EXCEPTION

  when others then
    if (l_pago_cal_periods_csr%isopen) then
      close l_pago_cal_periods_csr;
    end if;
    return null;

END Get_Pago_Cal_Period_ID;


/*===========================================================================+
 | PROCEDURE
 |   Get_Yago_Cal_Period_ID
 |
 | DESCRIPTION
 |   Returns the prior year Calendar Period ID for the given Calendar Period.
 |
 |   The returned Calendar Period will have the same Calendar and Dimension
 |   Group.  As Adjusment Periods can have overlapping date ranges, only
 |   non adjustment periods are processed and returned.
 |
 | SCOPE - PUBLIC
 |
 | ARGUMENTS
 |   p_cal_period_id            Calendar Period Id
 +===========================================================================*/

FUNCTION Get_Yago_Cal_Period_ID (
  p_cal_period_id                 in number
) RETURN number
IS

  l_yago_cal_period_id           number;

  cursor l_yago_cal_periods_csr (
    p_cal_period_id               in number
  ) is
    select cp2.cal_period_id
    from fem_cal_periods_b cp
    ,fem_cal_periods_attr cpa_adj
    ,fem_cal_periods_attr cpa_start
    ,fem_cal_periods_attr cpa_end
    ,fem_cal_periods_b cp2
    ,fem_cal_periods_attr cpa2_adj
    ,fem_cal_periods_attr cpa2_start
    ,fem_cal_periods_attr cpa2_end
    ,fem_dimensions_b dim
    ,fem_dim_attributes_b a_adj
    ,fem_dim_attr_versions_b v_adj
    ,fem_dim_attributes_b a_start
    ,fem_dim_attr_versions_b v_start
    ,fem_dim_attributes_b a_end
    ,fem_dim_attr_versions_b v_end
    where cp.cal_period_id = p_cal_period_id
    and dim.dimension_varchar_label = 'CAL_PERIOD'
    and a_adj.dimension_id = dim.dimension_id
    and a_adj.attribute_varchar_label = 'ADJ_PERIOD_FLAG'
    and v_adj.attribute_id = a_adj.attribute_id
    and v_adj.default_version_flag = 'Y'
    and a_start.dimension_id = dim.dimension_id
    and a_start.attribute_varchar_label = 'CAL_PERIOD_START_DATE'
    and v_start.attribute_id = a_start.attribute_id
    and v_start.default_version_flag = 'Y'
    and a_end.dimension_id = dim.dimension_id
    and a_end.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
    and v_end.attribute_id = a_end.attribute_id
    and v_end.default_version_flag = 'Y'
    and cpa_adj.attribute_id = a_adj.attribute_id
    and cpa_adj.version_id = v_adj.version_id
    and cpa_adj.cal_period_id = cp.cal_period_id
    and cpa_adj.dim_attribute_varchar_member = 'N'
    and cpa_start.attribute_id = a_start.attribute_id
    and cpa_start.version_id = v_start.version_id
    and cpa_start.cal_period_id = cp.cal_period_id
    and cpa_end.attribute_id = a_end.attribute_id
    and cpa_end.version_id = v_end.version_id
    and cpa_end.cal_period_id = cp.cal_period_id
    and cpa2_adj.attribute_id = a_adj.attribute_id
    and cpa2_adj.version_id = v_adj.version_id
    and cpa2_adj.cal_period_id = cp2.cal_period_id
    and cpa2_adj.dim_attribute_varchar_member = 'N'
    and cpa2_start.attribute_id = a_start.attribute_id
    and cpa2_start.version_id = v_start.version_id
    and cpa2_start.cal_period_id = cp2.cal_period_id
    and cpa2_end.attribute_id = a_end.attribute_id
    and cpa2_end.version_id = v_end.version_id
    and cpa2_end.cal_period_id = cp2.cal_period_id
    and cp2.calendar_id = cp.calendar_id
    and cp2.dimension_group_id = cp.dimension_group_id
    and add_months(cpa_end.date_assign_value,-12) between cpa2_start.date_assign_value and cpa2_end.date_assign_value
    and add_months(cpa_start.date_assign_value,-12) between cpa2_start.date_assign_value and cpa2_end.date_assign_value;

BEGIN

  open l_yago_cal_periods_csr (p_cal_period_id);

  fetch l_yago_cal_periods_csr
  into l_yago_cal_period_id;

  close l_yago_cal_periods_csr;

  return l_yago_cal_period_id;

EXCEPTION

  when others then
    if (l_yago_cal_periods_csr%isopen) then
      close l_yago_cal_periods_csr;
    end if;
    return null;

END Get_Yago_Cal_Period_ID;


/*===========================================================================+
 | FOR INTERNAL USE ONLY.
 +===========================================================================*/

PROCEDURE Run_Seed_Transformation (
  p_dimension_varchar_label       in varchar2
  ,p_seed_db_link                 in varchar2
  ,x_completion_status            out nocopy varchar2
) IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(100) := 'Run_Seed_Transformation';

  ---------------------
  -- Declare cursors --
  ---------------------
  cursor l_bi_attr_dims_csr is
    select *
    from fem_bi_attr_dimensions_v
    where dimension_varchar_label <> 'ALL'
    order by dimension_varchar_label;

  -------------------
  -- Declare Types --
  -------------------
  type bi_attr_dims_table is table of fem_bi_attr_dimensions_v%rowtype;

  -----------------------
  -- Declare variables --
  -----------------------
  l_bi_attr_dims_tbl              bi_attr_dims_table;

  l_module_name                   varchar2(200);
  l_function_name                 varchar2(200);

  l_dummy_number                  number;
  l_dummy_boolean                 boolean;

  l_completion_status             varchar2(30);

  l_warnings                      number := 0;
  l_errors                        number := 0;

  l_attr_trans_invalid_dim_err    exception;

BEGIN

  l_module_name := G_MODULE||'.'||lower(l_api_name);
  l_function_name := G_PACKAGE_NAME||'.'||l_api_name;

  -------------------------------------------
  -- Start Procedure Logging and Messaging --
  -------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.begin'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  ------------------------------
  -- Validate input parameter --
  ------------------------------
  begin
    select 1 into l_dummy_number
    from fem_bi_attr_dimensions_v
    where dimension_varchar_label = p_dimension_varchar_label;
  exception
    when no_data_found then
      raise l_attr_trans_invalid_dim_err;
    when others then
      raise;
  end;

  ----------------------
  -- Start Processing --
  ----------------------
  if (p_dimension_varchar_label <> 'ALL') then

    -- Call Transformation
    x_completion_status := Transformation (
      p_dimension_varchar_label => p_dimension_varchar_label
      ,p_seed_db_link           => p_seed_db_link
    );

  else

    -- Get Dimension information
    open l_bi_attr_dims_csr;
    fetch l_bi_attr_dims_csr bulk collect into l_bi_attr_dims_tbl;
    close l_bi_attr_dims_csr;

    -- Run transformation for each dimension using a child process
    for i in 1..l_bi_attr_dims_tbl.LAST loop

      l_completion_status := Transformation (
        p_dimension_varchar_label => l_bi_attr_dims_tbl(i).dimension_varchar_label
        ,p_seed_db_link           => p_seed_db_link
      );

      if l_completion_status = 'WARNING' then
        l_warnings:= l_warnings + 1;
      elsif l_completion_status <> 'NORMAL' then
        l_errors := l_errors + 1;
      end if;

    end loop;

    if l_errors = 0  and l_warnings = 0 then

      -- If all dimensions transformations are successful
      x_completion_status := 'NORMAL';

    elsif (l_errors > 0) then

      -- If all dimensions transformations are failed
      x_completion_status := 'ERROR';

    else

      -- If some dimensions transformations are successful
      x_completion_status := 'WARNING';

    end if;

  end if; -- if p_dimension_varchar_label = 'ALL' then

  -----------------------------------------
  -- End Procedure Logging and Messaging --
  -----------------------------------------
  if x_completion_status = 'NORMAL' then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_PROCEDURE
      ,p_module   => l_module_name||'.end'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_202
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

  elsif x_completion_status = 'WARNING' then

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_PROCEDURE
      ,p_module   => l_module_name||'.end'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_206
    );

    x_completion_status := x_completion_status||': '||l_warnings;

  else

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_PROCEDURE
      ,p_module   => l_module_name||'.end'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    x_completion_status := x_completion_status||': '||l_errors;

  end if;

EXCEPTION

  when l_attr_trans_invalid_dim_err then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.invalid_dimension'
      ,p_app_name => G_FEM
      ,p_msg_name => G_BI_ATTR_INVALID_DIMENSION
      ,p_token1   => 'DIMENSION'
      ,p_value1   => p_dimension_varchar_label
    );

    x_completion_status := 'ERROR: INVALID_DIMENSION';

  when others then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    x_completion_status := 'ERROR: OTHER_EXCEPTION';

END Run_Seed_Transformation;


-- Private Function and Procedure Bodies ---------------------------------------

/*===========================================================================+
 | FUNCTION
 |   Transformation
 |
 | DESCRIPTION
 |   Transforms an individual dimension attribute model.
 |
 | SCOPE - PRIVATE
 |
 | ARGUMENTS
 |   p_dimension_varchar_label  Dimension Varchar Label
 +===========================================================================*/

FUNCTION Transformation (
  p_dimension_varchar_label       in varchar2
  ,p_build_mode                   in varchar2 := 'DEFERRED'
  ,p_refresh_mode                 in varchar2 := 'COMPLETE'
  ,p_enable_qrewrite              in varchar2 := 'N'
  ,p_next_extent                  in varchar2 := '2M'
  ,p_seed_db_link                 in varchar2 := null
) RETURN varchar2
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(100) := 'Transformation';

  -----------------------
  -- Declare variables --
  -----------------------
  l_return_status                 varchar2(30);

  l_module_name                   varchar2(200);
  l_function_name                 varchar2(200);

  l_data_tablespace               varchar2(30);
  l_index_tablespace              varchar2(30);
  l_enable_qrewrite               varchar2(30);
  l_storage                       varchar2(200);

  l_dimension_id                  number;
  l_dimension_name                varchar2(80);
  l_member_b_table_name           varchar2(30);
  l_member_tl_table_name          varchar2(30);
  l_attribute_table_name          varchar2(30);
  l_member_col                    varchar2(30);
  l_member_display_code_col       varchar2(30);
  l_member_name_col               varchar2(30);
  l_member_description_col        varchar2(200);
  l_group_use_code                varchar2(30);
  l_value_set_required_flag       varchar2(1);
  l_enabled_applicable_flag       varchar2(1);
  l_read_only_applicable_flag     varchar2(1);

  l_value_set_select              varchar2(200);

  l_attrd_query                   long;
  l_attrd_query_select            long;
  l_attrd_attr_select             long;
  l_attrd_query_from              varchar2(2000);
  l_attrd_query_where             varchar2(2000);

  l_attrn_query                   long;
  l_attrn_query_select            long;
  l_attrn_attr_select             long;
  l_attrn_query_from              varchar2(2000);
  l_attrn_query_where             varchar2(2000);

  l_attrn_vl_query_select         long;
  l_attrn_vl_attr_select          long;

  l_no_attributes_exception       exception;

BEGIN

  l_return_status := 'NORMAL';

  l_module_name :=
    G_MODULE||'.'||lower(l_api_name)||'.'||lower(p_dimension_varchar_label);
  l_function_name :=
    G_PACKAGE_NAME||'.'||l_api_name ||'.'||p_dimension_varchar_label;

  -------------------------------------------
  -- Start Procedure Logging and Messaging --
  -------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.begin'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  if p_enable_qrewrite = 'Y' then
    l_enable_qrewrite := 'ENABLE';
  else
    l_enable_qrewrite := 'DISABLE';
  end if;

  -- Set the Storage Clause for the CREATE MATERIALIZED VIEW statement
  l_storage :=
  ' STORAGE(INITIAL 4K NEXT '||p_next_extent||' MINEXTENTS 1 MAXEXTENTS UNLIMITED PCTINCREASE 0)';

  -- Get the data and index tablespace names for creating materialized views and their indexes
  l_data_tablespace := ad_mv.g_mv_data_tablespace;
  l_index_tablespace := ad_mv.g_mv_index_tablespace;

  ----------------------------------
  -- Get the Dimension's metadata --
  ----------------------------------
  select dimension_id
  ,dimension_name
  ,member_b_table_name
  ,member_tl_table_name
  ,attribute_table_name
  ,member_col
  ,decode(member_display_code_col
    ,member_col,null
    ,member_display_code_col)
  ,decode(member_name_col
    ,member_display_code_col,null
    ,member_col,null
    ,member_name_col)
  ,decode(member_description_col
    ,member_name_col,null
    ,member_display_code_col,null
    ,member_col,null
    ,member_description_col)
  ,group_use_code
  ,value_set_required_flag
  ,logical_delete_applicable_flag
  ,read_only_applicable_flag
  into l_dimension_id
  ,l_dimension_name
  ,l_member_b_table_name
  ,l_member_tl_table_name
  ,l_attribute_table_name
  ,l_member_col
  ,l_member_display_code_col
  ,l_member_name_col
  ,l_member_description_col
  ,l_group_use_code
  ,l_value_set_required_flag
  ,l_enabled_applicable_flag
  ,l_read_only_applicable_flag
  from fem_xdim_dimensions_vl
  where dimension_varchar_label = p_dimension_varchar_label;

  ----------------------------------------------------------------------------
  -- Initialize variables used in dynamic SQL based on dimension properties --
  ----------------------------------------------------------------------------
  l_attrd_query_select :=
  ' select b.'||l_member_col;

  l_attrd_query_from :=
  ' from '||l_member_b_table_name||' b';

  l_attrd_query_where :=
  ' where 1=1';

  l_attrn_query_select :=
  ' select b.'||l_member_col;

  l_attrn_vl_query_select :=
  ' select '||l_member_col;

  l_attrn_query_from :=
  ' from '||l_member_b_table_name||' b'||
  ' ,'||l_member_tl_table_name||' tl';

  l_attrn_query_where :=
  ' where tl.'||l_member_col||' = b.'||l_member_col;

  -- Must include value_set_id columns if a VSR dimension
  if (l_value_set_required_flag = 'Y') then

    l_value_set_select :=
    ' ,value_set_id';

    l_attrd_query_select := l_attrd_query_select||
    ' ,b.value_set_id';

    l_attrn_query_select := l_attrn_query_select||
    ' ,b.value_set_id';

    l_attrn_vl_query_select := l_attrn_vl_query_select||
    ' ,value_set_id';

    l_attrn_query_where := l_attrn_query_where||
    ' and tl.value_set_id = b.value_set_id';

  end if;

  l_attrn_query_select := l_attrn_query_select||
  ' ,tl.language'||
  ' ,tl.source_lang';

  if (l_member_display_code_col is not null) then

    l_attrd_query_select := l_attrd_query_select||
    ' ,b.'||l_member_display_code_col;

  end if;

  if (l_member_name_col is not null) then

    l_attrn_query_select := l_attrn_query_select||
    ' ,tl.'||l_member_name_col;

    l_attrn_vl_query_select := l_attrn_vl_query_select||
    ' ,'||l_member_name_col;

  end if;

  if (l_member_description_col is not null) then

    l_attrn_query_select := l_attrn_query_select||
    ' ,tl.'||l_member_description_col;

    l_attrn_vl_query_select := l_attrn_vl_query_select||
    ' ,'||l_member_description_col;

  end if;

  if (l_group_use_code <> 'NOT_SUPPORTED') then

    -- If dimension supports dimension groups, then add the necessary
    -- dimension group columns and tables before building final SELECT
    -- statement.

    l_attrd_query_select := l_attrd_query_select||
    ' ,b.dimension_group_id'||
    ' ,dgb.dimension_group_display_code';

    l_attrd_query_from := l_attrd_query_from||
    ' ,fem_dimension_grps_b dgb';

    l_attrd_query_where := l_attrd_query_where||
    ' and dgb.dimension_group_id (+) = b.dimension_group_id';

    l_attrn_query_select := l_attrn_query_select||
    ' ,b.dimension_group_id'||
    ' ,(select dgtl.dimension_group_name'||
    '   from fem_dimension_grps_tl dgtl'||
    '   where dgtl.dimension_group_id = b.dimension_group_id'||
    '   and dgtl.language = tl.language'||
    ' ) as dimension_group_name'||
    ' ,(select dgtl.description'||
    '   from fem_dimension_grps_tl dgtl'||
    '   where dgtl.dimension_group_id = b.dimension_group_id'||
    '   and dgtl.language = tl.language'||
    ' ) as dimension_group_desc';

    l_attrn_vl_query_select := l_attrn_vl_query_select||
    ' ,dimension_group_id'||
    ' ,dimension_group_name'||
    ' ,dimension_group_desc';

  end if;

  -- Need to add the Calendar colums for the Calendar Period dimension
  -- Also add PAGO and YAGO columns as Calendar Period dimension columns for
  -- use in variance reporting.
  if (p_dimension_varchar_label = 'CAL_PERIOD') then

    l_attrd_query_select := l_attrd_query_select||
    ' ,b.calendar_id'||
    ' ,cal.calendar_display_code'||
    ' ,FEM_BI_DIMENSION_UTILS_PKG.Get_Pago_Cal_Period_ID(b.'||l_member_col||') pago_cal_period_id'||
    ' ,FEM_BI_DIMENSION_UTILS_PKG.Get_Yago_Cal_Period_ID(b.'||l_member_col||') yago_cal_period_id';

    l_attrd_query_from := l_attrd_query_from||
    ' ,fem_calendars_b cal';

    l_attrd_query_where := l_attrd_query_where||
    ' and cal.calendar_id = b.calendar_id';

    l_attrn_query_select := l_attrn_query_select||
    ' ,b.calendar_id'||
    ' ,cal.calendar_name'||
    ' ,cal.description as calendar_desc';

    l_attrn_vl_query_select := l_attrn_vl_query_select||
    ' ,calendar_id'||
    ' ,calendar_name'||
    ' ,calendar_desc';

    l_attrn_query_from := l_attrn_query_from||
    ' ,fem_calendars_tl cal';

    l_attrn_query_where := l_attrn_query_where||
    ' and cal.calendar_id = b.calendar_id'||
    ' and cal.language = tl.language';

  end if;

  if (l_enabled_applicable_flag = 'Y') then

    l_attrd_query_select := l_attrd_query_select||
    ' ,b.enabled_flag';

  end if;

  if (l_read_only_applicable_flag = 'Y') then

    l_attrd_query_select := l_attrd_query_select||
    ' ,b.read_only_flag';

  end if;

  l_attrd_query_select := l_attrd_query_select||
  ' ,b.personal_flag';

  -- Get the dynamic SQL for querying Attribute Values
  if (p_seed_db_link is not null) then

    Get_Seed_Dim_Attribute_Sql (
      p_dimension_id             => l_dimension_id
      ,p_attribute_table_name    => l_attribute_table_name
      ,p_member_col              => l_member_col
      ,p_value_set_required_flag => l_value_set_required_flag
      ,p_seed_db_link            => p_seed_db_link
      ,x_attrd_attr_select       => l_attrd_attr_select
      ,x_attrn_attr_select       => l_attrn_attr_select
      ,x_attrn_vl_attr_select    => l_attrn_vl_attr_select
    );

  else

    Get_Dim_Attribute_Sql (
      p_dimension_id             => l_dimension_id
      ,p_attribute_table_name    => l_attribute_table_name
      ,p_member_col              => l_member_col
      ,p_value_set_required_flag => l_value_set_required_flag
      ,x_attrd_attr_select       => l_attrd_attr_select
      ,x_attrn_attr_select       => l_attrn_attr_select
      ,x_attrn_vl_attr_select    => l_attrn_vl_attr_select
    );

  end if;

  if (l_attrd_attr_select is null) then

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_BI_ATTR_NO_ATTRIBUTES_WRN
      ,p_token1   => 'DIMENSION'
      ,p_value1   => l_function_name
    );

    l_return_status := 'WARNING';

  end if;

  l_attrd_query_select :=
    l_attrd_query_select||
    l_attrd_attr_select||
  ' ,b.created_by'||
  ' ,b.creation_date'||
  ' ,b.last_updated_by'||
  ' ,b.last_update_date'||
  ' ,b.last_update_login';

  l_attrn_query_select :=
    l_attrn_query_select||
    l_attrn_attr_select||
  ' ,tl.created_by'||
  ' ,tl.creation_date'||
  ' ,tl.last_updated_by'||
  ' ,tl.last_update_date'||
  ' ,tl.last_update_login';

  l_attrn_vl_query_select :=
    l_attrn_vl_query_select||
    l_attrn_vl_attr_select||
  ' ,created_by'||
  ' ,creation_date'||
  ' ,last_updated_by'||
  ' ,last_update_date'||
  ' ,last_update_login';

  ----------------------------------------------------
  -- Build the complete SQL for the Attribute Views --
  ----------------------------------------------------
  -- Attribute Value Diplay Codes
  l_attrd_query :=
    l_attrd_query_select||
    l_attrd_query_from||
    l_attrd_query_where;

--  for i in 0..(round((length(l_attrd_query)/255),0)) loop
--    dbms_output.put_line(substr(l_attrd_query,255*i+1,255));
--  end loop;

  -- Attribute Value Names
  l_attrn_query :=
    l_attrn_query_select||
    l_attrn_query_from||
    l_attrn_query_where;

--  for i in 0..(round((length(l_attrn_query)/255),0)) loop
--    dbms_output.put_line(substr(l_attrn_query,255*i+1,255));
--  end loop;

  -----------------------------------------------------------------
  -- Create the DB objects for supporting the Materialized Views --
  -----------------------------------------------------------------
  Create_MV_Objects (
    p_attr_mv_name_prefix      => l_attribute_table_name||'D'
    ,p_attr_query              => l_attrd_query
    ,p_attr_vl_query_select    => null
    ,p_member_col              => l_member_col
    ,p_member_display_code_col => l_member_display_code_col
    ,p_member_name_col         => null
    ,p_value_set_select        => l_value_set_select
    ,p_data_tablespace         => l_data_tablespace
    ,p_index_tablespace        => l_index_tablespace
    ,p_storage                 => l_storage
    ,p_build_mode              => p_build_mode
    ,p_refresh_mode            => p_refresh_mode
    ,p_enable_qrewrite         => l_enable_qrewrite
  );

  Create_MV_Objects (
    p_attr_mv_name_prefix      => l_attribute_table_name||'N'
    ,p_attr_query              => l_attrn_query
    ,p_attr_vl_query_select    => l_attrn_vl_query_select
    ,p_member_col              => l_member_col
    ,p_member_display_code_col => null
    ,p_member_name_col         => l_member_name_col
    ,p_value_set_select        => l_value_set_select
    ,p_data_tablespace         => l_data_tablespace
    ,p_index_tablespace        => l_index_tablespace
    ,p_storage                 => l_storage
    ,p_build_mode              => p_build_mode
    ,p_refresh_mode            => p_refresh_mode
    ,p_enable_qrewrite         => l_enable_qrewrite
  );

  -----------------------------------------
  -- End Procedure Logging and Messaging --
  -----------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.end'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  return(l_return_status);

EXCEPTION

  when g_mv_create_exception then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.mv_create_exception'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    return('ERROR');

  when others then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    return('ERROR');

END Transformation;


/*===========================================================================+
 | PROCEDURE
 |   Create_MV_Objects
 |
 | DESCRIPTION
 |   Creates all the DB Objects to supporting the Attribute Materialized
 ?   Views.
 |
 | SCOPE - PRIVATE
 |
 | ARGUMENTS
 |   p_attr_mv_name_prefix        Attribute MV Name Prefix
 |   p_attr_query                 Attribute MV Query Statement
 |   p_attr_vl_query_select       Attribute VL View Select Statement
 |   p_member_col                 Dimension Member ID Column Name
 |   p_member_display_code_col    Dimension Member Display Code Column Name
 |   p_member_name_col            Dimension Member Name Column Name
 |   p_value_set_select           Value Set Select Statement
 |   p_data_tablespace            MV Data Tablespace Name
 |   p_index_tablespace           MV Index Tablespace Name
 |   p_storage                    MV Storage Clause
 |   p_build_mode                 MV Build Mode
 |   p_refresh_mode               MV Refresh Mode
 |   p_enable_qrewrite            MV Enable Query Rewrite Clause
 +===========================================================================*/

PROCEDURE Create_MV_Objects (
  p_attr_mv_name_prefix           in varchar2
  ,p_attr_query                   in long
  ,p_attr_vl_query_select         in long
  ,p_member_col                   in varchar2
  ,p_member_display_code_col      in varchar2
  ,p_member_name_col              in varchar2
  ,p_value_set_select             in varchar2
  ,p_data_tablespace              in varchar2
  ,p_index_tablespace             in varchar2
  ,p_storage                      in varchar2
  ,p_build_mode                   in varchar2
  ,p_refresh_mode                 in varchar2
  ,p_enable_qrewrite              in varchar2
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(100) := G_PACKAGE_NAME||'.Create_MV_Objects';

  -----------------------
  -- Declare variables --
  -----------------------
  l_module_name                   varchar2(200);
  l_function_name                 varchar2(200);

  l_attr_v_name                   varchar2(30);
  l_attr_mv_name                  varchar2(30);
  l_attr_vl_name                  varchar2(30);

  l_pk_index_columns              varchar2(2000);
  l_u1_index_columns              varchar2(2000);

  l_dynamic_sql                   varchar2(2000);

BEGIN

  l_module_name :=
    G_MODULE||'.'||lower(l_api_name)||'.'||lower(p_attr_mv_name_prefix);
  l_function_name :=
    G_PACKAGE_NAME||'.'||l_api_name ||'.'||p_attr_mv_name_prefix;

  -------------------------------------------
  -- Start Procedure Logging and Messaging --
  -------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.begin'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------

  --  Set the names for the views and materialized views
  l_attr_v_name := p_attr_mv_name_prefix||'_V';
  l_attr_mv_name := p_attr_mv_name_prefix||'_MV';
  l_attr_vl_name := p_attr_mv_name_prefix||'_VL';

  ------------------------------------------
  -- Drop The Attribute Materialized View --
  ------------------------------------------
  begin

    l_dynamic_sql :=
    ' DROP MATERIALIZED VIEW '||l_attr_mv_name;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_STATEMENT
      ,p_module   => l_module_name||'.drop_mv'
      ,p_msg_text => l_dynamic_sql
    );

    execute immediate l_dynamic_sql;

  exception
    when g_mv_notexists_exception then null;
  end;

  ----------------------------------------------------------
  -- Create View For Collapsing Attribute Dimension Model --
  ----------------------------------------------------------
  if (G_LOG_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

    for i in 0..(round((length(p_attr_query)/4000),0)) loop

      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_STATEMENT
        ,p_module   => l_module_name||'.create_v.'||lower(l_attr_v_name)||'.'||i
        ,p_msg_text => substr(p_attr_query,4000*i+1,4000)
      );

    end loop;

  end if;

  execute immediate
  ' CREATE OR REPLACE VIEW '||l_attr_v_name||
  ' AS '||p_attr_query;

  --------------------------------------------
  -- Create The Attribute Materialized View --
  --------------------------------------------
  l_dynamic_sql :=
  ' CREATE MATERIALIZED VIEW '||l_attr_mv_name||
  ' TABLESPACE '||p_data_tablespace||
  ' INITRANS 4 MAXTRANS 255 '||
    p_storage||
  ' BUILD '||p_build_mode||
  ' USING INDEX TABLESPACE '||p_index_tablespace||
    p_storage||
  ' REFRESH '||p_refresh_mode ||' ON DEMAND '||
    p_enable_qrewrite||' QUERY REWRITE '||
  ' AS '||
  ' SELECT *'||
  ' FROM '||l_attr_v_name;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_STATEMENT
    ,p_module   => l_module_name||'.create_mv'
    ,p_msg_text => l_dynamic_sql
  );

  execute immediate l_dynamic_sql;

  -----------------------------------
  -- Create The Attribute MLS View --
  -----------------------------------
  if (p_attr_vl_query_select is not null) then

    l_dynamic_sql :=
    ' CREATE OR REPLACE VIEW '||l_attr_vl_name||
    ' AS'||
      p_attr_vl_query_select||
    ' FROM '||l_attr_mv_name||
    ' WHERE LANGUAGE = USERENV(''LANG'')';

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_STATEMENT
      ,p_module   => l_module_name||'.create_vl'
      ,p_msg_text => l_dynamic_sql
    );

    execute immediate l_dynamic_sql;

  end if;

  --------------------------------------------
  -- Create The Materialized View's Indexes --
  --------------------------------------------
  if (p_member_display_code_col is not null) then

    l_pk_index_columns :=
      p_member_col||
      p_value_set_select;

    l_u1_index_columns :=
      p_member_display_code_col||
      p_value_set_select;

  elsif (p_member_name_col is not null) then

    l_pk_index_columns :=
      p_member_col||
      p_value_set_select||
      ' ,language';

    l_u1_index_columns :=
      p_member_name_col||
      p_value_set_select||
      ' ,language';

  end if;

  -- Primary Key Index
  if (l_pk_index_columns is not null) then

    l_dynamic_sql :=
    ' CREATE INDEX '||l_attr_mv_name||'_PK'||
    ' ON '||l_attr_mv_name||' ('||
        l_pk_index_columns||
    ' )'||
    ' TABLESPACE '||p_index_tablespace||
    ' INITRANS 4 MAXTRANS 255 '||
    p_storage;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_STATEMENT
      ,p_module   => l_module_name||'.create_mv_pk'
      ,p_msg_text => l_dynamic_sql
    );

    execute immediate l_dynamic_sql;

  end if;

  -- Alternate Unique Index #1
  if (l_u1_index_columns is not null) then

    l_dynamic_sql :=
    ' CREATE INDEX '||l_attr_mv_name||'_U1'||
    ' ON '||l_attr_mv_name||' ('||
        l_u1_index_columns||
    ' )'||
    ' TABLESPACE '||p_index_tablespace||
    ' INITRANS 4 MAXTRANS 255 '||
    p_storage;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_STATEMENT
      ,p_module   => l_module_name||'.create_mv_u1'
      ,p_msg_text => l_dynamic_sql
    );

    execute immediate l_dynamic_sql;

  end if;

  -----------------------------------
  -- Refresh The Materialized View --
  -----------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_STATEMENT
    ,p_module   => l_module_name||'.refresh_mv'
    ,p_msg_text => l_attr_mv_name
  );

  DBMS_MVIEW.Refresh(l_attr_mv_name,'?');

  -----------------------------------------
  -- End Procedure Logging and Messaging --
  -----------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.end'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

EXCEPTION

  when others then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    raise g_mv_create_exception;

END Create_MV_Objects;


/*===========================================================================+
 | PROCEDURE
 |   Get_Dim_Attribute_Sql
 |
 | DESCRIPTION
 |   Gets dynamic SQL statement for selecting dimension attribute values.
 |
 | SCOPE - PRIVATE
 |
 | ARGUMENTS
 |   p_dimension_id             Dimension ID
 |   p_attribute_table_name     Attribute Table Name
 |   p_member_col               Member Column Name
 |   p_value_set_required_flag  Value Set Required Flag
 +===========================================================================*/

PROCEDURE Get_Dim_Attribute_Sql (
  p_dimension_id                  in number
  ,p_attribute_table_name         in varchar2
  ,p_member_col                   in varchar2
  ,p_value_set_required_flag      in varchar2
  ,x_attrd_attr_select            out nocopy long
  ,x_attrn_attr_select            out nocopy long
  ,x_attrn_vl_attr_select         out nocopy long
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(100) := G_PACKAGE_NAME||'.Get_Dim_Attribute_Sql';

  -----------------------
  -- Declare variables --
  -----------------------
  l_module_name                   varchar2(200);
  l_function_name                 varchar2(200);

  l_value_set_where               varchar2(100);

  l_attr_mem_b_tab                varchar2(30);
  l_attr_mem_tl_tab               varchar2(30);
  l_attr_mem_col                  varchar2(30);
  l_attr_mem_display_code_col     varchar2(30);
  l_attr_mem_name_col             varchar2(30);
  l_attrn_value_set_where         varchar2(100);
  l_attrd_value_set_where         varchar2(100);
  l_attrn_language_where          varchar2(100);

  l_attrn_sql_stmt                varchar2(2000);
  l_attrd_sql_stmt                varchar2(2000);
  l_attr_col                      varchar2(30);

  l_sign_attrd_sql_stmt           varchar2(2000);
  l_sign_attribute_id             number;
  l_sign_attr_version_id          number;

  l_bsc_attrn_sql_stmt            varchar2(2000);
  l_bsc_attrd_sql_stmt            varchar2(2000);
  l_bsc_attribute_id              number;
  l_bsc_attr_version_id           number;

  l_sign_attr_col_name            varchar2(30);
  l_basic_attr_col_name           varchar2(30);

BEGIN

  l_module_name :=
    G_MODULE||'.'||lower(l_api_name)||'.'||lower(p_attribute_table_name);
  l_function_name :=
    G_PACKAGE_NAME||'.'||l_api_name ||'.'||p_attribute_table_name;

  -------------------------------------------
  -- Start Procedure Logging and Messaging --
  -------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.begin'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  x_attrd_attr_select := null;
  x_attrn_attr_select := null;
  x_attrn_vl_attr_select := null;

  if (p_value_set_required_flag = 'Y') then
    l_value_set_where := ' and attr.value_set_id = b.value_set_id';
  end if;

  ------------------------------------------------------
  -- Loop through all Dimension Attribute Definitions --
  ------------------------------------------------------
  for attr_rec in (
    select a.attribute_id
    ,v.version_id
    ,a.attribute_varchar_label
    ,a.attribute_data_type_code
    ,a.attribute_value_column_name
    ,a.attribute_dimension_id
    ,dim.dimension_varchar_label as attr_dimension_varchar_label
    from fem_dim_attributes_b a
    ,fem_dim_attr_versions_b v
    ,fem_dimensions_b dim
    where a.dimension_id = p_dimension_id
    and a.personal_flag = 'N'
    and a.queryable_for_reporting_flag = 'Y'
    and a.allow_multiple_assignment_flag = 'N'
    and v.attribute_id = a.attribute_id
    and v.default_version_flag = 'Y'
    and dim.dimension_id (+) = a.attribute_dimension_id
    order by a.attribute_required_flag desc
    ,a.attribute_varchar_label
  ) loop

    -- If Attribute Definition points to a Dimension, then must denormalize
    -- the attribute value by querying the appropriate dimension member
    -- TL table to get the member Name.
    if (attr_rec.attribute_data_type_code = 'DIMENSION') then

      -----------------------------------------
      -- Get the Dimension metadata
      -----------------------------------------
      select member_b_table_name
      ,member_tl_table_name
      ,member_col
      ,member_display_code_col
      ,member_name_col
      ,decode(value_set_required_flag
        ,'Y',' and adb.value_set_id = attr.dim_attribute_value_set_id'
        ,null)
      ,decode(value_set_required_flag
        ,'Y',' and adtl.value_set_id = attr.dim_attribute_value_set_id'
        ,null)
      ,decode(member_tl_table_name
        ,member_vl_object_name,null
        ,' and adtl.language = tl.language')
      into l_attr_mem_b_tab
      ,l_attr_mem_tl_tab
      ,l_attr_mem_col
      ,l_attr_mem_display_code_col
      ,l_attr_mem_name_col
      ,l_attrd_value_set_where
      ,l_attrn_value_set_where
      ,l_attrn_language_where
      from fem_xdim_dimensions
      where dimension_id = attr_rec.attribute_dimension_id;

      l_attrd_sql_stmt :=
      ' select adb.'||l_attr_mem_display_code_col||
      ' from '||l_attr_mem_b_tab||' adb'||
      ' ,'||p_attribute_table_name||' attr'||
      ' where adb.'||l_attr_mem_col||' = attr.'||attr_rec.attribute_value_column_name||
      l_attrd_value_set_where||
      ' and attr.attribute_id = '||attr_rec.attribute_id||
      ' and attr.version_id = '||attr_rec.version_id||
      ' and attr.'||p_member_col||' = b.'||p_member_col||
      l_value_set_where;

      l_attrn_sql_stmt :=
      ' select adtl.'||l_attr_mem_name_col||
      ' from '||l_attr_mem_tl_tab||' adtl'||
      ' ,'||p_attribute_table_name||' attr'||
      ' where adtl.'||l_attr_mem_col||' = attr.'||attr_rec.attribute_value_column_name||
      l_attrn_value_set_where||
      l_attrn_language_where||
      ' and attr.attribute_id = '||attr_rec.attribute_id||
      ' and attr.version_id = '||attr_rec.version_id||
      ' and attr.'||p_member_col||' = b.'||p_member_col||
      l_value_set_where;

      -- If the attribute definition points to the Extended Account Type dimension,
      -- then we must also include the Extended Account Type's SIGN and
      -- BASIC_ACCOUNT_TYPE attribute values.
      if (attr_rec.attr_dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE') then

        select a.attribute_id
        ,v.version_id
        into l_sign_attribute_id
        ,l_sign_attr_version_id
        from fem_dim_attributes_b a
        ,fem_dim_attr_versions_b v
        where a.dimension_id = attr_rec.attribute_dimension_id
        and a.attribute_varchar_label = 'SIGN'
        and v.attribute_id = a.attribute_id
        and v.default_version_flag = 'Y';

        l_sign_attrd_sql_stmt :=
        ' select ext_attr.number_assign_value'||
        ' from '||p_attribute_table_name||' attr'||
        ' ,fem_ext_acct_types_attr ext_attr'||
        ' where attr.attribute_id = '||attr_rec.attribute_id||
        ' and attr.version_id = '||attr_rec.version_id||
        ' and attr.'||p_member_col||' = b.'||p_member_col||
        l_value_set_where||
        ' and ext_attr.attribute_id = '||l_sign_attribute_id||
        ' and ext_attr.version_id = '||l_sign_attr_version_id||
        ' and ext_attr.ext_account_type_code = attr.'||attr_rec.attribute_value_column_name;

        select a.attribute_id
        ,v.version_id
        into l_bsc_attribute_id
        ,l_bsc_attr_version_id
        from fem_dim_attributes_b a
        ,fem_dim_attr_versions_b v
        where a.dimension_id = attr_rec.attribute_dimension_id
        and a.attribute_varchar_label = 'BASIC_ACCOUNT_TYPE_CODE'
        and v.attribute_id = a.attribute_id
        and v.default_version_flag = 'Y';

        l_bsc_attrd_sql_stmt :=
        ' select ext_attr.dim_attribute_varchar_member'||
        ' from '||p_attribute_table_name||' attr'||
        ' ,fem_ext_acct_types_attr ext_attr'||
        ' where attr.attribute_id = '||attr_rec.attribute_id||
        ' and attr.version_id = '||attr_rec.version_id||
        ' and attr.'||p_member_col||' = b.'||p_member_col||
        l_value_set_where||
        ' and ext_attr.attribute_id = '||l_bsc_attribute_id||
        ' and ext_attr.version_id = '||l_bsc_attr_version_id||
        ' and ext_attr.ext_account_type_code = attr.'||attr_rec.attribute_value_column_name;

        l_bsc_attrn_sql_stmt :=
        ' select bsc_tl.basic_account_type_name'||
        ' from '||p_attribute_table_name||' attr'||
        ' ,fem_ext_acct_types_attr ext_attr'||
        ' ,fem_basic_acct_types_tl bsc_tl'||
        ' where attr.attribute_id = '||attr_rec.attribute_id||
        ' and attr.version_id = '||attr_rec.version_id||
        ' and attr.'||p_member_col||' = b.'||p_member_col||
        l_value_set_where||
        ' and ext_attr.attribute_id = '||l_bsc_attribute_id||
        ' and ext_attr.version_id = '||l_bsc_attr_version_id||
        ' and ext_attr.ext_account_type_code = attr.'||attr_rec.attribute_value_column_name||
        ' and bsc_tl.basic_account_type_code = ext_attr.dim_attribute_varchar_member'||
        ' and bsc_tl.language = tl.language';

      end if;

    else

      l_attrd_sql_stmt :=
      ' select attr.'||attr_rec.attribute_value_column_name||
      ' from '||p_attribute_table_name||' attr'||
      ' where attr.attribute_id = '||attr_rec.attribute_id||
      ' and attr.version_id = '||attr_rec.version_id||
      ' and attr.'||p_member_col||' = b.'||p_member_col||
      l_value_set_where;

      l_attrn_sql_stmt := null;

    end if;

    -- Use the attribute varchar label as the column name as the max length
    -- is 30 characters and the string is not translated.  Must replace any
    -- non-alphanumeric characters with a underscore (_).
    l_attr_col := upper(translate(attr_rec.attribute_varchar_label
      ,' ,.<>/?;:[]{}\|-=+`~!@#$%^&*()"'''
      ,'________________________________'
    ));

    if (G_LOG_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_STATEMENT
        ,p_module   => l_module_name||'.'||l_attr_col||'.attrn'
        ,p_msg_text => l_attrn_sql_stmt
      );

      FEM_ENGINES_PKG.Tech_Message (
        p_severity  => G_LOG_LEVEL_STATEMENT
        ,p_module   => l_module_name||'.'||l_attr_col||'.attrd'
        ,p_msg_text => l_attrd_sql_stmt
      );

    end if;

    x_attrd_attr_select := x_attrd_attr_select||
    ' ,('||l_attrd_sql_stmt||') '||l_attr_col;

    if (l_attrn_sql_stmt is not null) then

      x_attrn_attr_select := x_attrn_attr_select||
      ' ,('||l_attrn_sql_stmt||') '||l_attr_col;

      x_attrn_vl_attr_select := x_attrn_vl_attr_select||
      ' ,'||l_attr_col;

    end if;

    if (attr_rec.attr_dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE') then
    -- If the attribute definition points to the Extended Account Type dimension,
    -- then we must also include columns for the Extended Account Type dimesion's SIGN
    -- and BASIC_ACCOUNT_TYPE attributes.

    -- <<Begin BUG 9340274 changes:  Add support for user-defined attributes
    --   referencing the EXTENDED_ACCOUNT_TYPE dimension.

       if (attr_rec.attribute_varchar_label = 'EXTENDED_ACCOUNT_TYPE') then
       -- For the seeded EXTENDED_ACCOUNT_TYPE attribute, use the hard-coded column names
       -- EXTENDED_ACCOUNT_SIGN and BASIC_ACCOUNT_TYPE for that attribute's SIGN and
       -- BASIC_ACCOUNT_TYPE attributes.

          l_sign_attr_col_name  := 'EXTENDED_ACCOUNT_SIGN';
          l_basic_attr_col_name := 'BASIC_ACCOUNT_TYPE';

       else
       -- But for any user-defined attributes that reference the EXTENDED_ACCOUNT_TYPE
       -- dimension, we have to use the first 24 characters of the attribute varchar
       -- label concatenated with '_SIGN' or '_BASIC', to avoid having duplicate
       -- column names in the view definitions.

          l_sign_attr_col_name  := SUBSTR(attr_rec.attribute_varchar_label,1,24)||'_SIGN';
          l_basic_attr_col_name := SUBSTR(attr_rec.attribute_varchar_label,1,24)||'_BASIC';

       end if;

       x_attrd_attr_select := x_attrd_attr_select||
       ' ,('||l_sign_attrd_sql_stmt||') '||l_sign_attr_col_name||
       ' ,('||l_bsc_attrd_sql_stmt||') '||l_basic_attr_col_name;

       x_attrn_attr_select := x_attrn_attr_select||
       ' ,('||l_bsc_attrn_sql_stmt||') '||l_basic_attr_col_name;

       x_attrn_vl_attr_select := x_attrn_vl_attr_select||', '||l_basic_attr_col_name;

    -- End BUG 9340274 changes>>

    -- Set the SIGN and BASIC_ACCOUNT_TYPE attribute SQL to null
       l_sign_attrd_sql_stmt := null;
       l_bsc_attrd_sql_stmt := null;
       l_bsc_attrn_sql_stmt := null;

    end if;

  end loop;

  -----------------------------------------
  -- End Procedure Logging and Messaging --
  -----------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.end'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

EXCEPTION

  when others then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    x_attrd_attr_select := null;
    x_attrn_attr_select := null;
    x_attrn_vl_attr_select := null;

END Get_Dim_Attribute_Sql;


/*===========================================================================+
 | FOR INTERNAL USE ONLY.
 +===========================================================================*/

PROCEDURE Get_Seed_Dim_Attribute_Sql (
  p_dimension_id                  in number
  ,p_attribute_table_name         in varchar2
  ,p_member_col                   in varchar2
  ,p_value_set_required_flag      in varchar2
  ,p_seed_db_link                 in varchar2
  ,x_attrd_attr_select            out nocopy long
  ,x_attrn_attr_select            out nocopy long
  ,x_attrn_vl_attr_select         out nocopy long
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(100) := G_PACKAGE_NAME||'.Get_Seed_Dim_Attribute_Sql';

  -------------------
  -- Declare types --
  -------------------
  type attribute_record is record (
    attribute_varchar_label       fem_dim_attributes_b.attribute_varchar_label%type
    ,version_display_code         fem_dim_attr_versions_b.version_display_code%type
    ,attribute_data_type_code     fem_dim_attributes_b.attribute_data_type_code%type
    ,attribute_value_column_name  fem_dim_attributes_b.attribute_value_column_name%type
    ,attribute_dimension_id       fem_dim_attributes_b.attribute_dimension_id%type
    ,attr_dimension_varchar_label fem_dimensions_b.dimension_varchar_label%type
  );

  type attribute_table is table of attribute_record
  index by binary_integer;

  type dynamic_cursor is ref cursor;

  -----------------------
  -- Declare variables --
  -----------------------
  l_module_name                   varchar2(200);
  l_function_name                 varchar2(200);

  l_attr_csr                      dynamic_cursor;
  l_attr_csr_stmt                 varchar2(2000);

  l_attr_tbl                      attribute_table;

  l_value_set_where               varchar2(100);

  l_attr_mem_b_tab                varchar2(30);
  l_attr_mem_tl_tab               varchar2(30);
  l_attr_mem_col                  varchar2(30);
  l_attr_mem_display_code_col     varchar2(30);
  l_attr_mem_name_col             varchar2(30);
  l_attrd_value_set_where         varchar2(100);
  l_attrn_value_set_where         varchar2(100);
  l_attrn_language_where          varchar2(100);

  l_attrd_sql_stmt                varchar2(2000);
  l_attrn_sql_stmt                varchar2(2000);
  l_attr_col                      varchar2(30);

  l_sign_attrd_sql_stmt           varchar2(2000);

  l_bsc_attrd_sql_stmt            varchar2(2000);
  l_bsc_attrn_sql_stmt            varchar2(2000);

BEGIN

  l_module_name :=
    G_MODULE||'.'||lower(l_api_name)||'.'||lower(p_attribute_table_name);
  l_function_name :=
    G_PACKAGE_NAME||'.'||l_api_name ||'.'||p_attribute_table_name;

  -------------------------------------------
  -- Start Procedure Logging and Messaging --
  -------------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.begin'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_201
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  x_attrd_attr_select := null;
  x_attrn_attr_select := null;
  x_attrn_vl_attr_select := null;

  if (p_value_set_required_flag = 'Y') then
    l_value_set_where := ' and attr.value_set_id = b.value_set_id';
  end if;

  ------------------------------------------------------
  -- Loop through all Dimension Attribute Definitions --
  ------------------------------------------------------
  l_attr_csr_stmt :=
  ' select a.attribute_varchar_label'||
  ' ,v.version_display_code'||
  ' ,a.attribute_data_type_code'||
  ' ,a.attribute_value_column_name'||
  ' ,a.attribute_dimension_id'||
  ' ,dim.dimension_varchar_label as attr_dimension_varchar_label'||
  ' from fem_dim_attributes_b@'||p_seed_db_link||' a'||
  ' ,fem_dim_attr_versions_b@'||p_seed_db_link||' v'||
  ' ,fem_dimensions_b@'||p_seed_db_link||' dim'||
  ' where a.dimension_id = :b_dimension_id'||
  ' and a.personal_flag = ''N'''||
  ' and a.queryable_for_reporting_flag = ''Y'''||
  ' and a.allow_multiple_assignment_flag = ''N'''||
  ' and v.attribute_id = a.attribute_id'||
  ' and v.default_version_flag = ''Y'''||
  ' and dim.dimension_id (+) = a.attribute_dimension_id'||
  ' order by a.attribute_required_flag desc'||
  ' ,a.attribute_varchar_label';

  open l_attr_csr for l_attr_csr_stmt
  using p_dimension_id;

  fetch l_attr_csr bulk collect into l_attr_tbl;
  close l_attr_csr;

  if (l_attr_tbl.LAST is not null) then

    for i in 1..l_attr_tbl.LAST loop

      -- If Attribute Definition points to a Dimension, then must denormalize
      -- the attribute value by querying the appropriate dimension member
      -- TL table to get the member Name.
      if (l_attr_tbl(i).attribute_data_type_code = 'DIMENSION') then

        -----------------------------------------
        -- Get the Dimension metadata
        -----------------------------------------
        execute immediate
        ' select member_b_table_name'||
        ' ,member_tl_table_name'||
        ' ,member_col'||
        ' ,member_display_code_col'||
        ' ,member_name_col'||
        ' ,decode(value_set_required_flag'||
        '   ,''Y'','' and adb.value_set_id = attr.dim_attribute_value_set_id'''||
        '   ,null)'||
        ' ,decode(value_set_required_flag'||
        '   ,''Y'','' and adtl.value_set_id = attr.dim_attribute_value_set_id'''||
        '   ,null)'||
        ' ,decode(member_tl_table_name'||
        '   ,member_vl_object_name,null'||
        '   ,'' and adtl.language = tl.language'')'||
        ' from fem_xdim_dimensions@'||p_seed_db_link||
        ' where dimension_id = :b_attribute_dimension_id'
        into l_attr_mem_b_tab
        ,l_attr_mem_tl_tab
        ,l_attr_mem_col
        ,l_attr_mem_display_code_col
        ,l_attr_mem_name_col
        ,l_attrd_value_set_where
        ,l_attrn_value_set_where
        ,l_attrn_language_where
        using l_attr_tbl(i).attribute_dimension_id;

        l_attrd_sql_stmt :=
        ' select adb.'||l_attr_mem_display_code_col||
        ' from '||l_attr_mem_b_tab||' adb'||
        ' ,'||p_attribute_table_name||' attr'||
        ' ,fem_dim_attributes_b a'||
        ' ,fem_dim_attr_versions_b v'||
        ' where adb.'||l_attr_mem_col||' = attr.'||l_attr_tbl(i).attribute_value_column_name||
        l_attrd_value_set_where||
        ' and a.dimension_id = '||p_dimension_id||
        ' and a.attribute_varchar_label = '''||l_attr_tbl(i).attribute_varchar_label||''''||
        ' and v.attribute_id = a.attribute_id'||
        ' and v.version_display_code = '''||l_attr_tbl(i).version_display_code||''''||
        ' and attr.attribute_id = a.attribute_id'||
        ' and attr.version_id = v.version_id'||
        ' and attr.'||p_member_col||' = b.'||p_member_col||
        l_value_set_where;

        l_attrn_sql_stmt :=
        ' select adtl.'||l_attr_mem_name_col||
        ' from '||l_attr_mem_tl_tab||' adtl'||
        ' ,'||p_attribute_table_name||' attr'||
        ' ,fem_dim_attributes_b a'||
        ' ,fem_dim_attr_versions_b v'||
        ' where adtl.'||l_attr_mem_col||' = attr.'||l_attr_tbl(i).attribute_value_column_name||
        l_attrn_value_set_where||
        l_attrn_language_where||
        ' and a.dimension_id = '||p_dimension_id||
        ' and a.attribute_varchar_label = '''||l_attr_tbl(i).attribute_varchar_label||''''||
        ' and v.attribute_id = a.attribute_id'||
        ' and v.version_display_code = '''||l_attr_tbl(i).version_display_code||''''||
        ' and attr.attribute_id = a.attribute_id'||
        ' and attr.version_id = v.version_id'||
        ' and attr.'||p_member_col||' = b.'||p_member_col||
        l_value_set_where;

        -- If the attribute definition points to the Extended Account Type dimension,
        -- then we must also include the Extended Account Type's SIGN and
        -- BASIC_ACCOUNT_TYPE attribute values.
        if (l_attr_tbl(i).attr_dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE') then

          l_sign_attrd_sql_stmt :=
          ' select ext_attr.number_assign_value'||
          ' from '||p_attribute_table_name||' attr'||
          ' ,fem_dim_attributes_b a'||
          ' ,fem_dim_attr_versions_b v'||
          ' ,fem_ext_acct_types_attr ext_attr'||
          ' ,fem_dim_attributes_b ext_a'||
          ' ,fem_dim_attr_versions_b ext_v'||
          ' where a.dimension_id = '||p_dimension_id||
          ' and a.attribute_varchar_label = '''||l_attr_tbl(i).attribute_varchar_label||''''||
          ' and v.attribute_id = a.attribute_id'||
          ' and v.version_display_code = '''||l_attr_tbl(i).version_display_code||''''||
          ' and attr.attribute_id = a.attribute_id'||
          ' and attr.version_id = v.version_id'||
          ' and attr.'||p_member_col||' = b.'||p_member_col||
          l_value_set_where||
          ' and ext_a.dimension_id = '||l_attr_tbl(i).attribute_dimension_id||
          ' and ext_a.attribute_varchar_label = ''SIGN'''||
          ' and ext_v.attribute_id = ext_a.attribute_id'||
          ' and ext_v.version_display_code = ''Default'''||
          ' and ext_attr.attribute_id = ext_a.attribute_id'||
          ' and ext_attr.version_id = ext_v.version_id'||
          ' and ext_attr.ext_account_type_code = attr.'||l_attr_tbl(i).attribute_value_column_name;

          l_bsc_attrd_sql_stmt :=
          ' select ext_attr.dim_attribute_varchar_member'||
          ' from '||p_attribute_table_name||' attr'||
          ' ,fem_dim_attributes_b a'||
          ' ,fem_dim_attr_versions_b v'||
          ' ,fem_ext_acct_types_attr ext_attr'||
          ' ,fem_dim_attributes_b ext_a'||
          ' ,fem_dim_attr_versions_b ext_v'||
          ' where a.dimension_id = '||p_dimension_id||
          ' and a.attribute_varchar_label = '''||l_attr_tbl(i).attribute_varchar_label||''''||
          ' and v.attribute_id = a.attribute_id'||
          ' and v.version_display_code = '''||l_attr_tbl(i).version_display_code||''''||
          ' and attr.attribute_id = a.attribute_id'||
          ' and attr.version_id = v.version_id'||
          ' and attr.'||p_member_col||' = b.'||p_member_col||
          l_value_set_where||
          ' and ext_a.dimension_id = '||l_attr_tbl(i).attribute_dimension_id||
          ' and ext_a.attribute_varchar_label = ''BASIC_ACCOUNT_TYPE_CODE'''||
          ' and ext_v.attribute_id = ext_a.attribute_id'||
          ' and ext_v.version_display_code = ''Default'''||
          ' and ext_attr.attribute_id = ext_a.attribute_id'||
          ' and ext_attr.version_id = ext_v.version_id'||
          ' and ext_attr.ext_account_type_code = attr.'||l_attr_tbl(i).attribute_value_column_name;

          l_bsc_attrn_sql_stmt :=
          ' select bsc_tl.basic_account_type_name'||
          ' from '||p_attribute_table_name||' attr'||
          ' ,fem_dim_attributes_b a'||
          ' ,fem_dim_attr_versions_b v'||
          ' ,fem_ext_acct_types_attr ext_attr'||
          ' ,fem_dim_attributes_b ext_a'||
          ' ,fem_dim_attr_versions_b ext_v'||
          ' ,fem_basic_acct_types_tl bsc_tl'||
          ' where a.dimension_id = '||p_dimension_id||
          ' and a.attribute_varchar_label = '''||l_attr_tbl(i).attribute_varchar_label||''''||
          ' and v.attribute_id = a.attribute_id'||
          ' and v.version_display_code = '''||l_attr_tbl(i).version_display_code||''''||
          ' and attr.attribute_id = a.attribute_id'||
          ' and attr.version_id = v.version_id'||
          ' and attr.'||p_member_col||' = b.'||p_member_col||
          l_value_set_where||
          ' and ext_a.dimension_id = '||l_attr_tbl(i).attribute_dimension_id||
          ' and ext_a.attribute_varchar_label = ''BASIC_ACCOUNT_TYPE_CODE'''||
          ' and ext_v.attribute_id = ext_a.attribute_id'||
          ' and ext_v.version_display_code = ''Default'''||
          ' and ext_attr.attribute_id = ext_a.attribute_id'||
          ' and ext_attr.version_id = ext_v.version_id'||
          ' and ext_attr.ext_account_type_code = attr.'||l_attr_tbl(i).attribute_value_column_name||
          ' and bsc_tl.basic_account_type_code = ext_attr.dim_attribute_varchar_member'||
          ' and bsc_tl.language = tl.language';

        end if;

      else

        l_attrd_sql_stmt :=
        ' select attr.'||l_attr_tbl(i).attribute_value_column_name||
        ' from '||p_attribute_table_name||' attr'||
        ' ,fem_dim_attributes_b a'||
        ' ,fem_dim_attr_versions_b v'||
        ' where a.dimension_id = '||p_dimension_id||
        ' and a.attribute_varchar_label = '''||l_attr_tbl(i).attribute_varchar_label||''''||
        ' and v.attribute_id = a.attribute_id'||
        ' and v.version_display_code = '''||l_attr_tbl(i).version_display_code||''''||
        ' and attr.attribute_id = a.attribute_id'||
        ' and attr.version_id = v.version_id'||
        ' and attr.'||p_member_col||' = b.'||p_member_col||
        l_value_set_where;

        l_attrn_sql_stmt := null;

      end if;

      -- Use the attribute varchar label as the column name as the max length
      -- is 30 characters and the string is not translated.  Must replace any
      -- non-alphanumeric characters with a underscore (_).
      l_attr_col := upper(translate(l_attr_tbl(i).attribute_varchar_label
        ,' ,.<>/?;:[]{}\|-=+`~!@#$%^&*()"'''
        ,'________________________________'
      ));

      if (G_LOG_LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_STATEMENT
          ,p_module   => l_module_name||'.'||l_attr_col||'.attrd'
          ,p_msg_text => l_attrd_sql_stmt
        );

        FEM_ENGINES_PKG.Tech_Message (
          p_severity  => G_LOG_LEVEL_STATEMENT
          ,p_module   => l_module_name||'.'||l_attr_col||'.attrn'
          ,p_msg_text => l_attrn_sql_stmt
        );

      end if;

      x_attrd_attr_select := x_attrd_attr_select||
      ' ,('||l_attrd_sql_stmt||') '||l_attr_col;

      if (l_attrn_sql_stmt is not null) then

        x_attrn_attr_select := x_attrn_attr_select||
        ' ,('||l_attrn_sql_stmt||') '||l_attr_col;

        x_attrn_vl_attr_select := x_attrn_vl_attr_select||
        ' ,'||l_attr_col;

      end if;

      -- If the attribute definition points to the Extended Account Type dimension,
      -- then we must also include the Extended Account Type's SIGN and
      -- BASIC_ACCOUNT_TYPE attribute values.
      if (l_attr_tbl(i).attr_dimension_varchar_label = 'EXTENDED_ACCOUNT_TYPE') then

        x_attrd_attr_select := x_attrd_attr_select||
        ' ,('||l_sign_attrd_sql_stmt||') EXTENDED_ACCOUNT_SIGN'||
        ' ,('||l_bsc_attrd_sql_stmt||') BASIC_ACCOUNT_TYPE';

        x_attrn_attr_select := x_attrn_attr_select||
        ' ,('||l_bsc_attrn_sql_stmt||') BASIC_ACCOUNT_TYPE';

        x_attrn_vl_attr_select := x_attrn_vl_attr_select||
        ' ,BASIC_ACCOUNT_TYPE';

        -- Set the SIGN and BASIC_ACCOUNT_TYPE attribute SQL to null
        l_sign_attrd_sql_stmt := null;
        l_bsc_attrd_sql_stmt := null;
        l_bsc_attrn_sql_stmt := null;

      end if;

    end loop;

  end if;

  -----------------------------------------
  -- End Procedure Logging and Messaging --
  -----------------------------------------
  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => l_module_name || '.end'
    ,p_app_name => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

  FEM_ENGINES_PKG.User_Message (
    p_app_name  => G_FEM
    ,p_msg_name => G_GL_POST_202
    ,p_token1   => 'FUNC_NAME'
    ,p_value1   => l_function_name
    ,p_token2   => 'TIME'
    ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
  );

EXCEPTION

  when others then

    rollback;

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_215
      ,p_token1   => 'ERR_MSG'
      ,p_value1   => SQLERRM
    );

    FEM_ENGINES_PKG.Tech_Message (
      p_severity  => G_LOG_LEVEL_EXCEPTION
      ,p_module   => l_module_name||'.others'
      ,p_app_name => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_GL_POST_203
      ,p_token1   => 'FUNC_NAME'
      ,p_value1   => l_function_name
      ,p_token2   => 'TIME'
      ,p_value2   => to_char(sysdate)||' '||to_char(sysdate,'HH24:MI:SS')
    );

    x_attrd_attr_select := null;
    x_attrn_attr_select := null;
    x_attrn_vl_attr_select := null;

END Get_Seed_Dim_Attribute_Sql;


END FEM_BI_DIMENSION_UTILS_PKG;

/
