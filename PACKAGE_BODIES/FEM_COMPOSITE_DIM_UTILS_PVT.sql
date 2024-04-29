--------------------------------------------------------
--  DDL for Package Body FEM_COMPOSITE_DIM_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_COMPOSITE_DIM_UTILS_PVT" AS
/* $Header: FEMVCDUB.pls 120.3 2006/09/21 08:26:53 nmartine noship $ */


-------------------------------
-- Declare package constants --
-------------------------------

  -- Log Level Constants
  G_LOG_LEVEL_1                constant number := FND_LOG.Level_Statement;
  G_LOG_LEVEL_2                constant number := FND_LOG.Level_Procedure;
  G_LOG_LEVEL_3                constant number := FND_LOG.Level_Event;
  G_LOG_LEVEL_4                constant number := FND_LOG.Level_Exception;
  G_LOG_LEVEL_5                constant number := FND_LOG.Level_Error;
  G_LOG_LEVEL_6                constant number := FND_LOG.Level_Unexpected;

  -- Seeded Financial Element IDs
  G_FIN_ELEM_ID_STATISTIC      constant number := 10000;
  G_FIN_ELEM_ID_ACTIVITY_RATE  constant number := 5005;

------------------------------
-- Declare package messages --
------------------------------
  G_CDU_BAD_COMP_DIM_WC_ERR    constant varchar2(30) := 'FEM_CDU_BAD_COMP_DIM_WC_ERR';

--------------------------------------
-- Declare package type definitions --
--------------------------------------
  t_return_status                 varchar2(1);
  t_msg_count                     number;
  t_msg_data                      varchar2(2000);

------------------------------
-- Declare package variables --
-------------------------------


--------------------------------
-- Declare package exceptions --
--------------------------------


-----------------------------------------------
-- Declare private procedures and functions --
-----------------------------------------------
FUNCTION Get_Comp_Dim_Where_Clause (
  p_comp_dim_req_column           in varchar2
  ,p_source_table_alias           in varchar2
  ,p_target_table_name            in varchar2
  ,p_target_table_alias           in varchar2
)
RETURN long;


--------------------------------------------------------------------------------
--  Package bodies for functions/procedures
--------------------------------------------------------------------------------

/*============================================================================+
 | PROCEDURE
 |   Populate_Cost_Object_Id
 |
 | DESCRIPTION
 |   Populates the COST_OBJECT_ID column value on the specified target table.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |
 |   IN
 |     p_api_version
 |         Current version of this API.
 |     p_init_msg_list
 |         Flag indicating if FND_MSG_PUB should be initialized or not.
 |     p_commit
 |         Flag indicating if this API should commit after completion.
 |     p_object_type_code
 |         The Object Type Code of the calling program.
 |     p_source_table_query
 |         A SQL query string to be used for querying all the Cost Objects
 |         that require population of COST_OBJECT_ID.  The FROM clause must
 |         reference a source table that contains all the component dimension
 |         ID columns of the Cost Object dimension.  An alias for that source
 |         table must be specified and must match the value specified for the
 |         p_source_table_alias parameter.
 |     p_source_table_query_param1
 |         The source table query where clause bind parameter 1 (optional)
 |     p_source_table_query_param2
 |         The source table query where clause bind parameter 2 (optional)
 |     p_source_table_alias
 |         The source table alias.  Alias must match the alias used in
 |         p_source_table_query.
 |     p_target_table_name
 |         The target table name.
 |     p_target_table_alias
 |         The target table alias.
 |     p_target_dsg_where_clause
 |         The Dataset Group where-clause string to be used on the target table.
 |         NOTE:  If an alias was specified in the Dataset Group where-clause,
 |         it must match the value specified for the p_target_table_alias
 |         parameter.
 |
 |   OUT
 |     x_return_status
 |         Possible return status.
 |     x_msg_count
 |         Count of messages returned.  If x_msg_count = 1, then the message
 |         is returned in x_msg_data.  If x_msg_count > 1, then messages are
 |         returned via FND_MSG_PUB.
 |     x_msg_data
 |          Error message returned.
 |
 |
 | MODIFICATION HISTORY
 |   nmartine   31-JAN-2005  Created
 |
 +============================================================================*/

