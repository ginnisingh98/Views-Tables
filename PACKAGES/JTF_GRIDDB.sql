--------------------------------------------------------
--  DDL for Package JTF_GRIDDB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_GRIDDB" AUTHID CURRENT_USER as
/* $Header: JTFGRDDS.pls 120.1.12010000.2 2008/11/04 19:26:15 dbowles ship $ */
  -------
  -- Version 11.5.3 - 1.92 09-AUG-2000
  -------
  type dataSetType is table of jtf_dbstring_utils.maxString%TYPE
   index by binary_integer;

  dataSet dataSetType;

  type colDefRecType is record
  (
     gridName                  varchar2(256)
    ,grid_datasource_name      varchar2(30)  -- datasource
    ,grid_col_alias            varchar2(30)        -- col_name
    ,db_col_name               varchar2(255)
    ,data_type_code            varchar2(30)       -- data_type
    ,query_seq                 number(3)
    ,sortable_flag             varchar2(1)
    ,sort_asc_by_default_flag  varchar2(1)  -- sortAscending
    ,visible_flag              varchar2(1)
    ,freeze_visible_flag       varchar2(1)  --is_vis_flag_customizable
    ,display_index             integer  -- not display_seq
    ,display_type_code         varchar2(30)
    ,display_format_type_code  varchar2(30)
    ,display_hsize             number(6)  -- display_width
    ,header_alignment_code     varchar2(30)
    ,cell_alignment_code       varchar2(30)
    ,display_format_mask       varchar2(255)
    ,checkbox_checked_value    varchar2(255)
    ,checkbox_unchecked_value  varchar2(255)
    ,checkbox_other_values     varchar2(1)
    ,db_currency_code_col      varchar2(30)
    ,db_currency_col_alias     varchar2(30)
    ,label_text                varchar2(80)
    ,db_sort_column            varchar2(255)
    ,fire_post_query_flag      varchar2(1)
    ,image_description_col     varchar2(255)
    ,SQL_colAlias              varchar2(30) -- keeps track of the SQL column
                                            -- alias for this columnAlias.
  );

  type colDefTabType is table of colDefRecType
    index by binary_integer;

  type tabDefRecType is record
  (
     gridName              varchar2(256)
    ,title_text            varchar2(80)
    ,colCount              pls_integer
    ,rowCount              pls_integer
    ,moreRowsExists        varchar2(1)
    ,SQLStatement          jtf_dbstring_utils.maxString%TYPE
    ,SQLCursor             integer
    ,grid_datasource_name  varchar2(30)  -- datasource
    ,db_view_name          varchar2(30)  --tab_name
    ,default_row_height    number(2) -- lines / row
    ,max_queried_rows      number(5)
    ,where_clause          varchar2(32767)
    ,grid_sort_col_alias1  varchar2(30)  -- sort_column
    ,grid_sort_col_alias2  varchar2(30)  -- sort_column
    ,grid_sort_col_alias3  varchar2(30)  -- sort_column
    ,alt_color_code        varchar2(30)
    ,alt_color_interval    number(1)
    ,custom_grid_id        number
    ,custom_grid_name      varchar2(80)
    ,public_flag           varchar2(1)
    ,owner                 number(15)
    ,hasWhereClauseChanged varchar2(1)
    ,hasBindVarsChanged    varchar2(1)
    ,refreshFlag           varchar2(1)
    ,fetchSize             pls_integer
  );

  type tabDefTabType is table of tabDefRecType
    index by binary_integer;

  function  getFetchSize return number;
  procedure setFetchSize(rows in number);

  function  isMoreRowsAvailable(gridName in varchar2
                               ,p_serverInitDate in date) return varchar2;


  function  fetchDataSet(gridName in varchar2
                        ,p_serverInitDate in date) return dataSet%TYPE;
  procedure init(gridName       in varchar2
                ,dataSource     in varchar2
                ,customGridId   in out nocopy number
                ,customGridName in out nocopy varchar2
                ,outPutStream   out nocopy jtf_dbstream_utils.streamType
                ,x_serverInitDate out nocopy date );

  procedure reset(gridName in varchar2, p_serverInitDate in date);
  procedure refresh(gridName in varchar2, p_serverInitDate in date);

  procedure setSortCol(gridName       in varchar2
                      ,col_alias1     in varchar2
                      ,sort_asc_flag1 in varchar2
                      ,col_alias2     in varchar2
                      ,sort_asc_flag2 in varchar2
                      ,col_alias3     in varchar2
                      ,sort_asc_flag3 in varchar2
                      ,p_serverInitDate in date);

  function  getWhereClause(gridName in varchar2
                          ,p_serverInitDate in date) return varchar2;
  procedure setWhereClause(gridName in varchar2, whereClause in varchar2
                           ,p_serverInitDate in date);
  function  findColumnIndex(gridName in varchar2,grid_col_alias in varchar2
                            ,p_serverInitDate in date) return integer;
  function  findColumnAlias(gridName in varchar2,columnIndex in integer
                           ,p_serverInitDate in date) return varchar2;
  function  getSQLStatement(gridName in varchar2
                           ,p_serverInitDate in date) return varchar2;

  procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in varchar2, p_serverInitDate in date);
  procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in date, p_serverInitDate in date);
  procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in number, p_serverInitDate in date);
  procedure removeAllBindVariables(gridName in varchar2
                                  , p_serverInitDate in date);

  function getCharBindVariableValue(gridName in varchar2,
                                    variableName in varchar2
                                   ,p_serverInitDate in date) return varchar2;
  function getDateBindVariableValue(gridName in varchar2
                                   , variableName in varchar2
                                   ,p_serverInitDate in date) return date;
  function getNumberBindVariableValue(gridName in varchar2,
                                      variableName in varchar2
                                      ,p_serverInitDate in date) return number;

  function  getCharProperty(gridName in varchar2, propertyType in varchar2 ,p_serverInitDate in date) return varchar2;
  procedure setCharProperty(gridName in varchar2, propertyType in varchar2, propertyValue in varchar2 ,p_serverInitDate in date);

  function  getColumnDefs(gridName in varchar2 ,p_serverInitDate in date) return colDefTabType;
  function  findTableDefIndex(gridName in varchar2 ,p_serverInitDate in date) return binary_integer;

  procedure saveSerializedTableDef(gridName     in varchar2
                                 ,dataSource   in varchar2
                                 ,customGridId in out nocopy number
                                 ,customGridName in out nocopy varchar2
                                 ,defaultFlag in boolean
                                 ,publicFlag  in boolean
                                 ,inputStream jtf_dbstream_utils.streamType
                                 ,successFlag out nocopy boolean
                                 ,p_serverInitDate in date);

  function deleteCustomizations(gridName    in varchar2
                               ,customGridId in number
                               ,p_serverInitDate in date) return boolean;

  function getVersion return VARCHAR2;
  procedure debug(p_debug_tbl IN JTF_DEBUG_PUB.debug_tbl_type
                                 := JTF_DEBUG_PUB.G_MISS_DEBUG_TBL,
                  p_gridname              IN   varchar2 := NULL,
                  x_path                  OUT NOCOPY varchar2,
                  x_filename              OUT NOCOPY  varchar2,
 		  X_Return_Status         OUT NOCOPY  VARCHAR2,
  		  X_Msg_Count             OUT NOCOPY  NUMBER,
  		  X_Msg_Data              OUT NOCOPY  VARCHAR2);

