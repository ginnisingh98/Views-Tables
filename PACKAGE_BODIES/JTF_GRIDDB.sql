--------------------------------------------------------
--  DDL for Package Body JTF_GRIDDB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_GRIDDB" as
/* $Header: JTFGRDDB.pls 120.2 2006/01/19 03:14:44 snellepa ship $ */
-----------------------
-- Version 11.5.3 - 2.03 09-Aug-2000
-----------------------
  fetchSize          number := 50;
  -- Outgoing persistance versions
  tabVersion         varchar2(5) := '1';
  recVersion         varchar2(5) := '1';
  colDefVersion      varchar2(5) := '1';
  serverInitDate     date        := sysdate;

  -- Incoming persistance versions
  clientTabVersion       varchar2(5) := '1';
  clientColDefVersion    varchar2(5) := '1';

  lineFeed           varchar2(10) := jtf_dbstring_utils.getLineFeed;
  nullValue          varchar2(10) := jtf_dbstring_utils.getNullString;

  tableDefs  tabDefTabType;
  columnDefs colDefTabType;
  temp_columnDefs colDefTabType;

  INVALID_DATASOURCE exception;
  INVALID_GRID       exception;
  INVALID_PROPERTY   exception;

  type bindVarRecType is record
  (
    gridName            varchar2(256)
   ,variableName        varchar2(60)
   ,variableDataType    varchar2(30)  -- C, D, N  (Character, Date or Number)
   ,variableCharValue   varchar2(2000)
   ,variableDateValue   date
   ,variableNumberValue number
  );

  type bindVarTabType is table of bindVarRecType
    index by binary_integer;

  bindVariables bindVarTabType;

  USER_UI_DEFAULT_FOLDER constant varchar2(80) := 'USER_DEFAULT';

-----------------------------------------------------------------------------
-- VARIABLES FOR ERROR_TYPES, make sure handleErrors() can handle any additions.
-----------------------------------------------------------------------------
  INTERNAL_ERROR            constant pls_integer := 1;
  APPLICATION_ERROR         constant pls_integer := 2;
  INVALID_PROPERTY_ERROR    constant pls_integer := 3;
  INVALID_GRID_ERROR        constant pls_integer := 4;
  INIT_ERROR                constant pls_integer := 5;
  MAXLENGTH_EXCEEDED_ERROR  constant pls_integer := 6;
  INVALID_DATASOURCE_ERROR  constant pls_integer := 7;
  MISSING_SORT_COL_ERROR    constant pls_integer := 8;
  INVALID_COLUMNALIAS_ERROR constant pls_integer := 9;
  ILLEGAL_SORT_COLUMN_ERROR constant pls_integer := 10;

-- separator for image name and image description
IMAGE_SEPARATOR varchar2(1) := '*';

procedure raise_error is
begin
  app_exception.raise_exception;
end raise_error;

-----------------------------------------------------------------------------
-- Description:
-----------------------------------------------------------------------------
procedure validateServer(p_date in date, gridName in varchar2) is
begin
  if p_date is not NULL then
    if serverInitDate > p_date then
       -- dbms_output.put_line('in validation server');
       FND_MESSAGE.SET_NAME('JTF', 'JTF_GRID_SERVER_VALIDATION');
       FND_MESSAGE.SET_TOKEN('GRID', gridName, FALSE);
--       FND_MSG_PUB.ADD;
       raise_error;
    end if;
  end if;
end;

----------------------------------------------------------------------------
function findTableDefIndex(gridName in varchar2) return binary_integer is
  i binary_integer;
begin
  i := tableDefs.FIRST;
  while i is not null loop
  	if tableDefs(i).gridName = gridName then
   		return i;
   	end if;
    i := tableDefs.next(i);
  end loop;
  return null;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'findTableDefIndex',gridName,null,SQLERRM);
*/
end findTableDefIndex;

-----------------------------------------------------------------------------
-- Description:
--
-- handle Error messages
--
-- Notes: MUST NEVER BE CALLED FROM OUTSIDE OF THIS PACKAGE!
--
-- @param method The method where the error occurred.
-- @param tableIndex the index pointing to the row in tableDefs for the given grid
-- @param message The error message
-- @param SQLError The SQLERRM error message
-----------------------------------------------------------------------------

procedure handleErrors(errorType in pls_integer
                      ,method in varchar2
                      ,tableIndex in pls_integer
                      ,message in varchar2
                      ,SQLError in varchar2) is