PROCEDURE Populate_Cost_Object_Id (
  p_api_version                   in number
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy  varchar2
  ,x_msg_count                    out nocopy  number
  ,x_msg_data                     out nocopy  varchar2
  ,p_object_type_code             in varchar2
  ,p_source_table_query           in long
  ,p_source_table_query_param1    in number   default null
  ,p_source_table_query_param2    in number   default null
  ,p_source_table_alias           in varchar2
  ,p_target_table_name            in varchar2
  ,p_target_table_alias           in varchar2
  ,p_target_dsg_where_clause      in long
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(30) := 'Populate_Cost_Object_Id';
  l_api_version          constant number       := 1.0;

  -----------------------
  -- Declare variables --
  -----------------------
  l_comp_dim_update_stmt          long;
  l_comp_dim_where_clause         long;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

BEGIN

  -- Standard Start of API Savepoint
  savepoint Populate_Cost_Object_Id_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------------
  -- STEP 1: Get Cost Object Dimension Where Clause
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Get Cost Object Dimension Where Clause'
  );

  l_comp_dim_where_clause :=
    Get_Comp_Dim_Where_Clause (
      p_comp_dim_req_column => 'cost_obj'
      ,p_source_table_alias => p_source_table_alias
      ,p_target_table_name  => p_target_table_name
      ,p_target_table_alias => p_target_table_alias
    );

  if (l_comp_dim_where_clause is null) then
    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_CDU_BAD_COMP_DIM_WC_ERR
      ,p_token1   => 'COLUMN_NAME'
      ,p_value1   => 'COST_OBJECT_ID'
      ,p_token2   => 'TABLE_NAME'
      ,p_value2   => p_target_table_name
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Build Cost Object Dynamic Update Statement
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Build Cost Object Update Statement'
  );

  l_comp_dim_update_stmt :=
  ' update '||p_target_table_name||' '||p_target_table_alias||
  ' set cost_object_id = ('||
      p_source_table_query||
      l_comp_dim_where_clause||
  ' )'||
  ' where currency_type_code = ''ENTERED'''||
  ' and cost_object_id is null'||
  ' and '||p_target_dsg_where_clause||
  ' and exists ('||
      p_source_table_query||
      l_comp_dim_where_clause||
  ' )';

  ------------------------------------------------------------------------------
  -- STEP 3: Execute Dynamic Update Statement
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3: Execute Dynamic Update Statement'
  );

  -- Execute dynamic Update SQL statement
  if (p_source_table_query_param1 is not null) then

    if (p_source_table_query_param2 is not null) then
      execute immediate l_comp_dim_update_stmt
      using p_source_table_query_param1
      ,p_source_table_query_param2
      ,p_source_table_query_param1
      ,p_source_table_query_param2;
    else
      execute immediate l_comp_dim_update_stmt
      using p_source_table_query_param1
      ,p_source_table_query_param1;
    end if;

  else

    if (p_source_table_query_param2 is not null) then
      execute immediate l_comp_dim_update_stmt
      using p_source_table_query_param2
      ,p_source_table_query_param2;
    else
      execute immediate l_comp_dim_update_stmt;
    end if;

  end if;

  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then

    rollback to Populate_Cost_Object_Id_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count
      ,p_data => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then

    rollback to Populate_Cost_Object_Id_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count
      ,p_data => x_msg_data
    );

  when others then

    rollback to Populate_Cost_Object_Id_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
      FND_MSG_PUB.Add_Exc_Msg (
        p_pkg_name        => G_PKG_NAME
        ,p_procedure_name => l_api_name
      );
    end if;
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count
      ,p_data => x_msg_data
    );

END Populate_Cost_Object_Id;



/*============================================================================+
 | PROCEDURE
 |   Populate_Activity_Id
 |
 | DESCRIPTION
 |   Populates the ACTIVITY_ID column value on the specified target table.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |
 |   IN
 |     p_api_version
 |         Current version of this API.
 |     p_init_msg_list
 |         Flag indicating if FND_MSG_PUB should be initialized or not.
 |     p_commit
 |         Flag indicating if this API should commit after completion.
 |     p_object_type_code
 |         The Object Type Code of the calling program.
 |     p_source_table_query
 |         A SQL query string to be used for querying all the Activities
 |         that require population of ACTIVITY_ID.  The FROM clause must
 |         reference a source table that contains all the component dimension
 |         ID columns of the Activity dimension.  An alias for that source
 |         table must be specified and must match the value specified for the
 |         p_source_table_alias parameter.
 |     p_source_table_query_param1
 |         The source table query where clause bind parameter 1 (optional)
 |     p_source_table_query_param2
 |         The source table query where clause bind parameter 2 (optional)
 |     p_source_table_alias
 |         The source table alias.  Alias must match the alias used in
 |         p_source_table_query.
 |     p_target_table_name
 |         The target table name.
 |     p_target_table_alias
 |         The target table alias.
 |     p_target_dsg_where_clause
 |         The Dataset Group where-clause string to be used on the target table.
 |         NOTE:  If an alias was specified in the Dataset Group where-clause,
 |         it must match the value specified for the p_target_table_alias
 |         parameter.
 |     p_ledger_id
 |         Ledger Id.
 |     p_statistic_basis_id
 |         Statistic Basis Id.  Optional, as it is only applicable for
 |         Activity Statistic Rollup.
 |
 |   OUT
 |     x_return_status
 |         Possible return status.
 |     x_msg_count
 |         Count of messages returned.  If x_msg_count = 1, then the message
 |         is returned in x_msg_data.  If x_msg_count > 1, then messages are
 |         returned via FND_MSG_PUB.
 |     x_msg_data
 |          Error message returned.
 |
 |
 | MODIFICATION HISTORY
 |   nmartine   31-JAN-2005  Created
 |
 +============================================================================*/