--  function getFormatMask(currency_code varchar2) return varchar2 deterministic;

  function  getGridFetchSize(gridName in varchar2, p_serverInitDate in date) return number;
  procedure setGridFetchSize(gridName in varchar2, rows in number, p_serverInitDate in date);


  procedure getSortCol(gridName       in varchar2
                      ,p_serverInitDate in date
                      ,sort_col1      out nocopy varchar2
                      ,sort_asc_flag1 out nocopy varchar2
                      ,sort_col2      out nocopy varchar2
                      ,sort_asc_flag2 out nocopy varchar2
                      ,sort_col3      out nocopy varchar2
                      ,sort_asc_flag3 out nocopy varchar2
                     );

  procedure getTableDefInfo(gridName       in varchar2
                      ,p_serverInitDate in date
                      ,x_sort_col1      out nocopy varchar2
                      ,x_sort_col2      out nocopy varchar2
                      ,x_sort_col3 out nocopy varchar2
                      ,x_fetchSize      out nocopy number
                     );
/** this function is invoked only from populate and refresh methods.
    this function catches any "invalid package" exception and tries to recompile  them before throwing an error.
*/

function fetchFirstSet(gridName in varchar2
                      ,p_serverInitDate in date) return dataSet%TYPE;
END jtf_gridDB;

/
