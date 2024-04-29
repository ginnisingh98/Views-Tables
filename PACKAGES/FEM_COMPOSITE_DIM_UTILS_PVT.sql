--------------------------------------------------------
--  DDL for Package FEM_COMPOSITE_DIM_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_COMPOSITE_DIM_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVCDUS.pls 120.1 2006/07/28 08:37:04 nmartine noship $ */

---------------------------------------------
--  Package Constants
---------------------------------------------
  G_PKG_NAME             constant varchar2(30) := 'FEM_COMPOSITE_DIM_UTILS_PVT';
  G_FEM                  constant varchar2(3)  := 'FEM';
  G_BLOCK                constant varchar2(80) := G_FEM||'.PLSQL.'||G_PKG_NAME;

---------------------------------------------
--  Package Types
---------------------------------------------
  type dynamic_cursor is ref cursor;


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
);


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
);



END FEM_COMPOSITE_DIM_UTILS_PVT;

 

/