PROCEDURE Populate_Activity_Id (
  p_api_version                   in number
  ,p_init_msg_list                in varchar2 := FND_API.G_FALSE
  ,p_commit                       in varchar2 := FND_API.G_FALSE
  ,x_return_status                out nocopy  varchar2
  ,x_msg_count                    out nocopy  number
  ,x_msg_data                     out nocopy  varchar2
  ,p_object_type_code             in varchar2
  ,p_source_table_query           in long
  ,p_source_table_query_param1    in number   default null
  ,p_source_table_query_param2    in number   default null
  ,p_source_table_alias           in varchar2
  ,p_target_table_name            in varchar2
  ,p_target_table_alias           in varchar2
  ,p_target_dsg_where_clause      in long
  ,p_ledger_id                    in number
  ,p_statistic_basis_id           in number   default null
)
IS

  -----------------------
  -- Declare constants --
  -----------------------
  l_api_name             constant varchar2(30) := 'Populate_Activity_Id';
  l_api_version          constant number       := 1.0;

  -----------------------
  -- Declare variables --
  -----------------------
  l_financial_elem_id_clause      varchar2(255);
  l_line_item_id_clause           varchar2(255);

  l_comp_dim_update_stmt          long;
  l_comp_dim_where_clause         long;

  l_return_status                 t_return_status%TYPE;
  l_msg_count                     t_msg_count%TYPE;
  l_msg_data                      t_msg_data%TYPE;

  ----------------------------
  -- Declare static cursors --
  ----------------------------