begin
  if    errorType  = INVALID_GRID_ERROR
  or    tableIndex is null
  or    tableIndex = 0 then
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
    fnd_message.set_token('MSG','Internal Error: jtf_grid.handleErrors() was called from jtf_griddb.'||method||' with the following information:'
    ||lineFeed||lineFeed||nvl(message,'<'||nullValue||'>')
    ||lineFeed||lineFeed||'The error is in the form or the JTF_GRID package.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
  elsif errorType = INTERNAL_ERROR then
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
  	fnd_message.set_token('MSG','An unexpected error occurred in jtf_griddb.'||method
  	||lineFeed||lineFeed||'grid: <'||tableDefs(tableIndex).gridName|| '>'
  	||lineFeed||'datasource: <'||tableDefs(tableIndex).grid_datasource_name||'>'
  	||lineFeed||lineFeed||'The following information is available:'
    ||lineFeed||lineFeed||nvl(message,'<'||nullValue||'>')
  	||lineFeed||lineFeed||'The error is in the form or the JTF_GRID package.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
  elsif errorType = INVALID_PROPERTY_ERROR then
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
    fnd_message.set_token('MSG','Application Error: An invalid propertyType was passed to jtf_griddb.'||method
    ||lineFeed||lineFeed||'grid: <'||tableDefs(tableIndex).gridName|| '>'
    ||lineFeed||'datasource: <'||tableDefs(tableIndex).grid_datasource_name||'>'
    ||lineFeed||lineFeed||'The following information is available:'
    ||lineFeed||lineFeed||nvl(message,'<'||nullValue||'>')
    ||lineFeed||lineFeed||' The error is in the form.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
  elsif errorType = APPLICATION_ERROR then
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
    fnd_message.set_token('MSG','Application Error: jtf_griddb.'||method||' reports that an Application Error has occurred for:'
    ||lineFeed||lineFeed||'grid: <'||tableDefs(tableIndex).gridName|| '>'
    ||lineFeed||'datasource: <'||tableDefs(tableIndex).grid_datasource_name||'>'
    ||lineFeed||lineFeed||'The following information is available:'
    ||lineFeed||lineFeed||nvl(message,'<'||nullValue||'>')
    ||lineFeed||lineFeed||'The error is either in the form or the metadata definition.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
  elsif errorType = MAXLENGTH_EXCEEDED_ERROR then
   	fnd_message.set_name('JTF','JTF_GRID_EXCEED_MAXLENGTH');
  	fnd_message.set_token('MSG','Application Error: jtf_griddb.'||method||' reports: A record of data for:'
  	||lineFeed||lineFeed||'grid: <'||tableDefs(tableIndex).gridName|| '>'
  	||lineFeed||'datasource: <'||tableDefs(tableIndex).grid_dataSource_name||'>'
  	||lineFeed||lineFeed||'exceeds the current maxlength ('||to_char(jtf_dbstring_utils.getMaxStringLength)||' bytes / record). Reduce the number of columns defined in the datasource (metadata definition) or display partial column values.');
  elsif errorType = MISSING_SORT_COL_ERROR then
   	fnd_message.set_name('JTF','JTF_GRID_MISSING_SORT_COLUMN');
  	fnd_message.set_token('SOURCE','jtf_griddb.'||method);
  	fnd_message.set_token('DATASOURCE',tableDefs(tableIndex).grid_dataSource_name);
  	fnd_message.set_token('GRIDNAME',tableDefs(tableIndex).gridName);
  elsif errorType = INVALID_COLUMNALIAS_ERROR then
    fnd_message.set_name('JTF','JTF_GRID_INVALID_COLUMNALIAS');
  	fnd_message.set_token('SOURCE','jtf_griddb.'||method);
  	fnd_message.set_token('DATASOURCE',tableDefs(tableIndex).grid_dataSource_name);
  	fnd_message.set_token('COLUMN_ALIAS',nvl(message,'<'||nullValue||'>'));
  	fnd_message.set_token('GRIDNAME',tableDefs(tableIndex).gridName);
  elsif errorType = ILLEGAL_SORT_COLUMN_ERROR then
    fnd_message.set_name('JTF','JTF_GRID_ILLEGAL_SORT_COLUMN');
  	fnd_message.set_token('SOURCE','jtf_griddb.'||method);
  	fnd_message.set_token('DATASOURCE',tableDefs(tableIndex).grid_dataSource_name);
  	fnd_message.set_token('COLUMN_ALIAS',nvl(message,'<'||nullValue||'>'));
  	fnd_message.set_token('GRIDNAME',tableDefs(tableIndex).gridName);
  else
  	-- We should never get this message
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
    fnd_message.set_token('MSG','Internal Error: jtf_gridd.handleErrors() was called from jtf_griddb.'||method||' with an invalid errorType for:'
    ||lineFeed||lineFeed||'grid: <'||tableDefs(tableIndex).gridName|| '>'
    ||lineFeed||'datasource: <'||tableDefs(tableIndex).grid_dataSource_name||'>'
    ||lineFeed||lineFeed||'The following information is available:'
    ||lineFeed||lineFeed||nvl(message,'<'||nullValue||'>')
    ||lineFeed||lineFeed||'The error is in the form or the JTF_GRID package.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
  end if;
  raise_error;
end handleErrors;

-----------------------------------------------------------------------------
-- Description:
--
-- handle Error messages
--
-- Notes: MUST NEVER BE CALLED FROM OUTSIDE OF THIS PACKAGE!
--
-- @param method The method where the error occurred.
-- @param gridName The block.item where the error occurred
-- @param message  The error message
-- @param SQLError The SQLERRM error message
-----------------------------------------------------------------------------

procedure handleErrors(errorType in pls_integer
                      ,method in varchar2
                      ,gridName in varchar2
                      ,message in varchar2
                      ,SQLError in varchar2) is
  tableIndex pls_integer;
begin
  if errorType = INVALID_GRID_ERROR then
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
    fnd_message.set_token('MSG','Application Error: jtf_griddb.'||method||' reports that'
    ||lineFeed||lineFeed||'grid: <'||nvl(rtrim(gridName),nullValue)||'>'
    ||lineFeed||lineFeed||'has not been initialized. A grid must be specified using BLOCK.ITEM_NAME in UPPERCASE. The error is in the form.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
    raise_error;
  elsif errorType = INIT_ERROR then
  	fnd_message.set_name('JTF','JTF_GRID_DB_ERRORS');
  	fnd_message.set_token('SOURCE','JTF_GRIDDB');
    fnd_message.set_token('MSG','An unexpected error occurred in jtf_griddb.'||method||' for:'
    ||lineFeed||lineFeed||'grid: <'||nvl(rtrim(gridName),nullValue)|| '>'
    ||lineFeed||lineFeed||'The following information is available:'
    ||lineFeed||lineFeed||nvl(message,'<'||nullValue||'>')
    ||lineFeed||lineFeed||'The error is either in the form or the metadata definition.');
    fnd_message.set_token('SQLERROR',nvl(SQLError,'<'||nullValue||'>'));
    raise_error;
  elsif errorType = INVALID_DATASOURCE_ERROR then
   	fnd_message.set_name('JTF','JTF_GRID_INVALID_DATASOURCE');
  	fnd_message.set_token('SOURCE','jtf_griddb.'||method);
  	fnd_message.set_token('DATASOURCE',nvl(message,'<'||nullValue||'>'));
  	fnd_message.set_token('GRIDNAME',nvl(rtrim(gridName),nullValue||'>'));
    raise_error;
  else
  	tableIndex := findTableDefIndex(gridName);
  	if tableIndex is null
  	or tableIndex = 0 then
  	  -- recursive call if we can't find the gridName, this means that the grid has not been initialized.
      handleErrors(INVALID_GRID_ERROR,method,gridName,message,SQLError);
  	else
  	  handleErrors(errorType,method,tableIndex,message,SQLError);
  	end if;
  end if;
end handleErrors;

function getFetchSize return number is
begin
  return fetchSize;
end getFetchSize;

procedure setFetchSize(rows in number) is
begin
  fetchSize := rows;
end setFetchSize;
--------------------------------------------------------------------------

function findTableDefIndex(gridName in varchar2, p_serverInitDate in date) return binary_integer is
  i binary_integer;
begin
  validateServer(p_serverInitDate, gridName);
  return findTableDefIndex(gridName);
end findTableDefIndex;
----------------------------------------------------------------------------

-- Find the binary_integer that points to the row holding the meta data for the
-- next column for the current grid.
-- if colIndex is null or 0 then this function will return the first column
-- returns null is there are no more columns
function findNextColumnDefIndex(gridName in varchar2, colIndex in binary_integer) return binary_integer is
  i binary_integer;
begin
	if colIndex is null
	or colIndex = 0 then
	  i := columnDefs.FIRST;
	else
	  i := columnDefs.NEXT(colIndex);
	end if;

  while i is not null loop
    if columnDefs(i).gridName = gridName then
      return i;
    end if;
    i := columnDefs.next(i);
  end loop;
  return null;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'findNextColumnDefIndex',gridName,
    ' colIndex = <'||nvl(to_char(colIndex),nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end findNextColumnDefIndex;
-------------------------------------------------------------------------------
----------------------------------------------------------------------------

-- Find the Column Alias for the given columnIndex within the current spreadtable, this is not the
-- index pointing to a row in the columnDef collection, but rather the sequence number of the column
-- for the grid. The columnIndex a 1 based index.
function findColumnAlias(gridName in varchar2,columnIndex in integer) return varchar2 is
  i binary_integer;
  j integer := 0;
begin
	i := findNextColumnDefIndex(gridName,0);
  while i is not null loop
 		j := j + 1;
    if j = columnIndex then
      return columnDefs(i).grid_col_alias;
    end if;
   	i := findNextColumnDefIndex(gridName,i);
  end loop;
  return null;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'findColumnAlias',gridName,
    ' columnIndex = <'||nvl(to_char(columnIndex),nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end findColumnAlias;
-----------------------------------------------------------------------------
-- Find the next index pointing to a bindVariable for the given grid
function findNextBindVariable(gridName in varchar2, bindIndex in binary_integer) return binary_integer is
  i  binary_integer;
begin
	if bindIndex is not null
	or bindIndex > 0 then
	  i := bindVariables.NEXT(bindIndex);
	else
	  i := bindVariables.FIRST;
	end if;

  while i is not null loop
  	if bindVariables(i).gridName = gridName then
  		return i;
  	end if;
  	i := bindVariables.NEXT(i);
  end loop;
  return null;
/*
exception
  when others then
    handleErrors(INTERNAL_ERROR,'findNextBindVariable',gridName,
    ' bindIndex = <'||nvl(to_char(bindIndex),nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end findNextBindVariable;



function findBindVariableIndex(gridName in varchar2, variableName in varchar2) return binary_integer is
  i binary_integer;
begin
	if bindVariables.COUNT = 0 then
		return 1;
	else
    i := findNextBindVariable(gridName,null);
    while i is not null loop
  	  if bindVariables(i).variableName = variableName then
   		  return i;
  	  else
        i := findNextBindVariable(gridName,i);
  	  end if;
    end loop;
    -- if we get this far, the bindvariable did not exist in the collection, we need to find an empty spot.
    i := 1;
		if bindVariables.LAST <> bindVariables.COUNT then
      while i < tableDefs.LAST loop
     	  if bindVariables.EXISTS(i) then
     		  i := i + 1;
     	  else
      	  return i;
     	  end if;
      end loop;
    else
      return (bindVariables.LAST + 1);
    end if;
  end if;
  -- should never get this far
  return (nvl(bindVariables.LAST,0) + 1);
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'findBindVariableIndex',gridName,
    ' variableName = <'||nvl(variableName,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end findBindVariableIndex;


function bindVariablesCount(gridName varchar2) return number is
  i binary_integer;
  bindVarCount binary_integer := 0;
begin
	if bindVariables.COUNT = 0 then
		return bindVarCount;
	else
                i := findNextBindVariable(gridName,null);
                while i is not null loop
                        bindVarCount := bindVarCount + 1;
                        i := findNextBindVariable(gridName,i);
                end loop;
                return bindVarCount;
       end if;
end;


-- Find the binary_integer that points to the row holding the meta data for the
-- given column_alias and grid.
function findColumnDefIndex(gridName in varchar2
                           ,grid_col_alias in varchar2) return binary_integer is
  i binary_integer;
begin
	i := findNextColumnDefIndex(gridName,0);
  while i is not null loop
    if columnDefs(i).grid_col_alias = grid_col_alias then
      return i;
   	end if;
  	i := findNextColumnDefIndex(gridName,i);
  end loop;
  return null;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'findColumnDefIndex',gridName,
    ' grid_col_alias = <'||nvl(grid_col_alias,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end findColumnDefIndex;


function findColumnDefIndex(gridName in varchar2
                           ,grid_col_alias in varchar2
                           ,p_serverInitDate in date) return binary_integer is
begin
   validateServer(p_serverInitDate, gridName);
   return findColumnDefIndex(gridName, grid_col_alias);
end findColumnDefIndex;


-- Find the Column Index for the given column within the current spreadtable, this is not the
-- index pointing to a row in the columnDef collection, but rather the sequence number of the column
-- for the grid.
-- This returned value is a 1 based index
function findColumnIndex(gridName in varchar2,grid_col_alias in varchar2) return integer is
  i binary_integer;
  j integer := 0;
begin
	i := findNextColumnDefIndex(gridName,0);
  while i is not null loop
 		j := j + 1;
    if columnDefs(i).grid_col_alias = grid_col_alias then
      return j;
    end if;
   	i := findNextColumnDefIndex(gridName,i);
  end loop;
  return null;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'findColumnIndex',gridName,
    ' grid_col_alias = <'||nvl(grid_col_alias,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end findColumnIndex;

function findColumnIndex(gridName in varchar2,grid_col_alias in varchar2, p_serverInitDate in date) return integer is
begin
  validateServer(p_serverInitDate, gridName);
  return findColumnIndex(gridName, grid_col_alias);
end findColumnIndex;

-----------------------------------------------------------------------------
function findColumnAlias(gridName in varchar2,columnIndex in integer, p_serverInitDate in date) return varchar2 is
begin
   validateServer(p_serverInitDate, gridName);
   return findColumnAlias(gridName,columnIndex);
end findColumnAlias;



function isMoreRowsAvailable(gridName in varchar2
                            ,p_serverInitDate in date) return varchar2 is
  i binary_integer;
begin
        validateServer(p_serverInitDate, gridName);
	i := findTableDefIndex(gridName);
	if i is not null then
    return tableDefs(i).moreRowsExists;
	else
		return null;
	end if;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'isMoreRowsAvailable',gridName,null,SQLERRM);
*/
end isMoreRowsAvailable;

function convertColumnToString(columnDefIndex in binary_integer) return varchar2 is
begin
  if columnDefs(columnDefIndex).data_type_code = 'C' then
    return columnDefs(columnDefIndex).db_col_name;
  elsif columnDefs(columnDefIndex).data_type_code = 'N' then
    if columnDefs(columnDefIndex).display_format_mask is not null then
      return 'to_char('|| columnDefs(columnDefIndex).db_col_name || ','''||columnDefs(columnDefIndex).display_format_mask||''')';
    elsif columnDefs(columnDefIndex).display_format_type_code = 'CUR'
    and   columnDefs(columnDefIndex).db_currency_code_col is not null then
    	return 'to_char('|| columnDefs(columnDefIndex).db_col_name || ',fnd_currency.get_format_mask('||columnDefs(columnDefIndex).db_currency_code_col||',jtf_dbstring_utils.getCurrencyFormatLength))';
    else
      return 'to_char('|| columnDefs(columnDefIndex).db_col_name || ')' ;
    end if;
  elsif columnDefs(columnDefIndex).data_type_code = 'D' then
    if columnDefs(columnDefIndex).display_format_type_code = 'DAT' then
      return 'fnd_date.date_to_displaydate('|| columnDefs(columnDefIndex).db_col_name || ')';
    else
    	return 'fnd_date.date_to_displayDT('|| columnDefs(columnDefIndex).db_col_name || ')';
    end if;
  else
    return columnDefs(columnDefIndex).db_col_name;
  end if;
end convertColumnToString;
/*
--03/13/2001 added this procedure to define columns based on their datatype.
procedure defineColumn(gridName in varchar2) is
begin

end;
*/
-- Builds a piece of the ORDER BY clause for the dynamic SQL statement
-- 03/13/2001 modified this procedure  to use grid_col_alias and not the
-- db_col_name to enable having unions in the where clause.
function buildOrderByClause(gridName in varchar2, grid_sort_col_alias in varchar2, orderClause in varchar2) return varchar2 is
  m_orderClause varchar2(600) := null;
  i  binary_integer;
begin
  if grid_sort_col_alias is not null then
       /* continue to have this check even though we don't use db_col anymore*/
  	i := findColumnDefIndex(gridName,grid_sort_col_alias);
  	if i is not null then
  		if orderClause is not null then
  			--m_orderClause := orderClause ||', '||columnDefs(i).db_col_name;
                    m_orderClause := orderClause ||','||nvl(columnDefs(i).db_sort_column, columnDefs(i).SQL_colAlias);
  		else
  			--m_orderClause := columnDefs(i).db_col_name;
                    m_orderClause := nvl(columnDefs(i).db_sort_column, columnDefs(i).SQL_colAlias);
  		end if;
      if columnDefs(i).sort_asc_by_default_flag = 'T' then
        m_orderClause := m_orderClause ||' ASC';
      else
      	m_orderClause := m_orderClause ||' DESC';
      end if;
  	end if;
  else
    return orderClause;
  end if;
  return m_orderClause;
end buildOrderByClause;

function prepareSQL(gridName in varchar2, tableIndex in binary_integer) return boolean is

  dynSQL      jtf_dbstring_utils.maxString%TYPE  := null;
  fromClause  varchar2(200) := null;
  whereClause varchar2(4000):= null;
  orderClause varchar2(600) := null;
  i pls_integer;
  j pls_integer := 1;
begin
  -- Get the first colIndex
  i := findNextColumnDefIndex(gridName,0);

  if i is null then
    return false;
  end if;

  dynSQL := 'SELECT ';
  while i is not null loop
   -- keeps track of the generated SQL column alias for each column in the metadata. Needed to create a proper sort order using aliases.
   columnDefs(i).SQL_colAlias := 'COL'||to_char(j);
   if columnDefs(i).fire_post_query_flag = 'T' then
         -- dynSQL := dynSQL ||'NULL '||columnDefs(i).grid_col_alias;
        dynSQL := dynSQL ||'NULL  COL'||to_char(j);
   else
    -- dynSQL := dynSQL || convertColumnToString(i);
    -- 03/13/01 modified the select statement to accept the db_col_name
    --   dynSQL := dynSQL || columnDefs(i).db_col_name || ' '||columnDefs(i).grid_col_alias;

    	dynSQL := dynSQL || columnDefs(i).db_col_name || ' COL'||to_char(j);
        -- if the column is a curreny column then select teh currency code also
        if columnDefs(i).data_type_code = 'N'
            and columnDEfs(i).display_format_type_code = 'CUR' then
        -- should include this even if currency code col isNULL as we expect it when we define the columns etc.
        --  dynSQL := dynSQL ||','||columnDefs(i).db_currency_code_col||' '||columnDefs(i).grid_col_alias||'_CODE';
           j := j + 1;
           dynSQL := dynSQL ||','||columnDefs(i).db_currency_code_col|| ' COL'||to_char(j);
       elsif columnDefs(i).data_type_code = 'I'
                 and columnDefs(i).image_Description_col is not NULL then
        --  dynSQL := dynSQL ||','||columnDefs(i).image_Description_col||' '||columnDefs(i).grid_col_alias||'_DESC';
          j  :=j + 1;
          dynSQL := dynSQL ||','||columnDefs(i).image_Description_col|| ' COL'||to_char(j);
         -- in case of images you always want to sort by the description if
         -- available. hence, mapping the SQL_colAlias of the image column to
         -- the column alias of the description column

         columnDefs(i).SQL_colAlias := 'COL'||to_char(j);

       end if;

  end if;  -- post_query_flag = 'T'
    i := findNextColumnDefIndex(gridName,i);
    -- add a comma unless this is the last column
    if i is not null then
    	dynSQL := dynSQL ||', ';
        j := j + 1;
    end if;
  end loop;

  fromClause  := ' FROM '|| tableDefs(tableIndex).db_view_name;

  if rtrim(tableDefs(tableIndex).where_clause) is not null then
    whereClause := ' WHERE '||tableDefs(tableIndex).where_clause;
  end if;

  orderClause := buildOrderByClause(gridName,tableDefs(tableIndex).grid_sort_col_alias1,null);
  orderClause := buildOrderByClause(gridName,tableDefs(tableIndex).grid_sort_col_alias2,orderClause);
  orderClause := buildOrderByClause(gridName,tableDefs(tableIndex).grid_sort_col_alias3,orderClause);
  if orderClause is not null then
  	orderClause := ' ORDER BY '|| orderClause;
  end if;

  tableDefs(tableIndex).SQLStatement := dynSQL || fromClause || whereClause || orderClause;
  -- everything went well
  --dbms_output.put_line(tableDefs(tableIndex).SQLStatement);
  return true;
exception
  when OTHERS then
    -- handleErrors(INTERNAL_ERROR,'prepareSQL',gridName,null
    -- ' tableIndex = <'||nvl(to_char(tableIndex),nullValue)||'>'||lineFeed
    -- ,SQLERRM);
    return false;

end prepareSQL;

procedure handleBindVariables(gridName in varchar2, tableIndex in binary_integer) is
  i binary_integer;
begin
  i := findNextBindVariable(gridName,null);
  while i is not null loop
  	if bindVariables(i).variableDataType = 'C' then
  		dbms_sql.bind_variable(tableDefs(tableIndex).SQLCursor,bindVariables(i).variableName,bindVariables(i).variableCharValue);
  	elsif bindVariables(i).variableDataType = 'D' then
  		dbms_sql.bind_variable(tableDefs(tableIndex).SQLCursor,bindVariables(i).variableName,bindVariables(i).variableDateValue);
  	elsif bindVariables(i).variableDataType = 'N' then
  		dbms_sql.bind_variable(tableDefs(tableIndex).SQLCursor,bindVariables(i).variableName,bindVariables(i).variableNumberValue);
  	else
  		null;
  		-- Unknown datatype, should never get here
  	end if;
  	i := findNextBindVariable(gridName,i);
  end loop;
exception
  when others then
    if dbms_sql.is_open(tableDefs(tableIndex).SQLCursor) then
      dbms_sql.close_cursor(tableDefs(tableIndex).SQLCursor);
      tableDefs(tableIndex).SQLCursor := null;
    end if;
    raise;
--    handleErrors(INTERNAL_ERROR,'handleBindVariables',gridName,
--    ' bindVariable = <'||nvl(bindVariables(i).variableName,nullValue)||'>'||lineFeed
--    ,SQLERRM);

end handleBindVariables;

function execSQL(gridName in varchar2, tableIndex in binary_integer) return varchar2 is
  rows    integer;
 -- colVal  varchar2(4000);
  ignore  integer;

-- 03/13/01 need additional columns to remove function calls
  charColVal  varchar2(4000);
  ImageCharColVal  varchar2(4000);
  numberColVal number;
  dateColVal   date;
  columnDefIndex pls_integer := 0;
  i pls_integer := 0;
  j pls_integer := 1;

begin
  -- CURSOR MGMT REWRITE

  -- If we don't have a handle to the cursor or it is closed for some reason
  -- we reopen it and make sure that the sql statement will be parsed as well
  -- as having any bind variables bound
  if tableDefs(tableIndex).SQLCursor is null
  or not dbms_sql.is_open(tableDefs(tableIndex).SQLCursor) then
    tableDefs(tableIndex).SQLCursor := dbms_sql.open_cursor;
    tableDefs(tableIndex).hasBindVarsChanged := 'T';
    tableDefs(tableIndex).hasWhereClauseChanged := 'T';
  end if;

  -- If we need to refresh the query AND the whereClause has changed for
  -- some reason -> we recreate the where clause and parse it
  if  tableDefs(tableIndex).refreshFlag = 'T'
  and tableDefs(tableIndex).hasWhereClauseChanged = 'T' then

    -- If we fail to build up the sql statement we close the
    -- cursor straight away.
    if prepareSQL(gridName,tableIndex) = false then
      dbms_sql.close_cursor(tableDefs(tableIndex).SQLCursor);
      tableDefs(tableIndex).SQLCursor := null;
      return null;
    -- If the SQL statement is OK, we parse and define the columns
    else
      dbms_sql.parse(tableDefs(tableIndex).SQLCursor, tableDefs(tableIndex).SQLStatement, dbms_sql.native);
    ----------------------------------------------------------
    for i in 1..temp_columnDefs.count loop
        --dbms_output.put_line('i si ' ||i||columnDefs(i).data_type_code);
        if temp_columnDefs(i).data_type_code = 'C' then
           dbms_sql.define_column(tableDefs(tableIndex).SQLCursor,j, charColVal, 4000);
        elsif temp_columnDefs(i).data_type_code = 'N' then
           dbms_sql.define_column(tableDefs(tableIndex).SQLCursor,j, NumberColVal);
           if temp_columnDefs(i).display_format_type_code = 'CUR' then
              j := j + 1;
              dbms_sql.define_column(tableDefs(tableIndex).SQLCursor, j, charColVal, 4000);
           end if;
        elsif temp_columnDefs(i).data_type_code = 'D' then
           dbms_sql.define_column(tableDefs(tableIndex).SQLCursor, j, dateColVal);
        elsif temp_columnDefs(i).data_type_code = 'I' then
           dbms_sql.define_column(tableDefs(tableIndex).SQLCursor,j, charColVal, 4000);
           if temp_columnDefs(i).image_description_col is not NULL then
             j := j + 1;
             dbms_sql.define_column(tableDefs(tableIndex).SQLCursor,j, CharColVal, 4000);
           end if;
        end if;
        j := j + 1;
      end loop;
     ----------------------------------------------------------------------
    end if;
  end if;

  -- If we need to refresh the query AND the bind variables has changed for
  -- some reason -> rebind the variables. Note if the WhereClause was changed we need
  -- to rebind
  if  tableDefs(tableIndex).refreshFlag = 'T'
  and (tableDefs(tableIndex).hasBindVarsChanged = 'T'
  or  tableDefs(tableIndex).hasWhereClauseChanged = 'T') then
    handleBindVariables(gridName,tableIndex);

    tableDefs(tableIndex).hasBindVarsChanged := 'F';
    tableDefs(tableIndex).hasWhereClauseChanged := 'F';
  end if;

  -- If we need to refresh the query for whatever reason -> execute the query
  if  tableDefs(tableIndex).refreshFlag = 'T' then
    ignore := dbms_sql.execute(tableDefs(tableIndex).SQLCursor);
    tableDefs(tableIndex).refreshFlag := 'F';
  end if;

  -- Fetch one row and write the result to the stream
  rows := dbms_sql.fetch_rows(tableDefs(tableIndex).SQLCursor);
  if rows > 0 then
    jtf_dbstream_utils.clearOutputStream;

/* the retrieved values are no longer only varchar2
    for i in 1..tableDefs(tableIndex).colCount loop
      dbms_sql.column_value(tableDefs(tableIndex).SQLCursor, i, colVal);
      jtf_dbstream_utils.writeString(colVal);
       end loop;
*/
-----------------------------------------------
     j := 1;
     for i in 1..temp_columnDefs.count loop
        --dbms_output.put_line('i value is '||i||' datatype is '||columnDefs(i).data_type_code);
        if temp_columnDefs(i).data_type_code = 'C' then
           dbms_sql.column_value(tableDefs(tableIndex).SQLCursor, j, CharColVal);
           jtf_dbstream_utils.writeString(charColVal);
        elsif temp_columnDefs(i).data_type_code = 'N' then
           dbms_sql.column_value(tableDefs(tableIndex).SQLCursor,j, NumberColVal);
           if temp_columnDefs(i).display_format_mask is not null then
              jtf_dbstream_utils.writeString(to_char(NumberColVal,temp_columnDefs(i).display_format_mask));
          elsif temp_columnDefs(i).display_format_type_code = 'CUR'
             and   temp_columnDefs(i).db_currency_code_col is not null then
              j := j + 1;
              dbms_sql.column_value(tableDefs(tableIndex).SQLCursor, j, charColVal);
              jtf_dbstream_utils.writeCurrency(NumberColVal, charColVal);
           else
              jtf_dbstream_utils.writeNumber(NumberColVal);
           end if;
        elsif temp_columnDefs(i).data_type_code = 'D' then
           dbms_sql.column_value(tableDefs(tableIndex).SQLCursor, j, dateColVal);
           if temp_columnDefs(i).display_format_type_code = 'DAT' then
             jtf_dbstream_utils.writeDate(DateColVal);
           else
             jtf_dbstream_utils.writeDateTime(DateColVal);
           end if;
        elsif temp_columnDefs(i).data_type_code = 'I' then
           dbms_sql.column_value(tableDefs(tableIndex).SQLCursor, j, CharColVal);
           imageCharColVal := CharColVal;
           if temp_columnDefs(i).image_description_col is not NULL then
              j := j + 1;
              dbms_sql.column_value(tableDefs(tableIndex).SQLCursor, j, CharColVal);
             jtf_dbstream_utils.writeString(ImageCharColVal||IMAGE_SEPARATOR||CharColVal);
           else
             jtf_dbstream_utils.writeString(ImageCharColVal||IMAGE_SEPARATOR);
           end if;
        end if;
        j := j + 1;
      end loop;
  -------------------------------------------------------------
  else
    -- We don't close the cursor nowadays, only if the grid is initialized
    -- with a different datasource will it be closed and reopened
    --  dbms_sql.close_cursor(tableDefs(tableIndex).SQLCursor);
    return null;
  end if;
  -- CURSOR MGMT REWRITE END
  if jtf_dbstream_utils.isLongOutputStream then
  	handleErrors(MAXLENGTH_EXCEEDED_ERROR,'execSQL',gridName,
  			' SQL Statement being executed: <'||nvl(tableDefs(tableIndex).SQLStatement,nullValue)||'>'||lineFeed
  			,null);
  end if;
  return jtf_dbstream_utils.getOutputStream;
exception
  when others then
    if dbms_sql.is_open(tableDefs(tableIndex).SQLCursor) then
      dbms_sql.close_cursor(tableDefs(tableIndex).SQLCursor);
      tableDefs(tableIndex).SQLCursor := null;
    end if;
    raise;
--    handleErrors(INTERNAL_ERROR,'execSQL',gridName,null
--		' SQL Statement: <'||nvl(tableDefs(tableIndex).SQLStatement,nullValue)||'>'||lineFeed||
--    ' tableIndex = <'||nvl(to_char(tableIndex),nullValue)||'>'||lineFeed||
--    ' rows = <'||nvl(to_char(rows),nullValue)||'>'||lineFeed||
--    ' colVal = <'||nvl(colVal,nullValue)||'>'||lineFeed||
--    ' rowVal = <'||nvl(replace(rowVal,separator,readableSeparator),nullValue)||'>'||lineFeed
--    ,SQLERRM);
end execSQL;

function fetchDataSet(gridName in varchar2
                      ,p_serverInitDate in date) return dataSet%TYPE is
  j               binary_integer;
  tempRec         jtf_dbstring_utils.maxString%TYPE;
  NOT_INITIALIZED Exception;
  rowCount        pls_integer;
  colCount        varchar2(6);
  i               pls_integer;
  k               pls_integer := 1;
begin
  validateServer(p_serverInitDate, gridName);
  dataSet.delete;
  j := findTableDefIndex(gridName);
  if j is null then
    raise NOT_INITIALIZED;
  end if;

  if tableDefs(j).moreRowsExists = 'T' then
    rowCount := tableDefs(j).rowCount;
    colCount := to_char(tableDefs(j).colCount);
   -- before fetching populate a temp_colDefs table with teh column definitions
  -- of this grid. this will reduce unnecessary searches in execSQL
    temp_columnDefs.DELETE;
    i := findNextColumnDefIndex(gridname, 0);
    while i is not NULL loop
      temp_columnDefs(k) := columnDefs(i);
      i := findNextColumnDefIndex(gridName, i);
      k := k + 1;
    end loop;
--   dbms_output.put_line('fetch size is ' || tableDefs(j).fetchSize);
   for i in 1..nvl(tableDefs(j).fetchSize, fetchSize) loop
      tempRec := execSQL(gridName,j);
      if tempRec is not null then
      	rowCount := rowCount + 1;
        jtf_dbstream_utils.clearOutputStream;
    -- 02/28/01 commented out the rowCount to enable inserts/deletes into the
    -- spreadtable. The midtier will add this to the stream before it sends it
    -- off to the client.
    --    jtf_dbstream_utils.writeInt(rowCount);
        jtf_dbstream_utils.writeString(recVersion);
        jtf_dbstream_utils.writeString(colCount);
        if jtf_dbstream_utils.isLongOutputStream then
         	handleErrors(MAXLENGTH_EXCEEDED_ERROR,'fetchDataSet',gridName,
  		   	' SQL Statement being executed: <'||nvl(tableDefs(j).SQLStatement,nullValue)||'>'||lineFeed
  			  ,null);
        end if;
        -- don't write tempRec to the stream, as it is already
        -- formatted by execSQL
        dataSet(i) := jtf_dbstream_utils.getOutputStream||tempRec;
      else
        tableDefs(j).moreRowsExists := 'F';
        exit;
      end if;
    end loop;
    tableDefs(j).rowCount := rowCount;
  end if;
  return dataSet;
exception
  when NOT_INITIALIZED then
    handleErrors(INVALID_GRID_ERROR,'fetchDataSet',gridName,null,null);
    return dataSet;
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'fetchDataSet',gridName,
		' tempRec = <'||nvl(tempRec,nullValue)||'>'||lineFeed||
    ' rowCount = <'||nvl(to_char(rowCount),nullValue)||'>'||lineFeed||
    ' colCount = <'||nvl(colCount,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end fetchDataSet;


-----------------------------------------------------------------------------

procedure refresh(gridName in varchar2,tableIndex in binary_integer) is
begin
	if tableIndex is null then
		raise INVALID_GRID;
	end if;
-- CURSOR MGMR REWRITE
--  if  tableDefs(tableIndex).moreRowsExists = 'T'
--  and tableDefs(tableIndex).SQLCursor is not null
--  and dbms_sql.is_open(tableDefs(tableIndex).SQLCursor) then
--    dbms_sql.close_cursor(tableDefs(tableIndex).SQLCursor);
--  end if;
--  tableDefs(tableIndex).SQLCursor := null;
-- CURSOR MGMR REWRITE END
  tableDefs(tableIndex).moreRowsExists := 'T';
  tableDefs(tableIndex).rowCount := 0;

  -- CURSOR MGMT REWRITE
  -- This will make sure we validate whether the WhereClause or
  -- Bindvariables has changed in execSQL
  tableDefs(tableIndex).refreshFlag := 'T';
  -- CURSOR MGMT REWRITE END

exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'refresh',gridName,null,null);
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'refresh',gridName,null,SQLERRM);
*/
end refresh;


function isTabColsInMemory(gridName in varchar2) return boolean is
  i binary_integer;
begin
  i := findNextColumnDefIndex(gridName,0);
  if i is not null then
    return true;
  else
	  return false;
  end if;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'isTabColsInMemory',gridName,null,SQLERRM);
*/
end isTabColsInMemory;

-- Retrieve top level Meta Data information from the
-- database
function getTableDefFromDB(gridName in varchar2, dataSource in varchar2) return binary_integer is

 cursor tableDef(gridName in varchar2, dataSource in varchar2) is
   select gridName
         ,grd.title_text
         ,grc.cols     -- ColCount
         ,0            -- Current Row Count
         ,'T'          -- more Rows exists
         ,null         -- SQL statement
         ,null         -- SQL cursor
         ,grd.grid_datasource_name
         ,grd.db_view_name
         ,grd.default_row_height
         ,grd.max_queried_rows
         ,grd.where_clause
         ,gsc.grid_sort_col_alias1
         ,gsc.grid_sort_col_alias2
         ,gsc.grid_sort_col_alias3
         ,'209,219,245' -- Ignore the col value, std color will be used nvl(grd.alt_color_code,'255,255,255')
         ,1             -- nvl(grd.alt_color_interval,0)
         ,null
         ,null
         ,null
         ,null
         ,'T'  -- whereClauseChanged
         ,'T'  -- bindVarsChanged
         ,'T'       -- refreshFlag
         ,fetch_Size -- fetchSize
    from  jtf_grid_datasources_vl grd
         ,jtf_grid_sort_cols   gsc
         ,(
            select grid_datasource_name
                  ,count(*) cols
            from jtf_grid_cols_b
            group by grid_datasource_name
          ) grc
    where grd.grid_datasource_name = dataSource
    and   grd.grid_datasource_name = gsc.grid_datasource_name(+)
    and   grd.grid_datasource_name = grc.grid_datasource_name;

  -- load the default folder as defined in jtf_def_custom_grids
  cursor defaultFolderDef(dataSource in varchar2) is
   select cgs.custom_grid_id
         ,cgs.custom_grid_name
         ,cgs.default_row_height
         ,cgs.where_clause
         ,cgs.grid_sort_col_alias1
         ,cgs.grid_sort_col_alias2
         ,cgs.grid_sort_col_alias3
         ,cgs.public_flag
         ,cgs.created_by  -- this is the owner
    from  jtf_custom_grids     cgs
         ,jtf_def_custom_grids dcg
    where dcg.grid_datasource_name = dataSource
    and   dcg.created_by           = fnd_global.user_id
    and   dcg.custom_grid_id       = cgs.custom_grid_id
    and   cgs.language             = userenv('LANG');

  i binary_integer;
  INVALID_DATASOURCE exception;

  l_custom_grid_id       number;
  l_custom_grid_name     varchar2(80);
  l_default_row_height   number(2);
  l_where_clause         varchar2(2000);
  l_grid_sort_col_alias1 varchar2(30);
  l_grid_sort_col_alias2 varchar2(30);
  l_grid_sort_col_alias3 varchar2(30);
  l_public_flag          varchar2(1);
  l_created_by           number(15);  -- this is the owner


begin
  if gridName is null
  or dataSource is null then
    return null;
  end if;

 	i := nvl(tableDefs.LAST,0) + 1;

  open  tableDef(gridName,dataSource);
  fetch tableDef into tableDefs(i);
  if tableDef%NOTFOUND then
  	close tableDef;
    raise INVALID_DATASOURCE;
  end if;
  close tableDef;

  open  defaultFolderDef(dataSource);
  fetch defaultFolderDef into
     l_custom_grid_id
    ,l_custom_grid_name
    ,l_default_row_height
    ,l_where_clause
    ,l_grid_sort_col_alias1
    ,l_grid_sort_col_alias2
    ,l_grid_sort_col_alias3
    ,l_public_flag
    ,l_created_by;

  if defaultFolderDef%FOUND then
    tableDefs(i).custom_grid_id := l_custom_grid_id;
    tableDefs(i).custom_grid_name := l_custom_grid_name;
    if l_default_row_height is not null then
      tableDefs(i).default_row_height := l_default_row_height;
    end if;
    if l_where_clause is not null then
      tableDefs(i).where_clause := l_where_clause;
    end if;
    tableDefs(i).grid_sort_col_alias1 := l_grid_sort_col_alias1;
    tableDefs(i).grid_sort_col_alias2 := l_grid_sort_col_alias2;
    tableDefs(i).grid_sort_col_alias3 := l_grid_sort_col_alias3;
    tableDefs(i).public_flag := l_public_flag;
    tableDefs(i).owner := l_created_by;
  end if;
	close defaultFolderDef;

  return i;

exception
  when INVALID_DATASOURCE then
    handleErrors(INVALID_DATASOURCE_ERROR,'getTableDefFromDB',gridName,dataSource,null);
    return null;
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'getTableDefFromDB',gridName,
    ' dataSource = <'||nvl(dataSource,nullValue)||'>'||lineFeed
    ,SQLERRM);
    return null;
*/
end getTableDefFromDB;

-- Retrieve column level Meta Data from the database
procedure getColDefsFromDB(gridName in varchar2, dataSource in varchar2, tableIndex in binary_integer) is

  cursor columnDef(gridName in varchar2, dataSource in varchar2) is
    select  gridName
           ,grc.grid_datasource_name
           ,grc.grid_col_alias
           ,grc.db_col_name
           ,grc.data_type_code
           ,grc.query_seq
           ,grc.sortable_flag
           ,grc.sort_asc_by_default_flag
           ,grc.visible_flag
           ,grc.freeze_visible_flag
           ,null                     -- this needs to be converted to display_index
           ,grc.display_type_code
           ,grc.display_format_type_code
           ,grc.display_hsize
           ,grc.header_alignment_code
           ,grc.cell_alignment_code
           ,grc.display_format_mask
           ,grc.checkbox_checked_value
           ,grc.checkbox_unchecked_value
           ,nvl(grc.checkbox_other_values,'F')
           ,grc.db_currency_code_col
           ,null                     -- currency_column_alias
           ,grc.label_text
           ,grc.db_sort_column
           ,grc.fire_post_query_flag
           ,grc.image_description_col
           ,null                    -- SQL column alias
    from jtf_grid_cols_vl      grc
    where grc.grid_datasource_name = dataSource
    order by grc.query_seq;

  cursor columnFolderDef(gridName in varchar2, dataSource in varchar2,x_custom_grid_id in number) is
    select  gridName
           ,grc.grid_datasource_name
           ,grc.grid_col_alias
           ,grc.db_col_name
           ,grc.data_type_code
           ,grc.query_seq
           ,grc.sortable_flag
           ,decode(grc.sortable_flag,'F',grc.sort_asc_by_default_flag,nvl(cgc.sort_asc_by_default_flag,grc.sort_asc_by_default_flag)) -- if false override customized value
           ,decode(grc.freeze_visible_flag,'T',grc.visible_flag,nvl(cgc.visible_flag,grc.visible_flag)) -- If true, override customized value
           ,grc.freeze_visible_flag
           ,null                     -- this needs to be converted to display_index
           ,grc.display_type_code
           ,grc.display_format_type_code
           ,nvl(cgc.display_hsize,grc.display_hsize)
           ,grc.header_alignment_code
           ,grc.cell_alignment_code
           ,grc.display_format_mask
           ,grc.checkbox_checked_value
           ,grc.checkbox_unchecked_value
           ,nvl(grc.checkbox_other_values,'F')
           ,grc.db_currency_code_col
           ,null                     -- currency_column_alias
           ,nvl(cgc.label_text,grc.label_text)
           ,grc.db_sort_column
           ,grc.fire_post_query_flag
           ,grc.image_description_col
           ,null                    -- sql column alias
    from  jtf_grid_cols_vl      grc
         ,jtf_custom_grid_cols  cgc
    where grc.grid_datasource_name = dataSource
    and   grc.grid_datasource_name = cgc.grid_datasource_name(+)
    and   grc.grid_col_alias       = cgc.grid_col_alias(+)
    and   cgc.custom_grid_id(+) = x_custom_grid_id
    order by grc.query_seq;


  cursor displaySeq(dataSource in varchar2) is
    select grc.grid_col_alias
    from   jtf_grid_cols_b grc
    where  grc.grid_datasource_name = datasource
    order by grc.display_seq;

  cursor folderDisplaySeq(dataSource in varchar2, x_custom_grid_id in number) is
    select grc.grid_col_alias
    from   jtf_grid_cols_vl      grc
          ,jtf_custom_grid_cols  cgc
    where  grc.grid_datasource_name = datasource
    and    grc.grid_datasource_name = cgc.grid_datasource_name(+)
    and    grc.grid_col_alias       = cgc.grid_col_alias(+)
    and    cgc.custom_grid_id(+) = x_custom_grid_id
    order by cgc.display_seq;


  cursor currency_col_alias(x_dataSource in varchar2,x_db_currency_code_col in varchar2) is
    select grc.grid_col_alias
    from   jtf_grid_cols_b grc
    where  grc.grid_datasource_name = x_dataSource
    and    grc.db_col_name = x_db_currency_code_col;

  INVALID_DATASOURCE exception;
  NO_DATASOURCE exception;

  i binary_integer;

  display_index  integer := 0;
  grid_col_alias varchar2(30);
begin
  if gridName is null
  or dataSource is null then
    raise NO_DATASOURCE;
  end if;

  i := nvl(columnDefs.LAST,0) + 1;

  -- if we are using the default settings
  if tableDefs(tableIndex).custom_grid_id is null then
    open columnDef(gridName,dataSource);
    fetch columnDef into columnDefs(i);

    if columnDef%NOTFOUND then
      close columnDef;
      raise INVALID_DATASOURCE;
    end if;

    while columnDef%FOUND loop
      -- if db_currency_code_col is not null then we search the metadata definition
      -- for a spreadtablecolumn based on this database column. If we find one,the
      -- developer will be able to use jtf_grid.getColumnNumberValue to retrieve the numeric value.
      -- If we don't find one, we have no idea (in the midtier) how the value is formatted, hence
      -- the developer will have to do the conversion themselves, ie using jtf_grid.getColumnCharValue
      if columnDefs(i).db_currency_code_col is not null then
        open currency_col_alias(dataSource,columnDefs(i).db_currency_code_col);
        fetch currency_col_alias into columnDefs(i).db_currency_col_alias;
        close currency_col_alias;
      end if;
      i := i + 1;
      fetch columnDef into columnDefs(i);
    end loop;
    close columnDef;

    open displaySeq(dataSource);
    fetch displaySeq into grid_col_alias;
    while displaySeq%FOUND loop
      i := findColumnDefIndex(gridName,grid_col_alias);
      columnDefs(i).display_index := display_index;

      fetch displaySeq into grid_col_alias;
      display_index := display_index + 1;
    end loop;
    close displaySeq;

  -- if we are using a folder
  else
    open columnFolderDef(gridName,dataSource,tableDefs(tableIndex).custom_grid_id);
    fetch columnFolderDef into columnDefs(i);

    if columnFolderDef%NOTFOUND then
      close columnFolderDef;
      raise INVALID_DATASOURCE;
    end if;

    while columnFolderDef%FOUND loop
      -- if db_currency_code_col is not null then we search the metadata definition
      -- for a spreadtablecolumn based on this database column. If we find one,the
      -- developer will be able to use jtf_grid.getColumnNumberValue to retrieve the numeric value.
      -- If we don't find one, we have no idea (in the midtier) how the value is formatted, hence
      -- the developer will have to do the conversion themselves, ie using jtf_grid.getColumnCharValue
      if columnDefs(i).db_currency_code_col is not null then
        open currency_col_alias(dataSource,columnDefs(i).db_currency_code_col);
        fetch currency_col_alias into columnDefs(i).db_currency_col_alias;
      close currency_col_alias;
      end if;
      i := i + 1;
      fetch columnFolderDef into columnDefs(i);
    end loop;
    close columnFolderDef;

    ------------------------------------
    -- IS THERE A MORE EFFICIENT WAY OF DOING THIS (GETTING THE DISPLAY_INDEX) THAN
    -- MAKING TWO PASSES AND SEARCHING THROUGH THE MEMORY
    ------------------------------------
    open folderDisplaySeq(dataSource,tableDefs(tableIndex).custom_grid_id);
    fetch folderDisplaySeq into grid_col_alias;
    while folderDisplaySeq%FOUND loop
      i := findColumnDefIndex(gridName,grid_col_alias);
      columnDefs(i).display_index := display_index;

      fetch folderDisplaySeq into grid_col_alias;
      display_index := display_index + 1;
    end loop;
    close folderDisplaySeq;
  end if;

exception
  when NO_DATASOURCE then
    handleErrors(INVALID_DATASOURCE_ERROR,'getColDefsFromDB',gridName,dataSource,null);
  when INVALID_DATASOURCE then
    handleErrors(INVALID_DATASOURCE_ERROR,'getColDefsFromDB',gridName,dataSource,null);
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'getColDefsFromDB',gridName,
    ' dataSource = <'||nvl(dataSource,nullValue)||'>',SQLERRM);
*/
end getColDefsFromDB;

-- Check to see whether the sort columns as defined in tableDefs also
-- exists in columnDefs. This could get corrupted if:
-- 1. The end user sorts on a few columns.
-- 2. Saves the customizations.
-- 3. The columns that the end user sorted on are deleted from the
--    metadata definition.
--
-- Here we check whether they exist in the metadata definition, if not we load
-- the default sort columns and apply these instead. As a final step we
-- update the customization data to reflect the default sort order.
procedure repairSortColumns(gridName in varchar2
                           ,tableIndex in binary_integer
                           ,dataSource in varchar2) is
  PRAGMA AUTONOMOUS_TRANSACTION;

  cursor sortCols(dataSource in varchar2) is
   select gsc.grid_sort_col_alias1
         ,gsc.grid_sort_col_alias2
         ,gsc.grid_sort_col_alias3
    from  jtf_grid_sort_cols   gsc
    where gsc.grid_datasource_name = dataSource;

  l_grid_sort_col_alias1 varchar2(30);
  l_grid_sort_col_alias2 varchar2(30);
  l_grid_sort_col_alias3 varchar2(30);

begin
  open sortCols(dataSource);
  fetch sortCols into l_grid_sort_col_alias1, l_grid_sort_col_alias2, l_grid_sort_col_alias3;
  if sortCols%NOTFOUND then
   /*    close sortCols;

  	handleErrors(MISSING_SORT_COL_ERROR,'repairSortColumns',tableIndex,dataSource,null);
  	return;
    */
    l_grid_sort_col_alias1 := NULL;
    l_grid_sort_col_alias2 := NULL;
    l_grid_sort_col_alias3 := NULL;
  end if;
  close sortCols;
  tableDefs(tableIndex).grid_sort_col_alias1 := l_grid_sort_col_alias1;
  tableDefs(tableIndex).grid_sort_col_alias2 := l_grid_sort_col_alias2;
  tableDefs(tableIndex).grid_sort_col_alias3 := l_grid_sort_col_alias3;
  update jtf_custom_grids
  set grid_sort_col_alias1 = l_grid_sort_col_alias1
     ,grid_sort_col_alias2 = l_grid_sort_col_alias2
     ,grid_sort_col_alias3 = l_grid_sort_col_alias3
  where custom_grid_id = tableDefs(tableIndex).custom_grid_id;
  commit;

exception
  when others then
    rollback;
    raise;
end repairSortColumns;

-- Check that the columnAlias exist in columnDefs
-- if columnAlias is null then we return true no matter what.
procedure validateColumn (gridName   in varchar2
                        ,tableIndex  in binary_integer
                        ,columnAlias in varchar2
                        ,raiseError  in boolean
                        ,errorType   in pls_integer
                        ,caller      in varchar2
                        ,broken      in out nocopy boolean) is
  INVALID_COLUMN exception;
begin
	if columnAlias is null or broken then
		return;
	end if;
	if findColumnDefIndex(gridName,columnAlias) is null then
    broken := true;
  	if raiseError then
		  raise INVALID_COLUMN;
		end if;
	end if;
exception
  when INVALID_COLUMN then
    broken := true;
	  handleErrors(errorType,caller,tableIndex,columnAlias,null);
end validateColumn;

-- Check to see whether the sort columns as defined in tableDefs also
-- exists in columnDefs. This could get corrupted if:
-- 1. The end user sorts on a few columns.
-- 2. Saves the customizations.
-- 3. The columns that the end user sorted on are deleted from the
--    metadata definition.
-- 4. The columndefinition for the column used in the sort order was deleted from
--    JTF_GRID_COLS_B
-- If corrupt we return false, the caller is responsible for calling repairSortColumns
-- to do the dirty work.
procedure validateSortColumns(gridName   in varchar2
                            ,tableIndex in binary_integer
                            ,raiseError in boolean
                            ,broken     in out nocopy boolean) is
  columnAlias        varchar2(30);
begin
  -- If the sort_col_alias is not null, and we get null back from findColumDefIndex
  -- then something is wrong and we need to rectify the situation.
  columnAlias := tableDefs(tableIndex).grid_sort_col_alias1;
 	validateColumn(gridName,tableIndex,columnAlias,raiseError,ILLEGAL_SORT_COLUMN_ERROR,'validateSortColumns',broken);
  columnAlias := tableDefs(tableIndex).grid_sort_col_alias2;
 	validateColumn(gridName,tableIndex,columnAlias,raiseError,ILLEGAL_SORT_COLUMN_ERROR,'validateSortColumns',broken);
  columnAlias := tableDefs(tableIndex).grid_sort_col_alias3;
 	validateColumn(gridName,tableIndex,columnAlias,raiseError,ILLEGAL_SORT_COLUMN_ERROR,'validateSortColumns',broken);
end validateSortColumns;

-- add the sort order to the current stream. Caller is responsible for clearing and
-- retrieving the stream.
procedure serializeSortOrder(gridName             in varchar2
                            ,tableIndex           in binary_integer
                            ,includeSortDirection in boolean) is
  sortCols           integer;
  j                  binary_integer;
  broken             boolean := false;
begin
  -- we check to see that the sort columns are not corrupt.
  -- if we are not using the default metadata definition we try to repair the metadata definition.
	if tableDefs(tableIndex).custom_grid_id is not null then
		-- don't raise an error yet, we may be able to repair the broken defintion
  	validateSortColumns(gridName,tableIndex,false,broken);
    if broken then
      repairSortColumns(gridName,tableIndex,tableDefs(tableIndex).grid_dataSource_name);
    end if;
  end if;
  broken := false;
  -- for non default metadata definitions we now check whether we could repair the metadata, if not
  -- we raise an error.
  -- for detault metadata definitions we check for the first time and immediately raise the error
  -- as there is no hope of repairing the definition.
  validateSortColumns(gridName,tableIndex,true,broken);
  if broken then
  	return;
  end if;

  -- SERIALIZE THE SORTORDER
  -- Serialization requires: number of sorted cols, lowest prio sorted col to highest prio
  sortCols := 0;
  if tableDefs(tableIndex).grid_sort_col_alias1 is not null then
    sortCols := sortCols + 1;
  end if;
  if tableDefs(tableIndex).grid_sort_col_alias2 is not null then
    sortCols := sortCols + 1;
  end if;
  if tableDefs(tableIndex).grid_sort_col_alias3 is not null then
    sortCols := sortCols + 1;
  end if;
  jtf_dbstream_utils.writeInt(sortCols);
  if tableDefs(tableIndex).grid_sort_col_alias3 is not null then
    jtf_dbstream_utils.writeInt(findColumnIndex(gridName,tableDefs(tableIndex).grid_sort_col_alias3) - 1); -- -1 since we need a 0 based index
    if includeSortDirection then
    	j := findColumnDefIndex(gridName,tableDefs(tableIndex).grid_sort_col_alias3);
    	if j is not null then
    	  jtf_dbstream_utils.writeString(columnDefs(j).sort_asc_by_default_flag);
    	else
    		-- redundant, this was checked in validateSortColumns, but for good measure....
    		handleErrors(ILLEGAL_SORT_COLUMN_ERROR,'serializeSortOrder',tableIndex,tableDefs(tableIndex).grid_sort_col_alias3,null);
    	end if;
    end if;
    sortCols := sortCols + 1;
  end if;
  if tableDefs(tableIndex).grid_sort_col_alias2 is not null then
    jtf_dbstream_utils.writeInt(findColumnIndex(gridName,tableDefs(tableIndex).grid_sort_col_alias2) - 1); -- -1 since we need a 0 based index
    if includeSortDirection then
    	j := findColumnDefIndex(gridName,tableDefs(tableIndex).grid_sort_col_alias2);
    	if j is not null then
    	  jtf_dbstream_utils.writeString(columnDefs(j).sort_asc_by_default_flag);
    	else
    		-- redundant, this was checked in validateSortColumns, but for good measure....
    		handleErrors(ILLEGAL_SORT_COLUMN_ERROR,'serializeSortOrder',tableIndex,tableDefs(tableIndex).grid_sort_col_alias2,null);
    	end if;
    end if;
    sortCols := sortCols + 1;
  end if;
  if tableDefs(tableIndex).grid_sort_col_alias1 is not null then
    jtf_dbstream_utils.writeInt(findColumnIndex(gridName,tableDefs(tableIndex).grid_sort_col_alias1) - 1); -- -1 since we need a 0 based index
    if includeSortDirection then
    	j := findColumnDefIndex(gridName,tableDefs(tableIndex).grid_sort_col_alias1);
    	if j is not null then
    	  jtf_dbstream_utils.writeString(columnDefs(j).sort_asc_by_default_flag);
    	else
    		-- redundant, this was checked in validateSortColumns, but for good measure....
    		handleErrors(ILLEGAL_SORT_COLUMN_ERROR,'serializeSortOrder',tableIndex,tableDefs(tableIndex).grid_sort_col_alias1,null);
    	end if;
    end if;
    sortCols := sortCols + 1;
  end if;
  -- END SORTORDER
end serializeSortOrder;

-- Build and return a string representing the serialized form of the spreadtable Meta Data
procedure getSerializedTableDef(gridName     in varchar2
                               ,dataSource   in varchar2
                               ,tableIndex   out nocopy binary_integer
                               ,outPutStream out NOCOPY jtf_dbstream_utils.streamType) is

  INVALID_DATASOURCE exception;
  i                  binary_integer;
  j                  binary_integer;

  sortCols           integer;
  startPos           integer;
  endPos             integer;
begin
  if gridName is null
  or dataSource is null then
    jtf_dbstream_utils.clearOutputStream;
    outPutStream := jtf_dbstream_utils.getLongOutputStream;
    tableIndex := null;
  end if;
  i := findTableDefIndex(gridName);
  if i is null then
  	i := getTableDefFromDB(gridName,dataSource);
  end if;
  if i is null then
  	raise INVALID_DATASOURCE;
  end if;

  jtf_dbstream_utils.clearOutputStream;
  -- SERIALIZE THE TABLEDEF
  jtf_dbstream_utils.writeString(tabVersion);
  -- Boolean to indicate whether the spreadtable is being initialized
  -- using an end users customizations.
  if tableDefs(i).custom_grid_id is null then
  	jtf_dbstream_utils.writeBoolean(false);
  else
  	jtf_dbstream_utils.writeBoolean(true);
  end if;
  -- HACK UP THE COLOR CODE IN THREE PARTS (R,G,B)
  startPos := 1;
  for x in 1..2 loop
  	endPos := instr(tableDefs(i).alt_color_code,',',startPos);
    jtf_dbstream_utils.writeString(substr(tableDefs(i).alt_color_code,startPos,endPos-startPos));
    startPos := endPos + 1;
  end loop;
  jtf_dbstream_utils.writeString(substr(tableDefs(i).alt_color_code,startPos));
  -- END COLOR CODE
  jtf_dbstream_utils.writeInt(tableDefs(i).alt_color_interval);
  jtf_dbstream_utils.writeInt(tableDefs(i).default_row_height);
  jtf_dbstream_utils.writeString(tableDefs(i).title_text);
  jtf_dbstream_utils.writeInt(tableDefs(i).colCount);
  -- END TABLEDEF

  if not isTabColsInMemory(gridName) then
  	getColDefsFromDB(gridName,dataSource,i);
  end if;
  j := findNextColumnDefIndex(gridName,0);

  -- SERIALIZE THE COLDEF
  while j is not null loop
    jtf_dbstream_utils.writeString(colDefVersion);
    jtf_dbstream_utils.writeString(columnDefs(j).grid_col_alias);
    jtf_dbstream_utils.writeInt(columnDefs(j).display_hsize);
    jtf_dbstream_utils.writeString(columnDefs(j).label_text);
    jtf_dbstream_utils.writeString(columnDefs(j).header_alignment_code);
    jtf_dbstream_utils.writeString(columnDefs(j).cell_alignment_code);
    jtf_dbstream_utils.writeString(columnDefs(j).data_type_code);
    jtf_dbstream_utils.writeInt(columnDefs(j).display_index);
    jtf_dbstream_utils.writeString(columnDefs(j).checkbox_checked_value);
    jtf_dbstream_utils.writeString(columnDefs(j).checkbox_unchecked_value);
    jtf_dbstream_utils.writeString(columnDefs(j).checkbox_other_values);
    jtf_dbstream_utils.writeString(columnDefs(j).display_type_code);
    jtf_dbstream_utils.writeString(columnDefs(j).visible_flag);
    jtf_dbstream_utils.writeString(columnDefs(j).freeze_visible_flag);
    jtf_dbstream_utils.writeString(columnDefs(j).sortable_flag);
    jtf_dbstream_utils.writeString(columnDefs(j).sort_asc_by_default_flag);
    j := findNextColumnDefIndex(gridName,j);
  end loop;
  -- END COLDEF

  serializeSortOrder(gridName,i,false);
  -------------------
  -- The code below has been moved to serializeSortOrder
  -------------------

  -- if we are not using the default metadata definition
  -- we check to see that the sort columns are not corrupt.
--  if tableDefs(i).custom_grid_id is not null then
--  	validateSortColumns(gridName,i,dataSource);
--  end if;

  -- SERIALIZE THE SORTORDER
  -- Serialization requires: number of sorted cols, lowest prio sorted col to highest prio
--  sortCols := 0;
--  if tableDefs(i).grid_sort_col_alias1 is not null then
--    sortCols := sortCols + 1;
--  end if;
--  if tableDefs(i).grid_sort_col_alias2 is not null then
--    sortCols := sortCols + 1;
--  end if;
--  if tableDefs(i).grid_sort_col_alias3 is not null then
--    sortCols := sortCols + 1;
--  end if;
--  jtf_dbstream_utils.writeInt(sortCols);
--  if tableDefs(i).grid_sort_col_alias3 is not null then
--    jtf_dbstream_utils.writeInt(findColumnIndex(gridName,tableDefs(i).grid_sort_col_alias3) - 1); -- -1 since we need a 0 based index
--    sortCols := sortCols + 1;
--  end if;
--  if tableDefs(i).grid_sort_col_alias2 is not null then
--    jtf_dbstream_utils.writeInt(findColumnIndex(gridName,tableDefs(i).grid_sort_col_alias2) - 1); -- -1 since we need a 0 based index
--    sortCols := sortCols + 1;
--  end if;
--  if tableDefs(i).grid_sort_col_alias1 is not null then
--    jtf_dbstream_utils.writeInt(findColumnIndex(gridName,tableDefs(i).grid_sort_col_alias1) - 1); -- -1 since we need a 0 based index
--    sortCols := sortCols + 1;
--  end if;
  -- END SORTORDER
  tableIndex   := i;
  outPutStream := jtf_dbstream_utils.getLongOutputStream;
exception
  when INVALID_DATASOURCE then
    handleErrors(INVALID_DATASOURCE_ERROR,'getSerializedTableDef',gridName,dataSource,null);
/*  when OTHERS then
    handleErrors(INTERNAL_ERROR,'getSerializedTableDef',gridName,
    ' dataSource = <'||nvl(dataSource,nullValue)||'>'||lineFeed||
    ' stream = <'||nvl(jtf_dbstream_utils.getOutputStream,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end getSerializedTableDef;


-- Take a serialized stream, deserialize it, and then save it into the database.
-- NOTE: This implementation only supports phase 1 of this functionality
procedure saveSerializedTableDef(gridName     in varchar2
                               ,dataSource   in varchar2
                               ,customGridId in out nocopy number
                               ,customGridName in out nocopy varchar2
                               ,defaultFlag in boolean
                               ,publicFlag  in boolean
                               ,inputStream jtf_dbstream_utils.streamType
                               ,successFlag out nocopy boolean
                               ,p_serverInitDate in date) is

  PRAGMA AUTONOMOUS_TRANSACTION;

  i                  binary_integer;
  j                  binary_integer;

  sortCols            integer;
  startPos            integer;
  endPos              integer;

  l_tabVersion  varchar2(5);
  l_colVersion  varchar2(5);
  l_custom_grid_id       number;
  l_custom_grid_name     varchar2(80);
  l_default_row_height   number(2);
  l_where_clause         varchar2(2000);
  l_grid_sort_col_alias1 varchar2(30);
  l_grid_sort_col_alias2 varchar2(30);
  l_grid_sort_col_alias3 varchar2(30);
  l_public_flag          varchar2(1) := jtf_dbstring_utils.getBooleanString(publicFlag);
  l_grid_col_alias       varchar2(30);
  l_sort_asc_by_default  varchar2(1);
  l_visible_flag         varchar2(1);
  l_display_seq          number(3);
  l_display_hsize        number(6);
  l_label_text           varchar2(80);

  cursor folderColumnExists(x_custom_grid_id       in number
                           ,x_grid_datasource_name in varchar2
                           ,x_grid_col_alias       in varchar2) is
    select label_text
    from   jtf_custom_grid_cols
    where  custom_grid_id       = x_custom_grid_id
    and    grid_datasource_name = x_grid_datasource_name
    and    grid_col_alias       = x_grid_col_alias;

  folder_col_label varchar2(80);
  sortCount integer;
begin
   validateServer(p_serverInitDate, NULL);
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;

  if inputStream.COUNT = 0 then
  	successFlag := false;
   	return;
  elsif inputStream.COUNT = 1 then
  	jtf_dbstream_utils.setInputStream(inputStream(inputStream.FIRST));
  else
  	jtf_dbstream_utils.setLongInputStream(inputStream);
  end if;
  --handleErrors(INTERNAL_ERROR,'saveSerializedTableDef',gridName,inputStream(inputStream.FIRST),to_char(inputStream.COUNT));

  l_tabVersion    := jtf_dbstream_utils.readString;
  -- this is the current version
  if l_tabVersion = clientTabVersion then
    l_default_row_height   := jtf_dbstream_utils.readInt;
    l_custom_grid_name     := nvl(customGridName,USER_UI_DEFAULT_FOLDER); -- Use the default name until phase 2.

    sortCount              := jtf_dbstream_utils.readInt;
    -- Something really fishy has happened, we should always have one sort column.
    if sortCount = 0 then
      l_grid_sort_col_alias1 := tableDefs(i).grid_sort_col_alias1;
    end if;
    if sortCount > 0 then
      l_grid_sort_col_alias1 := findColumnAlias(gridName,(jtf_dbstream_utils.readInt + 1)); -- +1 since this is coming from
    end if;
    if sortCount > 1 then
      l_grid_sort_col_alias2 := findColumnAlias(gridName,(jtf_dbstream_utils.readInt + 1)); -- the client which uses 0 based
    end if;
    if sortCount > 2 then
      l_grid_sort_col_alias3 := findColumnAlias(gridName,(jtf_dbstream_utils.readInt + 1)); -- indexes
    end if;
    l_where_clause         := null; -- null for now, only use the default.


    -- the folder already exists
    -- NOTE: For phase 2 we need a lot of checks here, phase 1 we only
    --       support one set of customizations / user and datasource
    --
    if tableDefs(i).custom_grid_id is null
    and customGridId is null then

      select jtf_custom_grids_s.nextval
      into   l_custom_grid_id
      from   dual;

      insert into jtf_custom_grids
        (custom_grid_id
        ,grid_datasource_name
        ,custom_grid_name
        ,language
        ,grid_sort_col_alias1
        ,grid_sort_col_alias2
        ,grid_sort_col_alias3
        ,public_flag
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,where_clause
        )
      values
        (l_custom_grid_id
        ,datasource
        ,l_custom_grid_name
        ,userenv('LANG')
        ,l_grid_sort_col_alias1
        ,l_grid_sort_col_alias2
        ,l_grid_sort_col_alias3
        ,l_public_flag
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.login_id
        ,l_where_clause
        );

      -- NOTE: This will have to change for phase 2
      insert into jtf_def_custom_grids
        (grid_datasource_name
        ,created_by
        ,creation_date
        ,last_updated_by
        ,last_update_date
        ,last_update_login
        ,custom_grid_id
        ,language
        )
      values
        (datasource
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.login_id
        ,l_custom_grid_id
        ,userenv('LANG')
        );
    else
    	-- NOTE: For phase 2 we need several checks here
    	if customGridId is null then
    	  l_custom_grid_id := tableDefs(i).custom_grid_id;
    	else
    		l_custom_grid_id := customGridId;
    	end if;
      update jtf_custom_grids
      set custom_grid_name     = l_custom_grid_name
         ,grid_sort_col_alias1 = l_grid_sort_col_alias1
         ,grid_sort_col_alias2 = l_grid_sort_col_alias2
         ,grid_sort_col_alias3 = l_grid_sort_col_alias3
         ,public_flag          = l_public_flag
         ,last_updated_by      = fnd_global.user_id
         ,last_update_date     = sysdate
         ,last_update_login    = fnd_global.login_id
         ,where_clause         = l_where_clause
      where custom_grid_id = l_custom_grid_id;
    end if;
    -- also update the information we hold in tableDefs
    tableDefs(i).custom_grid_id       := l_custom_grid_id;
    tableDefs(i).custom_grid_name     := l_custom_grid_name;
    tableDefs(i).grid_sort_col_alias1 := l_grid_sort_col_alias1;
    tableDefs(i).grid_sort_col_alias2 := l_grid_sort_col_alias2;
    tableDefs(i).grid_sort_col_alias3 := l_grid_sort_col_alias3;
    tableDefs(i).public_flag          := l_public_flag;
    tableDefs(i).owner                := fnd_global.user_id;
  end if;

  -- END TABLEDEF
  -- DESERIALIZE THE COLDEF
  for k in 1..tableDefs(i).colCount loop
    l_colVersion := jtf_dbstream_utils.readString;
    if l_colVersion = clientColDefVersion then
    	l_grid_col_alias      := jtf_dbstream_utils.readString;
      l_display_hsize       := jtf_dbstream_utils.readInt;
      l_label_text          := jtf_dbstream_utils.readString;
      l_display_seq         := jtf_dbstream_utils.readInt;
      l_visible_flag        := jtf_dbstream_utils.readString;
      l_sort_asc_by_default := jtf_dbstream_utils.readString;

      open folderColumnExists(l_custom_grid_id,datasource,l_grid_col_alias);
      fetch folderColumnExists into folder_col_label;

      j := findColumnDefIndex(gridName,l_grid_col_alias);

      -- We don't save the label if it hasn't changed
      if  folder_col_label is null
      and l_label_text = columnDefs(j).label_text then
        l_label_text := null;
      end if;

      if folderColumnExists%NOTFOUND then
        close folderColumnExists;
       	insert into jtf_custom_grid_cols
       	  (custom_grid_id
        	,grid_datasource_name
        	,grid_col_alias
        	,sort_asc_by_default_flag
        	,visible_flag
        	,display_seq
        	,display_hsize
        	,created_by
        	,creation_date
        	,last_updated_by
        	,last_update_date
        	,last_update_login
        	,label_text
        	)
        values
          (l_custom_grid_id
        	,datasource
        	,l_grid_col_alias
        	,l_sort_asc_by_default
        	,l_visible_flag
        	,l_display_seq
        	,l_display_hsize
        	,fnd_global.user_id
        	,sysdate
        	,fnd_global.user_id
        	,sysdate
        	,fnd_global.login_id
        	,l_label_text
        	);
      else
        close folderColumnExists;
       	update jtf_custom_grid_cols
       	set sort_asc_by_default_flag = l_sort_asc_by_default
        	 ,visible_flag             = l_visible_flag
        	 ,display_seq              = l_display_seq
        	 ,display_hsize            = l_display_hsize
        	 ,last_updated_by          = fnd_global.user_id
        	 ,last_update_date         = sysdate
        	 ,last_update_login        = fnd_global.login_id
        	 ,label_text               = l_label_text
        where custom_grid_id       = l_custom_grid_id
        and   grid_datasource_name = dataSource
        and   grid_col_alias       = l_grid_col_alias;
      end if;
    end if;
    columnDefs(j).sort_asc_by_default_flag := l_sort_asc_by_default;
    columnDefs(j).visible_flag             := l_visible_flag;
    columnDefs(j).display_index            := l_display_seq;
    columnDefs(j).display_hsize            := l_display_hsize;
    columnDefs(j).label_text               := l_label_text;
  end loop;
  -- END COLDEF
  commit;
  customGridId   := l_custom_grid_id;
  customGridName := l_custom_grid_name;
  successFlag    := true;
exception
  when INVALID_GRID then
    rollback;
    successFlag := false;
    handleErrors(INVALID_GRID_ERROR,'saveSerializedTableDef',gridName,null,null);
  when OTHERS then
   handleErrors(INTERNAL_ERROR,'saveSerializedTableDef',gridName,null,SQLERRM);
    rollback;
    successFlag := false;
--    handleErrors(INTERNAL_ERROR,'saveSerializedTableDef',gridName,
--    ' dataSource     = <'||nvl(dataSource,nullValue)||'>'||lineFeed||
--    ' custom_grid_id = <'||nvl(to_char(l_custom_grid_id),nullValue)||'>'||lineFeed||
--    ' custom_grid_name = <'||nvl(l_custom_grid_name,nullValue)||'>'||lineFeed||
--    ' default_flag = <'||nvl(jtf_dbstring_utils.getBooleanString(defaultFlag),nullValue)||'>'||lineFeed||
--    ' public_flag = <'||nvl(l_public_flag,nullValue)||'>'||lineFeed
--    null,SQLERRM);
--    return false;
end saveSerializedTableDef;


-- Delete the given set of customizations. Remove all references to it
-- from JTF_DEF_CUSTOM_GRIDS.
-- If customGridId is null we delete the current set.
function deleteCustomizations(gridName    in varchar2
                             ,customGridId in number
                             ,p_serverInitDate in date) return boolean is

  PRAGMA AUTONOMOUS_TRANSACTION;
  i binary_integer;
  l_custom_grid_id number;
begin
   validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;
	if customGridId is null
  and tableDefs(i).custom_grid_id is null then
		return true;
	end if;
	-- If customGridId is null we delete the current set.
	l_custom_grid_id := nvl(customGridId,tableDefs(i).custom_grid_id);
	delete from jtf_def_custom_grids
	where  custom_grid_id = l_custom_grid_id;
	delete from jtf_custom_grid_cols
	where  custom_grid_id = l_custom_grid_id;
	delete from jtf_custom_grids
	where  custom_grid_id = l_custom_grid_id;
	tableDefs(i).custom_grid_id := null;
	tableDefs(i).custom_grid_name := null;
	tableDefs(i).public_flag := null;
	tableDefs(i).owner := null;
	commit;
	return true;
exception
  when INVALID_GRID then
    rollback;
    handleErrors(INVALID_GRID_ERROR,'deleteCustomizations',gridName,null,null);
  when others then
   handleErrors(INTERNAL_ERROR,'saveSerializedTableDef',gridName,null,SQLERRM);
    rollback;
    return false;
end deleteCustomizations;


-- Set the new sort orders, and then refresh the grid
procedure setSortCol(gridName       in varchar2
                      ,col_alias1     in varchar2
                      ,sort_asc_flag1 in varchar2
                      ,col_alias2     in varchar2
                      ,sort_asc_flag2 in varchar2
                      ,col_alias3     in varchar2
                      ,sort_asc_flag3 in varchar2
                      ,p_serverInitDate in date)  is

  oldDataSource    varchar2(30);
  i                binary_integer;
  j                binary_integer;
begin
        validateServer(p_serverInitDate, gridName);
	i := findTableDefIndex(gridName);
	if i is null then
		raise INVALID_GRID;
	end if;
  tableDefs(i).grid_sort_col_alias1 := col_alias1;
	tableDefs(i).grid_sort_col_alias2 := col_alias2;
	tableDefs(i).grid_sort_col_alias3 := col_alias3;
  -- CURSOR MGMT REWRITE
  tableDefs(i).hasWhereClauseChanged := 'T';
  -- CURSOR MGMT REWRITE END
  if col_alias1 is not null
  and sort_asc_flag1 is not null then
    j := findColumnDefIndex(gridName,col_alias1);
    if j is not null then
      columnDefs(j).sort_asc_by_default_flag := sort_asc_flag1;
    end if;
  end if;
  if col_alias2 is not null
  and sort_asc_flag2 is not null then
    j := findColumnDefIndex(gridName,col_alias2);
    if j is not null then
      columnDefs(j).sort_asc_by_default_flag := sort_asc_flag2;
    end if;
  end if;
  if col_alias3 is not null
  and sort_asc_flag3 is not null then
    j := findColumnDefIndex(gridName,col_alias3);
    if j is not null then
      columnDefs(j).sort_asc_by_default_flag := sort_asc_flag3;
    end if;
  end if;

  refresh(gridName, i);

exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'setSortCol',gridName,null,null);
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'setSortCol',gridName,
    ' col_alias1 = <'||nvl(col_alias1,nullValue)||'>'||lineFeed||
    ' sort_asc_flag1 = <'||nvl(sort_asc_flag1,nullValue)||'>'||lineFeed||
    ' col_alias2 = <'||nvl(col_alias2,nullValue)||'>'||lineFeed||
    ' sort_asc_flag2 = <'||nvl(sort_asc_flag2,nullValue)||'>'||lineFeed||
    ' col_alias3 = <'||nvl(col_alias3,nullValue)||'>'||lineFeed||
    ' sort_asc_flag3 = <'||nvl(sort_asc_flag3,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end setSortCol;

procedure deleteColDef(gridName in varchar2) is
  i binary_integer;
begin
	i := findNextColumnDefIndex(gridName,0);
  if i is null then
		return;
	end if;

  while i is not null loop
 	  columnDefs.delete(i);
  	i := findNextColumnDefIndex(gridName,i);
  end loop;
/*
exception
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'deleteColDef',gridName,null,SQLERRM);
*/
end deleteColDef;



procedure reset(gridName in varchar2, tableIndex in binary_integer) is
begin
  if tableIndex is null then
  	raise INVALID_GRID;
  end if;

  -- If the package is has already been
  -- used to retrive data, reset it to
  -- its initial state
  --if  tableDefs(tableIndex).moreRowsExists = 'T'
-- 4282028
  if  tableDefs(tableIndex).SQLCursor is not null
  and dbms_sql.is_open(tableDefs(tableIndex).SQLCursor) then
    dbms_sql.close_cursor(tableDefs(tableIndex).SQLCursor);
  end if;

  -- if this function is being called then it passes server validation
  -- ideally this procedure/function should be called after remove all bind
  -- variables
  removeAllBindVariables(gridName, serverInitDate);

  tableDefs.delete(tableIndex);
  deleteColDef(gridName);

exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'reset',gridName,null,null);
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'reset',gridName,null,SQLERRM);
*/
end reset;


procedure reset(gridName in varchar2, p_serverInitDate in date) is
  i binary_integer;
begin
  validateServer(p_serverInitDate, gridName);

  i := findTableDefIndex(gridName);
  reset(gridName, i);
end reset;

procedure init(gridName       in varchar2
             ,dataSource     in varchar2
             ,customGridId   in out nocopy number
             ,customGridName in out nocopy varchar2
             ,outPutStream   out nocopy jtf_dbstream_utils.streamType
             ,x_serverInitDate out nocopy date ) is
  i binary_integer;
begin
  x_serverInitDate := serverInitDate;
  --dbms_output.put_line(to_char(x_serverInitDate, 'HH:MI:SS')|| 'sysdate is ' ||to_char(sysdate, 'HH:MI:SS'));
  i := findTableDefIndex(gridName);
  if i is not null then
    reset(gridName,i);
  end if;
  getSerializedTableDef(gridName,dataSource,i,outPutStream);
  customGridId   := tableDefs(i).custom_grid_id;
  customGridName := tableDefs(i).custom_grid_name;
/*
exception
  when OTHERS then
    handleErrors(INIT_ERROR,'init',gridName,
    ' dataSource = <'||nvl(dataSource,nullValue)||'>'||lineFeed
    ,SQLERRM);
*/
end init;

-------------------------------------------------------------------------
procedure refresh(gridName in varchar2, p_serverInitDate in date) is
  i             binary_integer;
begin
        validateServer(p_serverInitDate, gridName);
	i := findTableDefIndex(gridName);
	if i is null then
		raise INVALID_GRID;
	end if;
  refresh(gridName,i);
exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'refresh',gridName,null,null);
/*
  when OTHERS then
    handleErrors(INTERNAL_ERROR,'refresh',gridName,null,SQLERRM);
*/
end refresh;


function  getWhereClause(gridName in varchar2, p_serverInitDate in date) return varchar2 is
  i binary_integer;
begin
  validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;
  return tableDefs(i).where_clause;
exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'getWhereClause',gridName,null,null);
end  getWhereClause;

procedure setWhereClause(gridName in varchar2, whereClause in varchar2
                        ,p_serverInitDate in date) is
  i binary_integer;
begin
  validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;
  -- If the whereclause hasn't changed, do nothing
  if  (tableDefs(i).where_clause is null
  and whereClause is null)
  or (tableDefs(i).where_clause is not null
  and whereClause is not null
  and tableDefs(i).where_clause = whereClause) then
    null;
  -- Otherwise, set the new whereclause and the flag
  -- indicating that things has changed and need reparsing
  else
    tableDefs(i).where_clause := whereClause;
    tableDefs(i).hasWhereClauseChanged := 'T';
  end if;
  refresh(gridName,i);
exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'setWhereClause',gridName,null,null);
end  setWhereClause;

function  getSQLStatement(gridName in varchar2 ,p_serverInitDate in date) return varchar2 is
  i binary_integer;
begin
  validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;
  return tableDefs(i).SQLStatement;
exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'getSQLStatement',gridName,null,null);
end getSQLStatement;

-- CURSOR MGMT REWRITE
procedure setHasBindVarsChanged(gridName in varchar2) is
  i binary_integer;
begin
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;
  tableDefs(i).hasBindVarsChanged := 'T';
exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'setHasBindVariablesChanged',gridName,null,null);
end setHasBindVarsChanged;
-- CURSOR MGMT REWRITE END

procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in varchar2) is
  i binary_integer;
begin
  i := findBindVariableIndex(gridName, variableName);
	bindVariables(i).gridName := gridName;
	bindVariables(i).variableName := variableName;
	bindVariables(i).variableDataType := 'C';
	bindVariables(i).variableCharValue := variableValue;
        bindVariables(i).variableDateValue := null;
        bindVariables(i).variableNumberValue := null;
  -- CURSOR MGMT REWRITE
  setHasBindVarsChanged(gridName);
  -- CURSOR MGMT REWRITE END

end setBindVariable;

procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in varchar2 ,p_serverInitDate in date) is
begin
  validateServer(p_serverInitDate, gridName);
  setBindVariable(gridName, variableName, variableValue);
end setBindVariable;


procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in date) is
  i binary_integer;
begin
  i := findBindVariableIndex(gridName, variableName);
	bindVariables(i).gridName := gridName;
	bindVariables(i).variableName := variableName;
	bindVariables(i).variableDataType := 'D';
	bindVariables(i).variableDateValue := variableValue;
        bindVariables(i).variableCharValue := null;
        bindVariables(i).variableNumberValue := null;
  -- CURSOR MGMT REWRITE
  setHasBindVarsChanged(gridName);
  -- CURSOR MGMT REWRITE END
end setBindVariable;

procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in date, p_serverInitDate in date) is
begin
  validateServer(p_serverInitDate, gridName);
  setBindVariable(gridName, variableName, variableValue);
end setBindVariable;



procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in number) is
  i binary_integer;
begin
  i := findBindVariableIndex(gridName, variableName);
	bindVariables(i).gridName := gridName;
	bindVariables(i).variableName := variableName;
	bindVariables(i).variableDataType := 'N';
	bindVariables(i).variableNumberValue := variableValue;
        bindVariables(i).variableDateValue := null;
        bindVariables(i).variableCharValue := null;

  -- CURSOR MGMT REWRITE
  setHasBindVarsChanged(gridName);
  -- CURSOR MGMT REWRITE END
end setBindVariable;

procedure setBindVariable(gridName in varchar2, variableName in varchar2, variableValue in number, p_serverInitDate in date) is
begin
  validateServer(p_serverInitDate, gridName);
  setBindVariable(gridName, variableName, variableValue);
end setBindVariable;

function getCharBindVariableValue(gridName in varchar2, variableName in varchar2,p_serverInitDate in date) return varchar2 is
  i        binary_integer;
  bind_val varchar2(10) := NULL;
begin
  validateServer(p_serverInitDate, gridName);
  i := findBindVariableIndex(gridName, variableName);

-- if the bind variable does not exist then one is created.
-- if it exists but is not of type character then raise an error.

  IF not bindVariables.EXISTS(i) THEN
       setBindVariable(gridName, variableName, bind_val);
       return bind_val;

  ELSIF  bindVariables(i).variableDataType <> 'C' THEN

       handleErrors(APPLICATION_ERROR, 'getCharBindVariableValue', gridName,
       'Bind Variable '||replace(variableName,':')|| ' of type Char does not exist'||linefeed, null);

  end if;
  return bindVariables(i).variableCharValue;

/*  08/24 this procedure returns error if the bind variable is not found
  -- CURSOR MGMT REWRITE
  if not bindVariables.EXISTS(i) then
    setHasBindVarsChanged(gridName);
  end if;
  -- CURSOR MGMT REWRITE END

  -- this might be a new one, so assign the proper values just in case, and return the value
	bindVariables(i).gridName := gridName;
	bindVariables(i).variableName := variableName;
	bindVariables(i).variableDataType := 'C';
	return bindVariables(i).variableCharValue;
*/
end getCharBindVariableValue;

function getDateBindVariableValue(gridName in varchar2, variableName in varchar2,p_serverInitDate in date) return date is
  i binary_integer;
  bind_val date;
begin
  validateServer(p_serverInitDate, gridName);
  i := findBindVariableIndex(gridName, variableName);

-- if the bind variable does not exist then one is created.
-- if it exists but is not of type date then raise an error.

    if not bindVariables.EXISTS(i) then
         setBindVariable(gridName, variableName, bind_val);
         return bind_val;

    elsif bindVariables(i).variableDataType <> 'D' then

       handleErrors(APPLICATION_ERROR, 'getDateBindVariableValue',i ,
      'Bind Variable '||replace(variableName,':')|| ' of type Date does not exist'
       ||linefeed,null);

    end if;

  return bindVariables(i).variableDateValue;

/* 08/24 this procedure returns error if the bind variable is not found
  -- CURSOR MGMT REWRITE
  if not bindVariables.EXISTS(i) then
    setHasBindVarsChanged(gridName);
  end if;
  -- CURSOR MGMT REWRITE END


  -- this might be a new one, so assign the proper values just in case, and return the value
	bindVariables(i).gridName := gridName;
	bindVariables(i).variableName := variableName;
	bindVariables(i).variableDataType := 'D';
	return bindVariables(i).variableDateValue;
*/
end getDateBindVariableValue;

function getNumberBindVariableValue(gridName in varchar2, variableName in varchar2,p_serverInitDate in date) return number is
  i binary_integer;
  bind_val number;
begin
    validateServer(p_serverInitDate, gridName);
    i := findBindVariableIndex(gridName, variableName);

 -- if the bind variable does not exist then one is created.
 -- if it exists but is not of type number then raise an error.

   if not bindVariables.EXISTS(i) then
         setBindVariable(gridName, variableName, bind_val);
         return bind_val;

   elsif bindVariables(i).variableDataType <> 'N' then

        handleErrors(APPLICATION_ERROR, 'getNumberBindVariableValue', gridName,
      'Bind Variable '||replace(variableName,':')|| ' of type Integer does not exist'||linefeed, null);

  end if;

  return bindVariables(i).variableNumberValue;

  /* this procedure returns error if the bind variable is not found 08/24
  -- CURSOR MGMT REWRITE
  if not bindVariables.EXISTS(i) then
    setHasBindVarsChanged(gridName);
  end if;
  -- CURSOR MGMT REWRITE END


  -- this might be a new one, so assign the proper values just in case, and return the value
	bindVariables(i).gridName := gridName;
	bindVariables(i).variableName := variableName;
	bindVariables(i).variableDataType := 'N';
	return bindVariables(i).variableNumberValue;
*/
end getNumberBindVariableValue;

procedure removeAllBindVariables(gridName in varchar2) is
  i binary_integer;
begin
  i := findNextBindVariable(gridName, null);
  while i is not null loop
  	bindVariables.DELETE(i);
    i := findNextBindVariable(gridName, i);
  end loop;
  -- CURSOR MGMT REWRITE
  setHasBindVarsChanged(gridName);
  -- CURSOR MGMT REWRITE END

end removeAllBindVariables;


procedure removeAllBindVariables(gridName in varchar2,p_serverInitDate in date) is
begin
  validateServer(p_serverInitDate, gridName);
  removeAllBindVariables(gridName);
end removeAllBindVariables;

function  getCharProperty(gridName in varchar2, propertyType in varchar2, p_serverInitDate in date) return varchar2 is
  i binary_integer;
  j binary_integer;
begin
   validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
  	raise INVALID_GRID;
  end if;
	if propertyType = 'TITLE_TEXT' then
    return tableDefs(i).title_text;
	elsif propertyType = 'SERIALIZED_SORT_ORDER' then
		jtf_dbstream_utils.clearOutputStream;
		serializeSortOrder(gridName,i,true);
		-- we can safely do this as there is no way the stream can exceed 32k
		return jtf_dbstream_utils.getOutputStream;

        elsif propertyType = 'ALL_BIND_VARIABLES' then

            jtf_dbstream_utils.clearOutputStream;
            -- the first value will be the number of bind variables that are
            -- being passed.

              jtf_dbstream_utils.writeNumber(bindVariablesCount(gridName));

            if bindVariables.COUNT <> 0 then
               j := findNextBindVariable(gridName,null);

    	   	while j is not null loop
             		jtf_dbstream_utils.writeString(bindVariables(j).variableName);
             		jtf_dbstream_utils.writeString(bindVariables(j).variableDataType);
                  if bindVariables(j).variableDataType  = 'C' then
           		jtf_dbstream_utils.writeString(bindVariables(j).variableCharValue);
                  elsif  bindVariables(j).variableDataType = 'N' then
                        jtf_dbstream_utils.writeNumber(bindVariables(j).variableNumberValue);
                  elsif bindVariables(j).variableDataType  = 'D' then
                        jtf_dbstream_utils.writeDateTime(bindVariables(j).variableDateValue);
                  end if;

                  j := findNextBindVariable(gridName,j);

               end loop;
              end if;
                if jtf_dbstream_utils.isLongOutputStream then
  		       handleErrors(MAXLENGTH_EXCEEDED_ERROR,'getCharProperty',
			gridName,' Get all bind variables'||lineFeed,null);
  		end if;
              return jtf_dbstream_utils.getOutputStream;

	else
		raise INVALID_PROPERTY;
	end if;
	return null;
exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'getCharProperty',gridName,null,null);
  when INVALID_PROPERTY then
    handleErrors(INVALID_PROPERTY_ERROR,'getCharProperty',gridName,
    ' propertyType = <'||nvl(propertyType,nullValue)||'>'||lineFeed
    ,null);
end getCharProperty;

procedure setCharProperty(gridName in varchar2, propertyType in varchar2, propertyValue in varchar2, p_serverInitDate in date) is
begin
	null;
end setCharProperty;

---
-- return a collection of all columndefinitions for the given grid
---
function  getColumnDefs(gridName in varchar2, p_serverInitDate in date) return colDefTabType is
  colDef colDefTabType;
  i      binary_integer;
begin
   validateServer(p_serverInitDate, gridName);
  i := findNextColumnDefIndex(gridName,0);
  while i is not null loop
    colDef(nvl(colDef.LAST,0)+1) := columnDefs(i);
    i := findNextColumnDefIndex(gridName,i);
  end loop;
  return colDef;
end getColumnDefs;

----------------------------------------------------------------------
/** Fuction getVersion returns the header information for this file */
FUNCTION getVersion RETURN VARCHAR2 IS
BEGIN
   RETURN('$Header: JTFGRDDB.pls 120.2 2006/01/19 03:14:44 snellepa ship $');
END;

-----------------------------------------------------------------------
procedure addGridInfo(p_gridIndex  IN NUMBER,
                      l_debug_tbl IN OUT NOCOPY JTF_DEBUG_PUB.debug_tbl_type)
IS
  i          number;
  bind_count number;
  l_len_sql  number;
  len        number := 1;
  sql_statement jtf_dbstring_utils.maxString%TYPE;
  whereClause varchar2(4000);
  k          binary_integer;
  bind_var   binary_integer;

BEGIN

  i := l_debug_tbl.count;
     i := i + 1;
  l_debug_tbl(i).debug_message := ' ';
     i := i + 1;
  l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('GRID INDEX',
                                       p_gridIndex);
     i := i + 1;
  l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('GRID NAME',
                                       TableDefs(p_gridIndex).gridName);
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('TITLE TEXT',
                                       TableDefs(p_gridIndex).title_text);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('DATASOURCE',
                                       TableDefs(p_gridIndex).grid_datasource_name);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('DB VIEW NAME',
                                       TableDefs(p_gridIndex).db_view_name);

   l_len_sql := length(TableDefs(p_gridIndex).SQLStatement);
   sql_statement := TableDefs(p_gridIndex).SQLStatement;
           i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('LAST SQL STATEMENT',substr(sql_statement,len, JTF_DEBUG_PUB.FILE_LINESIZE - JTF_DEBUG_PUB.pad_length));
      len := len + (JTF_DEBUG_PUB.FILE_LINESIZE - JTF_DEBUG_PUB.pad_length);

     while l_len_sql > len loop
      i := i + 1;
      l_debug_tbl(i).debug_message := substr(sql_statement,len, JTF_DEBUG_PUB.FILE_LINESIZE);
      len := len + JTF_DEBUG_PUB.FILE_LINESIZE;
     end loop;

      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('SQL CURSOR',
                                      TableDefs(p_gridIndex).SQLCursor);
       i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('REFRESH FLAG',
                                      TableDefs(p_gridIndex).refreshFlag);
 -- where clause also greater than the fileline size
   len := 1;
   whereClause := TableDefs(p_gridIndex).where_clause;
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('CURRENT WHERE CLAUSE', substr(whereClause,len,JTF_DEBUG_PUB.FILE_LINESIZE - JTF_DEBUG_PUB.PAD_LENGTH));
    len := len + (JTF_DEBUG_PUB.FILE_LINESIZE - JTF_DEBUG_PUB.pad_length);

     while (length(whereClause) > len) loop
       i := i + 1;
       l_debug_tbl(i).debug_message := substr(whereClause,len, JTF_DEBUG_PUB.FILE_LINESIZE);
       len := len + JTF_DEBUG_PUB.FILE_LINESIZE;
     end loop;

      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('WHERE CLAUSE CHANGED', TableDefs(p_gridIndex).hasWhereClauseChanged);
      i := i + 1;
   bind_count := bindVariablesCount(TableDefs(p_gridIndex).gridName);
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('BIND VARIABLES COUNT', bind_count);

     if bind_count > 0 then
       bind_var := bindVariables.FIRST;
       while bind_var is not NULL LOOP
            if bindVariables(bind_var).gridName
                     = TableDefs(p_gridIndex).gridName then
               i := i + 1;
   l_debug_tbl(i).debug_message := ' ';
              i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('BIND NAME'), bindVariables(bind_var).variableName);
               i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('BIND TYPE'), bindVariables(bind_var).variableDataType);
               i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('CHAR BIND VALUE'), bindVariables(bind_var).variableCharValue);
               i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatDate(JTF_DEBUG_PUB.FormatIndent('DATE BIND VALUE'), bindVariables(bind_var).variableDateValue);
               i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber(JTF_DEBUG_PUB.FormatIndent('NUMBER BIND VALUE'), bindVariables(bind_var).variableNumberValue);

            end if;
            bind_var := bindVariables.NEXT(bind_var);
        END LOOP;
     end if;
      i := i + 1;
   l_debug_tbl(i).debug_message := 'SORT COLUMNS';
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('SORT COLUMN1'),
                                       TableDefs(p_gridIndex).grid_sort_col_alias1);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('SORT COLUMN2'),
                                       TableDefs(p_gridIndex).grid_sort_col_alias2);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('SORT COLUMN3'),
                                       TableDefs(p_gridIndex).grid_sort_col_alias3);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('FETCH SIZE',
                                       getFetchSize);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('MORE ROWS EXIST',
                                    TableDefs(p_gridIndex).moreRowsExists);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('CURRENT ROW COUNT',
                                      TableDefs(p_gridIndex).rowCount);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('COLUMN COUNT',
                                      TableDefs(p_gridIndex).colCount);
      i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('LINES OF TEXT PER ROW',
                                      TableDefs(p_gridIndex).default_row_height);
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('CUSTOM GRID ID',
                                      TableDefs(p_gridIndex).custom_grid_id);
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('CUSTOM GRID NAME',
                                      TableDefs(p_gridIndex).custom_grid_name);
       i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber('CUSTOM GRID OWNER',
                                      TableDefs(p_gridIndex).owner);
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar('PUBLIC FLAG',
                                      TableDefs(p_gridIndex).public_flag);
      i := i + 1;
     l_debug_tbl(i).debug_message := ' ';
     i := i + 1;
     l_debug_tbl(i).debug_message := 'COLUMN INFORMATION FOR GRID '||TableDefs(p_gridIndex).gridname;

     k := columndefs.FIRST;
     while k is not NULL LOOP
       if columndefs(k).gridname = TableDefs(p_gridIndex).gridname then
            i := i + 1;
         l_debug_tbl(i).debug_message := ' ';
            i := i + 1;
        l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('COLUMN INDEX'), k);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('GRID COL ALIAS'), columndefs(k).grid_col_alias);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DB COL ALIAS'), columndefs(k).db_col_name);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DATA TYPE CODE'), columndefs(k).data_type_code);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber(JTF_DEBUG_PUB.FormatIndent('QUERY SEQ'), columndefs(k).query_seq);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('SORTABLE FLAG'), columndefs(k).sortable_flag);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('VISIBLE FLAG'), columndefs(k).visible_flag);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('FREEZE VISIBLE STATE'), columndefs(k).freeze_visible_flag);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber(JTF_DEBUG_PUB.FormatIndent('DISPLAY INDEX'), columndefs(k).display_index);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DISPLAY TYPE'), columndefs(k).display_type_code);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DISPLAY FORMAT TYPE'), columndefs(k).display_format_type_code);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatNumber(JTF_DEBUG_PUB.FormatIndent('DISPLAY WIDTH'), columndefs(k).display_hsize);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('HEADER ALIGNMENT '), columndefs(k).header_alignment_code);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('CELL ALIGNMENT'), columndefs(k).cell_alignment_code);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DISPLAY FORMAT MASK'), columndefs(k).display_format_mask);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('CHECK BOX CHECKED VALUE'), columndefs(k).checkbox_checked_value);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('CHECK BOX UNCHECKED VALUE'), columndefs(k).checkbox_unchecked_value);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('CHECK BOX OTHER VALUE'), columndefs(k).checkbox_other_values);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DB CURRENCY CODE COL'), columndefs(k).db_currency_code_col);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('DB CURRENCY COL ALIAS'), columndefs(k).db_currency_col_alias);
           i := i + 1;
         l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatChar(JTF_DEBUG_PUB.FormatIndent('LABEL TEXT'), columndefs(k).label_text);

    end if;
    k := columnDefs.NEXT(k);
  end loop;

END addGridInfo;


-------------------------------------------------------------------------------
procedure debug(p_debug_tbl IN JTF_DEBUG_PUB.debug_tbl_type
                              := JTF_DEBUG_PUB.G_MISS_DEBUG_TBL,
                p_gridname  		IN VARCHAR2 := NULL,
                x_path                  OUT NOCOPY varchar2,
                x_filename 	 OUT NOCOPY varchar2,
                X_Return_Status         OUT NOCOPY  VARCHAR2,
  		X_Msg_Count             OUT NOCOPY  NUMBER,
  		X_Msg_Data              OUT NOCOPY  VARCHAR2) IS

  l_debug_tbl  JTF_DEBUG_PUB.debug_tbl_type;
  i            number := 1;
  j            binary_integer := 0;
  k            binary_integer := 1;
  all_info     binary_integer := 1;
  all_info_IDX number;

BEGIN

   /** Adding server information to the local debug table */

  if fnd_log.test(FND_LOG.LEVEL_EVENT, 'JTF.GRID.PLSQL.JTFGRDDB.DEBUG.GLOBAL.SERVER') then
   l_debug_tbl(i).debug_message := 'SERVER INFORMATION';
     i := i + 1;
   l_debug_tbl(i).debug_message := ' ';
     i := i + 1;
   l_debug_tbl(i).debug_message := 'SOURCE CODE INFORMATION';
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_GRIDDB.getVersion;
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DBSTRING_UTILS.getVersion;
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DBSTREAM_UTILS.getVersion;
     i := i + 1;
   l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.getVersion;
       i := i + 1;
   l_debug_tbl(i).debug_message := ' ';
       i := i + 1;
   l_debug_tbl(i).debug_message := 'GRID NAMES AND DATASOURCES';

   k := TableDefs.FIRST;
   WHILE k is not NULL LOOP
     i := i + 1;
     l_debug_tbl(i).debug_message
         := JTF_DEBUG_PUB.FormatChar(TableDefs(k).gridName,
                                     TableDefs(k).grid_datasource_name);
     k := TableDefs.NEXT(k);
   END LOOP;

     i := i + 1;
   l_debug_tbl(i).debug_message := ' ';

   For IDX in 1..l_debug_tbl.count LOOP
     l_debug_tbl(IDX).module_name
              := 'JTF.GRID.PLSQL.JTFGRDDB.DEBUG.GLOBAL.SERVER';
   END LOOP;

  end if; --source

-- current grid information
 if fnd_log.test(FND_LOG.LEVEL_EVENT, 'JTF.GRID.PLSQL.JTFGRDDB.DEBUG.CURRENT.SERVER') then
   all_info_IDX := l_debug_tbl.count + 1;
   if p_gridName is not NULL then
     i := i + 1;
    l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatSeperator;
     i := i + 1;
    l_debug_tbl(i).debug_message := 'CURRENT GRID INFORMATION';

    j := findTableDefIndex(p_gridName);
     if j is not null then
         addGridInfo(j, l_debug_tbl);
     end if;
    end if;

   For IDX in all_info_IDX..l_debug_tbl.count LOOP
     l_debug_tbl(IDX).module_name
        := 'JTF.GRID.PLSQL.JTFGRDDB.DEBUG.CURRENT.SERVER';
   END LOOP;

 end if; -- current grid

-- all grid information

  if fnd_log.test(FND_LOG.LEVEL_EVENT, 'JTF.GRID.PLSQL.JTFGRDDB.DEBUG.ALL.SERVER') then
    all_info_IDX := l_debug_tbl.count + 1;
   /*    i := i + 1;
      l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatSeperator;
       i := i + 1;
      l_debug_tbl(i).debug_message := 'INFORMATION OF ALL OTHER GRIDS';*/
       i := i + 1;
     l_debug_tbl(i).debug_message := ' ';

    all_info := TableDefs.FIRST;
    WHILE all_info is not NULL LOOP
      IF all_info <> j THEN       -- current info is already passed
        addGridInfo(all_info, l_debug_tbl);
      END IF;
     all_info := TableDefs.NEXT(all_info);
    END LOOP;
      i := i + 1;
    l_debug_tbl(i).debug_message := JTF_DEBUG_PUB.FormatSeperator;

    For IDX in all_info_IDX..l_debug_tbl.count LOOP
      l_debug_tbl(IDX).module_name
             := 'JTF.GRID.PLSQL.JTFGRDDB.DEBUG.ALL.SERVER';
    END LOOP;
  end if; -- all grid

-- add midtier/client info

   all_info_IDX := l_debug_tbl.count + 1;
   l_debug_tbl(all_info_IDX).debug_message := ' ';
   all_info_IDX := all_info_IDX + 1;
   FOR i in 1..p_debug_tbl.count LOOP
       l_debug_tbl(all_info_IDX) := p_debug_tbl(i);
       all_info_IDX := all_info_IDX + 1;
   END LOOP;

-- the module name was split up to avoid GSCC error
    JTF_DEBUG_PUB.Debug( p_debug_tbl        =>  l_debug_tbl,
                         p_module           => 'J'||'TF.GRID%',
                         x_path             => x_path,
                         x_filename         => x_filename,
                         x_msg_count        => x_msg_count,
                   	 X_MSG_DATA         => x_msg_data,
	           	 X_RETURN_STATUS    => x_return_status
                         );

END debug;
-----------------------------------------------------------------------------
function  getGridFetchSize(gridName in varchar2, p_serverInitDate in date) return number is
begin
  validateServer(p_serverInitDate, gridName);
  return tableDefs(findTableDefIndex(gridName)).fetchSize;
end getGridFetchSize;

-----------------------------------------------------------------------------
procedure setGridFetchSize(gridName in varchar2, rows in number, p_serverInitDate in date) is
begin
  validateServer(p_serverInitDate, gridName);
  tableDefs(findTableDefIndex(gridName)).fetchSize := rows;
end setGridFetchSize;

-----------------------------------------------------------------------------
procedure getSortCol(gridName       in varchar2
                      ,p_serverInitDate in date
                      ,sort_col1      out nocopy varchar2
                      ,sort_asc_flag1 out nocopy varchar2
                      ,sort_col2      out nocopy varchar2
                      ,sort_asc_flag2 out nocopy varchar2
                      ,sort_col3      out nocopy varchar2
                      ,sort_asc_flag3 out nocopy varchar2
                     ) is
i pls_integer;
j pls_integer;
begin
  validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
     raise INVALID_GRID;
  end if;
  sort_col1 := tableDefs(i).grid_sort_col_alias1;
  sort_col2 := tableDefs(i).grid_sort_col_alias2 ;
  sort_col3 := tableDefs(i).grid_sort_col_alias3 ;

  if sort_col1 is not null then
    j := findColumnDefIndex(gridName,sort_col1);
    if j is not null then
      sort_asc_flag1 := columnDefs(j).sort_asc_by_default_flag ;
    end if;
  end if;
  if sort_col2 is not null then
    j := findColumnDefIndex(gridName,sort_col2);
    if j is not null then
       sort_asc_flag2 := columnDefs(j).sort_asc_by_default_flag ;
    end if;
  end if;
  if sort_col3 is not null then
    j := findColumnDefIndex(gridName,sort_col3);
    if j is not null then
       sort_asc_flag3 := columnDefs(j).sort_asc_by_default_flag ;
    end if;
  end if;

exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'getSortCol',gridName,null,null);
end getSortCol;


procedure getTableDefInfo(gridName       in varchar2
                      ,p_serverInitDate in date
                      ,x_sort_col1      out nocopy varchar2
                      ,x_sort_col2      out nocopy varchar2
                      ,x_sort_col3      out nocopy varchar2
                      ,x_fetchSize      out nocopy number
                     ) IS
i pls_integer;
BEGIN
  validateServer(p_serverInitDate, gridName);
  i := findTableDefIndex(gridName);
  if i is null then
     raise INVALID_GRID;
  end if;
  x_sort_col1 := tableDefs(i).grid_sort_col_alias1;
  x_sort_col2 := tableDefs(i).grid_sort_col_alias2 ;
  x_sort_col3 := tableDefs(i).grid_sort_col_alias3 ;

  -- sort_Col1 can NULL only if sort_col2 and sort_col3 are null so we don't have
  -- to worry about sort_col1

  if x_sort_col2 is NULL and x_sort_col3 is not NULL then
     x_sort_col2 := x_sort_col3;
     x_sort_col3 := NULL;
  end if;

  x_fetchSize := tableDefs(i).fetchSize;

exception
  when INVALID_GRID then
    handleErrors(INVALID_GRID_ERROR,'getTableDefIndex',gridName,null,null);
END getTableDefInfo;

/** this function is invoked only from populate and refresh methods.
    this function catches any "invalid package" exception and tries to recompile
  them before throwing an error.
*/

function fetchFirstSet(gridName in varchar2
                      ,p_serverInitDate in date) return dataSet%TYPE is
j pls_integer;
begin
  return fetchDataSet(gridName
                      ,p_serverInitDate);
exception
  when OTHERS then
      if (SQLCODE = -4068) then
    --if (SQLCODE = -4068 or SQLCODE = -4061 or SQLCODE = -4065 or SQLCODE = -6508 or SQLCODE = -1003) then
        j := findTableDefIndex(gridName);
        tableDefs(j).refreshFlag := 'T';
        tableDefs(j).hasWhereClauseChanged := 'T';
        dataSet := fetchDataSet(gridName, p_serverInitDate);
        return dataSet;
      else
       raise;
    end if;
end;

END jtf_gridDB;

/