BEGIN

  -- Standard Start of API Savepoint
  savepoint Populate_Activity_Id_PVT;

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (
    p_current_version_number => l_api_version
    ,p_caller_version_number => p_api_version
    ,p_api_name              => l_api_name
    ,p_pkg_name              => G_PKG_NAME
  ) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize Message Stack on FND_MSG_PUB
  if (FND_API.To_Boolean(p_init_msg_list)) then
    FND_MSG_PUB.Initialize;
  end if;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  ------------------------------------------------
  -- Initialize Package and Procedure Variables --
  ------------------------------------------------
  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  ------------------------------------------------------------------------------
  -- STEP 1: Get Activity Dimension Where Clause
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 1: Get Activity Dimension Where Clause'
  );

  l_comp_dim_where_clause :=
    Get_Comp_Dim_Where_Clause (
      p_comp_dim_req_column => 'activity'
      ,p_source_table_alias => p_source_table_alias
      ,p_target_table_name  => p_target_table_name
      ,p_target_table_alias => p_target_table_alias
    );

  if (l_comp_dim_where_clause is null) then
    FEM_ENGINES_PKG.User_Message (
      p_app_name  => G_FEM
      ,p_msg_name => G_CDU_BAD_COMP_DIM_WC_ERR
      ,p_token1   => 'COLUMN_NAME'
      ,p_value1   => 'ACTIVITY_ID'
      ,p_token2   => 'TABLE_NAME'
      ,p_value2   => p_target_table_name
    );
  end if;

  ------------------------------------------------------------------------------
  -- STEP 2: Build Activity Dynamic Update Statement
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 2: Build Activity Update Statement'
  );

  if (p_object_type_code = 'ACT_COST_ROLLUP') then
    l_financial_elem_id_clause := 'financial_elem_id not in ('||
      G_FIN_ELEM_ID_STATISTIC||','||G_FIN_ELEM_ID_ACTIVITY_RATE||')';
  elsif (p_object_type_code = 'ACT_STAT_ROLLUP') then
    l_financial_elem_id_clause := 'financial_elem_id = '||
      G_FIN_ELEM_ID_STATISTIC;
    if (p_statistic_basis_id is not null) then
      l_line_item_id_clause := 'line_item_id = '||p_statistic_basis_id;
    end if;
  elsif (p_object_type_code = 'ACTIVITY_RATE') then
    l_financial_elem_id_clause := 'financial_elem_id not in ('||
      G_FIN_ELEM_ID_STATISTIC||','||G_FIN_ELEM_ID_ACTIVITY_RATE||')';
  end if;

  if (l_line_item_id_clause is null) then
    l_line_item_id_clause := '1=1';
  end if;

  l_comp_dim_update_stmt :=
  ' update '||p_target_table_name||' '||p_target_table_alias||
  ' set activity_id = ('||
      p_source_table_query||
      l_comp_dim_where_clause||
  ' )'||
  ' where ledger_id = :b_ledger_id'||
  ' and currency_type_code = ''ENTERED'''||
  ' and activity_id is null'||
  ' and '||l_financial_elem_id_clause||
  ' and '||l_line_item_id_clause||
  ' and '||p_target_dsg_where_clause||
  ' and exists ('||
      p_source_table_query||
      l_comp_dim_where_clause||
  ' )';

  ------------------------------------------------------------------------------
  -- STEP 3: Execute Dynamic Update Statement
  ------------------------------------------------------------------------------
  FEM_ENGINES_PKG.tech_message (
    p_severity  => G_LOG_LEVEL_1
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'Step 3: Execute Dynamic Update Statement'
  );

  -- Execute dynamic Update SQL statement
  if (p_source_table_query_param1 is not null) then

    if (p_source_table_query_param2 is not null) then
      execute immediate l_comp_dim_update_stmt
      using p_source_table_query_param1
      ,p_source_table_query_param2
      ,p_ledger_id
      ,p_source_table_query_param1
      ,p_source_table_query_param2;
    else
      execute immediate l_comp_dim_update_stmt
      using p_source_table_query_param1
      ,p_ledger_id
      ,p_source_table_query_param1;
    end if;

  else

    if (p_source_table_query_param2 is not null) then
      execute immediate l_comp_dim_update_stmt
      using p_source_table_query_param2
      ,p_ledger_id
      ,p_source_table_query_param2;
    else
      execute immediate l_comp_dim_update_stmt
      using p_ledger_id;
    end if;

  end if;

  -- Standard check of p_commit
  if FND_API.To_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get (
    p_count => x_msg_count
    ,p_data => x_msg_data
  );

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_2
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then

    rollback to Populate_Activity_Id_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count
      ,p_data => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then

    rollback to Populate_Activity_Id_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count
      ,p_data => x_msg_data
    );

  when others then

    rollback to Populate_Activity_Id_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
      FND_MSG_PUB.Add_Exc_Msg (
        p_pkg_name        => G_PKG_NAME
        ,p_procedure_name => l_api_name
      );
    end if;
    FND_MSG_PUB.Count_And_Get (
      p_count => x_msg_count
      ,p_data => x_msg_data
    );

END Populate_Activity_Id;



/*============================================================================+
 | FUNCTION
 |   Get_Comp_Dim_Where_Clause
 |
 | DESCRIPTION
 |   todo
 |
 | SCOPE - PRIVATE
 |
 +============================================================================*/

FUNCTION Get_Comp_Dim_Where_Clause (
  p_comp_dim_req_column           in varchar2
  ,p_source_table_alias           in varchar2
  ,p_target_table_name            in varchar2
  ,p_target_table_alias           in varchar2
)
RETURN long
IS

  l_comp_dim_sub_clause           long;
  l_comp_dim_where_clause         long;

  l_comp_dim_stmt                 long;
  l_comp_dim_cur                  dynamic_cursor;


BEGIN

  l_comp_dim_where_clause := null;

  l_comp_dim_stmt :=
  ' select '' and '||p_source_table_alias||'.''||reqs.column_name||'' = '||
    p_target_table_alias||'.''||reqs.column_name'||
  ' from fem_column_requiremnt_b reqs'||
  ' ,fem_tab_columns_v cols'||
  ' where reqs.'||p_comp_dim_req_column||'_dim_requirement_code is not null'||
  ' and reqs.'||p_comp_dim_req_column||'_dim_component_flag = ''Y'''||
  ' and reqs.dimension_id is not null'||
  ' and cols.table_name = :b_target_table_name'||
  ' and cols.column_name = reqs.column_name';

  open l_comp_dim_cur
  for l_comp_dim_stmt
  using p_target_table_name;

  loop

    fetch l_comp_dim_cur into l_comp_dim_sub_clause;
    exit when l_comp_dim_cur%NOTFOUND;

    l_comp_dim_where_clause := l_comp_dim_where_clause||l_comp_dim_sub_clause;

  end loop;

  close l_comp_dim_cur;

  return l_comp_dim_where_clause;

END Get_Comp_Dim_Where_Clause;




END FEM_COMPOSITE_DIM_UTILS_PVT;

/
