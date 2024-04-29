--------------------------------------------------------
--  DDL for Package Body BSC_MO_DB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_DB_PKG" AS
/* $Header: BSCMODBB.pls 120.22.12000000.2 2007/04/24 05:29:11 amitgupt ship $ */


g_conc_short_name VARCHAR2(100):='BSC_METADATA_OPTIMIZER_SPAWNED';
g_status_message VARCHAR2(100);


g_buckets NUMBER := 1;
g_bucket_id NUMBER := 1;
g_ddl_table_name VARCHAR2(100) := 'BSC_TMP_DDL_TABLE'||bsc_metadata_optimizer_pkg.g_session_id;
g_parallelize boolean := false;
g_parallel_threshold number := 50000000; -- never parallelize in 5.2
g_tables_processed number := 0;
g_bucket_size number := 100000;
g_sleep_time NUMBER;

g_max_buckets NUMBER;
g_ddl_bucket_id  DBMS_SQL.NUMBER_TABLE;
g_ddl_object      DBMS_SQL.VARCHAR2_TABLE;
g_ddl_object_ddl  DBMS_SQL.VARCHAR2_TABLE;
g_ddl_object_type  DBMS_SQL.VARCHAR2_TABLE;


TYPE rec_update_tables is record(
table_name varchar2(100),
property varchar2(100));
TYPE tab_update_tables is TABLE of rec_update_tables INDEX BY PLS_INTEGER;
g_update_tables tab_update_tables;

PROCEDURE CreateDDLTable IS
l_stmt VARCHAR2 (1000) := 'CREATE TABLE '||g_ddl_table_name||' (bucket_id NUMBER, object_name VARCHAR2(100), '||
				' object_ddl varchar2(4000), object_type varchar2(100), status VARCHAR2(10), error_message varchar2(4000))';

l_index VARCHAR2(1000) := 'CREATE UNIQUE INDEX '||g_ddl_table_name||'_U1 ON '||g_ddl_table_name||' (bucket_id, object_name)';
l_error VARCHAR2(1000);
BEGIN
  IF bsc_mo_helper_pkg.tableexists(g_ddl_table_name)=false THEN
    bsc_mo_helper_pkg.do_ddl(l_stmt, ad_ddl.create_table, g_ddl_table_name);
    bsc_mo_helper_pkg.do_ddl(l_index, ad_ddl.create_index, g_ddl_table_name||'_U1');
  ELSE
    execute immediate 'truncate table '||BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.'||g_ddl_table_name;
  END IF;

  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in CreateDDLTable:'||l_error);
    raise;
END;

PROCEDURE InsertDDL(pObjectName IN VARCHAR2,
                    pObjectDDL  IN VARCHAR2,
                    pObjectType IN VARCHAR2) IS
l_stmt VARCHAR2 (1000) := 'INSERT INTO '||g_ddl_table_name ||
			' (bucket_id, object_name, object_ddl, object_type) VALUES (:1, :2, :3, :4)';
l_error varchar2(1000);
BEGIN
  IF (pObjectTYPE = 'TABLE') THEN
    IF (mod(g_tables_processed, g_bucket_size) = 0 AND g_tables_processed <> 0 ) THEN
      g_bucket_id := g_bucket_id + 1;
      g_buckets := g_bucket_id;
      bsc_mo_helper_pkg.writetmp('Incrementing bucket id to '||g_bucket_id||', # Tables processed='||g_tables_processed||', g_bucket_size='||g_bucket_size);
    END IF;
  END IF;
  g_ddl_bucket_id(g_tables_processed) := g_bucket_id ;
  g_ddl_object(g_tables_processed) :=   pObjectName;
  g_ddl_object_ddl(g_tables_processed) := pObjectDDL;
  g_ddl_object_type(g_tables_processed) := pObjectType;
  g_tables_processed := g_tables_processed + 1;

  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in InsertDDL:'||l_error);
    raise;
END;

--****************************************************************************
--  sort_data_columns
--
--    DESCRIPTION:
--       Given a list of measures, sort them and return it
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
PROCEDURE sort_data_columns(p_data IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField) IS
wasAdded boolean ;
l_data_cols BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
l_col BSC_METADATA_OPTIMIZER_PKG.clsDataField;
CURSOR cOrdered IS
SELECT value_v, value_n order_index FROM BSC_TMP_BIG_IN_COND
WHERE variable_id=10
  AND session_id=USERENV('SESSIONID')
ORDER BY value_v;
l_dummy VARCHAR2(100);
l_ordered_index number;
l_ins varchar2(1000);
BEGIN
  IF (p_data.count=0) THEN
    return;
  END IF;
  DELETE BSC_TMP_BIG_IN_COND WHERE variable_id = 10 AND session_id=USERENV('SESSIONID');
  l_ins := 'INSERT INTO BSC_TMP_BIG_IN_COND(variable_id, value_v, value_n, session_id) values (:1, :2, :3, :4)';
  for i in p_data.first..p_data.last loop
    execute immediate l_ins USING 10, upper(p_data(i).fieldName), i, USERENV('SESSIONID');
  end loop;
  for i in cOrdered loop
    l_data_cols(l_data_cols.count) := p_data(i.order_index);
  end loop;
  p_data := l_data_cols;
END;
--****************************************************************************
--  GetDimKeyDataType
--
--    DESCRIPTION:
--       Get the data type of the given key columns
--
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function GetDimKeyDataType(dimTable IN VARCHAR2, columnName IN VARCHAR2, dataLength OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
l_stmt VARCHAR2(1000);
CURSOR cUserTabColumns IS
SELECT DATA_TYPE, DATA_LENGTH
  FROM USER_TAB_COLUMNS
 WHERE TABLE_NAME = dimTable
   AND COLUMN_NAME = columnName;

CURSOR cAllTabColumns IS
SELECT DATA_TYPE, DATA_LENGTH
  FROM ALL_TAB_COLUMNS
 WHERE TABLE_NAME = dimTable
   AND COLUMN_NAME = columnName
   AND OWNER = BSC_METADATA_OPTIMIZER_PKG.gBSCSchema;

l_temp1 NUMBER;
l_type VARCHAR2(30) := null;
l_length NUMBER;

BEGIN
  l_temp1 := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, dimTable);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writetmp('l_temp1 ='||l_temp1);
    bsc_mo_helper_pkg.writetmp('dimTable = '||dimTable||', column = '||columnName||', source ='||
       BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp1).Source);
  END IF;
  If BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp1).Source = 'PMF' Then
    --The dimension table is a View
    OPEN cUserTabColumns;
    FETCH cUserTabColumns INTO l_type, l_length;
    CLOSE cUserTabColumns;
  Else
    OPEN cAllTabColumns;
    FETCH cAllTabColumns INTO l_type, l_length;
    CLOSE cAllTabColumns;
  End If;

  IF l_type = 'UNDEFINED' then -- view is invalid
    bsc_mo_helper_pkg.writeTmp('View '||dimTable||' is invalid', FND_LOG.LEVEL_EXCEPTION);
    raise bsc_metadata_optimizer_pkg.optimizer_exception;
  END IF;
  If l_type IS NULL Then
    dataLength := 5;
    return 'VARCHAR2';
  Else
    If l_TYPE = 'NUMBER' Then
      dataLength := 0;
    Else
      dataLength := l_length;
    End If;
    return l_type;
  End If;

  EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in GetDimKeyDataType, dimTable='||dimTable|| ', columnName='||
           columnName||' :'||sqlerrm);
    raise;
End;

function reorder_index(p_b_pt_table_name varchar2, colColumns IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn) return varchar2 is
l_periodicity_id_exists boolean;
l_year_exists boolean;
l_period_exists boolean;
l_type_exists boolean;
l_stmt varchar2(1000);
l_zero_code_cols varchar2(1000) ;
begin

  for i in 0..colColumns.count-1 loop
      if (colColumns(i).columnName = 'PERIODICITY_ID') then
        l_periodicity_id_exists := true;
      elsif (colColumns(i).columnName = 'YEAR') then
        l_year_exists := true;
      elsif (colColumns(i).columnName = 'PERIOD') then
        l_period_exists := true;
      elsif (colColumns(i).columnName = 'TYPE') then
        l_type_exists := true;
      end if;
  end loop;
  -- changing here as this isnt used by anything other than bsc
  -- bug 3876730, add in the following order
  -- 'PERIODICITY_ID', 'YEAR', 'PERIOD', 'TYPE'
  l_stmt := null;
  if (l_periodicity_id_exists) then
    l_stmt := l_stmt||'PERIODICITY_ID,';
  end if;
  if (l_year_exists) then
    l_stmt := l_stmt||'YEAR,';
  end if;
  if (l_period_exists) then
    l_stmt := l_stmt||'PERIOD,';
  end if;
  if (l_type_exists) then
    l_stmt := l_stmt||'TYPE,';
  end if;

  l_zero_code_cols := null;
  for i in 0..colColumns.count-1  loop
    if (colColumns(i).isKey) then
      if (colColumns(i).columnName not in ('PERIODICITY_ID', 'YEAR', 'PERIOD', 'TYPE')) then
        if(BSC_IM_UTILS.needs_zero_code_b_pt(p_b_pt_table_name, colColumns(i).columnName)) then
          l_zero_code_cols := l_zero_code_cols||colColumns(i).columnName||',';
        else
          l_stmt:=l_stmt||colColumns(i).columnName||',';
        end if;
     end if;
   end if;
  end loop;
  if (l_zero_code_cols is not null) then
    l_stmt := l_stmt ||l_zero_code_cols;
  end if;
  l_stmt := substr(l_stmt, 1, length(l_stmt)-1);
  return l_stmt;
end;

PROCEDURE addAWColumns(
  colCampos IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn,
  p_b_aw_table IN boolean)
IS
  dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
  dbColumn_null BSC_METADATA_OPTIMIZER_PKG.clsDBColumn := null;
  l_columns BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn;
BEGIN
  -- projection
  dbColumn := dbColumn_null;
  dbColumn.columnName := 'PROJECTION';
  dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTVarchar2;
  dbColumn.columnLength := 100;
  dbColumn.iskey := false;
  colCampos(colCampos.count) := dbColumn;
  --05/18/2005, Venu asked me to not create B_AW table and move change_vector to B table
  --Add Change Vector right after projection col
  dbColumn := dbColumn_null;
  dbColumn.columnName := 'CHANGE_VECTOR';
  dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
  dbColumn.columnLength := 0;
  dbColumn.isKey := false;
  colCampos(colCampos.count) := dbColumn;

  bsc_mo_helper_pkg.writeTmp('added AW column(s) to table');
END;

PROCEDURE get_column_list(
      colColumns         IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn,
      p_column_sql      OUT NOCOPY VARCHAR2,
      p_primary_key_sql OUT NOCOPY VARCHAR2,
      p_keys_exist      OUT NOCOPY boolean ) IS
  l_index1 number;
  dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
BEGIN
  p_column_sql := null;
  l_index1 := colColumns.first;
  LOOP
    dbColumn := colColumns(l_index1);
    p_column_sql := p_column_sql || dbColumn.columnName;
    IF dbColumn.columnLength = 0 THEN
      p_column_sql := p_column_sql || ' '|| dbColumn.columnType;
    ELSE
      p_column_sql := p_column_sql || ' ' || dbColumn.columnType || '(' || dbColumn.columnLength ||')';
    END IF;
    IF dbColumn.isKey THEN
      p_column_sql := p_column_sql || ' NOT NULL';
      p_primary_key_sql :=p_primary_key_sql|| dbColumn.columnName;
      p_primary_key_sql :=p_primary_key_sql||',';
      -- Bug 4765104
      IF (dbColumn.isTimeKey=false) THEN
        p_keys_exist := true;
      END IF;
    END IF;
    p_column_sql := p_column_sql || ',';
    EXIT WHEN l_index1 = colColumns.last;
    l_index1 := colColumns.next(l_index1);
  END LOOP;
  p_column_sql := substr(p_column_sql, 1, length(p_column_sql)-1);
  bsc_mo_helper_pkg.writeTmp('get_col_list, p_primary_key_sql ='||p_primary_key_sql);
  p_primary_key_sql := substr(p_primary_key_sql, 1, length(p_primary_key_sql)-1);
   bsc_mo_helper_pkg.writeTmp('get_col_list, p_primary_key_sql ='||p_primary_key_sql);
    EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in get_column_list:'||sqlerrm);
    raise;
END;

PROCEDURE handle_ddl(p_object_name varchar2, p_object_type varchar2, p_ddl varchar2) IS
BEGIN
  IF (g_parallelize) THEN
    insertDDL(p_object_name, p_ddl, p_object_type);
    return;
  END IF;
  IF (p_object_type = 'INDEX') THEN
    begin
    BSC_MO_HELPER_PKG.do_ddl('drop index '||p_object_name, ad_ddl.drop_index, p_object_name);
    exception when others then
      null;
    end;
    BSC_MO_HELPER_PKG.Do_DDL (p_ddl, ad_ddl.create_index, p_object_name);
  ELSIF p_object_type='TABLE' THEN
    BEGIN
    BSC_MO_HELPER_PKG.Do_DDL (p_ddl, ad_ddl.create_table, p_object_name);
    exception when others then
      if sqlcode = -955 then --already exists for some reason, so drop and recreate
        BSC_MO_HELPER_PKG.Do_DDL ('drop table '||p_object_name, ad_ddl.drop_table, p_object_name);
        BSC_MO_HELPER_PKG.Do_DDL (p_ddl, ad_ddl.create_table, p_object_name);
      else
        raise;
      end if;
    END;
  END IF;
  if (bsc_metadata_optimizer_pkg.g_log) then
    bsc_mo_helper_pkg.writeTmp(p_ddl);
    bsc_mo_helper_pkg.writetmp(p_object_type||' '||p_object_name||' created successfully');
  end if;

    EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in handle_ddl, Table='||p_object_name||',ddl='||p_ddl||', error='||sqlerrm);
    raise;
END;

FUNCTION get_table_name(p_table_name varchar2) return VARCHAR2 IS
l_index number:=0;
BEGIN
  IF NOT bsc_mo_helper_pkg.tableexists(p_table_name) THEN
    return p_table_name;
  END IF;
  LOOP
    IF NOT bsc_mo_helper_pkg.tableexists(p_table_name||l_index) THEN
      return p_table_name||l_index;
    END IF;
    l_index := l_index+1;
  END LOOP;
    EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in get_table_name, Table='||p_table_name);
    raise;
END;

FUNCTION create_b_prj_table(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable, p_column_clause VARCHAR2, p_storage_clause VARCHAR2)
RETURN VARCHAR2 IS
l_stmt VARCHAR2(32767);
l_table_name varchar2(100);
BEGIN
  bsc_mo_helper_pkg.writeTmp('create_b_prj_table for '||p_table.name);
  l_table_name := get_table_name(p_table.name||'_PRJ');
  l_stmt := 'CREATE TABLE ' || l_table_name||' (' ||p_column_clause||') '||p_storage_clause;
  handle_ddl(l_table_name, 'TABLE', l_stmt);

  return l_table_name;
    EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in create_b_prj_table, Table='||p_table.name||', stmt='||l_stmt||', error='||sqlerrm);
    raise;
END;

FUNCTION create_i_rowid_table(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable, p_storage_clause VARCHAR2)
RETURN VARCHAR2 IS
l_stmt VARCHAR2(4000);
l_table_name varchar2(100);

BEGIN

  l_table_name := get_table_name(p_table.name||'_ROWID');
  l_stmt := 'CREATE TABLE ' || l_table_name||' (ROW_ID ROWID, '||BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME||' NUMBER) '||p_storage_clause;
  handle_ddl(l_table_name, 'TABLE', l_stmt);
  return l_table_name;
   EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in create_i_rowid_table, Table='||p_table.name||', stmt='||l_stmt||', error:'||sqlerrm);
    raise;
END;

PROCEDURE add_to_update_tables_list(p_Table_name VARCHAR2, p_property VARCHAR2, p_value VARCHAR2) IS
  l_update_rec rec_update_tables;
BEGIN
  l_update_rec.table_name := p_table_name;
  l_update_rec.property := p_property||BSC_DBGEN_STD_METADATA.BSC_ASSIGNMENT||p_value;
  g_update_tables(g_update_tables.count+1) := l_update_rec;
    EXCEPTION WHEN OTHERS THEN
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in add_to_update_tables_list, Table='||p_table_name|| ', property='||
          p_property||', value='||p_value||', error:'||sqlerrm);
    raise;
END;


--****************************************************************************
--  CrearTablaDB : CreateTableInDB
--
--    DESCRIPTION:
--       Create the given table in the database.
--       Create an index on the key columns.
--
--    PARAMETERS:
--       p_table_name: table name
--       colColumns: collection with the table columns
--       db_obj: database object
--****************************************************************************
PROCEDURE CreateTableInDB(
  p_table_name IN VARCHAR2,
  colColumns IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn,
  TableTbsName IN VARCHAR,
  IndexTbsName IN VARCHAR,
  p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable,
  p_table_type IN VARCHAR2)
IS
    dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
    l_stmt VARCHAR2(32767);
    columnList VARCHAR2(8000):=null;
    l_primary_key VARCHAR2(1000) := null;
    l_index1 NUMBER;
    l_newline varchar2(10) :='
';
    l_index_stmt VARCHAR2(32767) ;
    l_index_name VARCHAR2(100);
    l_error varchar2(2000);
    l_aw_stmt varchar2(32767);
    l_aw_index_stmt varchar2(32767);
    l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;

    l_b_aw_columns BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn;

    l_table_name VARCHAR2(100);
    b_keys_exist boolean ;

   l_table_misc_clause varchar2(4000) := null;
BEGIn
  --Create the table in the database
  IF (colColumns.count =0) THEN
    RETURN;
  END IF;
  get_column_list(colColumns, columnList, l_primary_key, b_keys_exist);

  l_stmt := 'CREATE TABLE ' || p_table_name||' (' || columnList||') ';
  if (p_table_type = 'B' and b_keys_exist) then
      l_stmt := l_stmt || bsc_metadata_optimizer_pkg.g_partition_clause;
  end if;
  l_stmt := l_stmt||' TABLESPACE '||TableTbsName  || ' '||BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
  handle_ddl(p_table_name, 'TABLE', l_stmt);

  -- Create B_PRJ table and indexes
  IF (p_table_type = 'B') THEN
    -- Bug 4765104, partition only when dim keys exist
    if (b_keys_exist) then
      l_table_misc_clause := bsc_metadata_optimizer_pkg.g_partition_clause;
      add_to_update_tables_list(p_table_name, BSC_DBGEN_STD_METADATA.BSC_PARTITION,
                                bsc_metadata_optimizer_pkg.g_num_partitions);
    end if;
    l_table_misc_clause := l_table_misc_clause||' TABLESPACE '||TableTbsName  ||
           ' '||BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
    l_table_name := create_b_prj_table(p_table, columnList, l_table_misc_clause);
    add_to_update_tables_list(p_table_name, BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE, l_table_name);
    --bug fix 5647971 centralized logic to get index name
    -- added api in helper package
      l_index_name := BSC_MO_HELPER_PKG.generate_index_name(p_table_name,'B','1');
      l_index_stmt := 'CREATE BITMAP INDEX '||l_index_name||' ON '||p_table_name||'(YEAR) TABLESPACE '||IndexTbsName||
                    ' '|| BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
    IF (bsc_metadata_optimizer_pkg.g_num_partitions>1 and b_keys_exist) then
      l_index_stmt := l_index_stmt||' LOCAL ';
    END IF;
    -- Create Bitmap indexes on YEAR And CHANGE_VECTOR (AW case)

    handle_ddl(l_index_name, 'INDEX', l_index_stmt);
    -- For AW create separate index on CHANGE_VECTOR
    IF (p_table.Impl_type=2) THEN -- create an AW type index
    --bug fix 5647971 centralized logic to get index name
    -- added api in helper package
      l_index_name := BSC_MO_HELPER_PKG.generate_index_name(p_table_name,'B','2');
      l_index_stmt := 'CREATE BITMAP INDEX ' || l_index_name || ' ON '|| p_table_name ||
             '(CHANGE_VECTOR) TABLESPACE '||IndexTbsName || ' '|| BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
      IF (bsc_metadata_optimizer_pkg.g_num_partitions>1 and b_keys_exist) then
        l_index_stmt := l_index_stmt||' LOCAL ';
      END IF;
      handle_ddl(l_index_name, 'INDEX', l_index_stmt);
    END IF;
    return; -- B table has only the 2 bit map indexes
  END IF;

  -- create I_ROWID table for Input Tables
  IF p_table_type ='I' THEN
    -- 11/16/2005, always generate rowid tables, after discussion with venu/mauricio.
    --AND bsc_metadata_optimizer_pkg.g_num_partitions>1
    l_table_name := create_i_rowid_table(p_table, ' TABLESPACE '||TableTbsName  ||
          ' '||BSC_METADATA_OPTIMIZER_PKG.gStorageClause);
      add_to_update_tables_list(p_table_name, BSC_DBGEN_STD_METADATA.BSC_I_ROWID_TABLE, l_table_name);
  END IF;

  IF l_primary_key IS NOT NULL THEN -- create normal index
    if (p_table_name like 'BSC_S%_PT' ) then
      l_primary_key := reorder_index(p_table_name, colColumns);
      BSC_MO_HELPER_PKG.writeTmp('index columns after reordering is :'||l_primary_key);
    end if;
    l_index_name := p_table_name ||'_U1';
    l_index_stmt := 'CREATE UNIQUE INDEX ' || l_index_name || ' ON '|| p_table_name ||
             ' ('|| l_primary_key || ') '||
            ' TABLESPACE '||IndexTbsName || ' '|| BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
    handle_ddl(l_index_name, 'INDEX', l_index_stmt);
  END IF;

  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in CreateTableInDB, Table='||p_table_name|| ':'||l_error);
    BSC_MO_HELPER_PKG.writeTmp('Table creation stmt ='||l_stmt, FND_LOG.LEVEL_UNEXPECTED, true );
    BSC_MO_HELPER_PKG.writeTmp('Index creation stmt ='||l_index_stmt, FND_LOG.LEVEL_UNEXPECTED, true );
    raise;
END ;

FUNCTION ExistIndex(IndexName IN VARCHAR2) RETURN boolean IS
    l_res boolean := FALSE;
    l_dummy VARCHAR2(1000);

CURSOR c1 (pSchema IN VARCHAR2) IS
SELECT INDEX_NAME FROM ALL_INDEXES
WHERE INDEX_NAME = upper(IndexName)
AND OWNER = pSchema;

l_error VARCHAR2(1000);
BEGIN
  OPEN c1(BSC_METADATA_OPTIMIZER_PKG.gBscSchema);
  FETCH c1 INTO l_dummy;
  IF c1%FOUND THEN
    l_res := TRUE;
  END IF;
  Close c1;
  RETURN l_res;
  EXCEPTION WHEN OTHERS THEN
    l_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in ExistIndex:'||l_error);
    raise;
END ;

--****************************************************************************
--  CreateProjTable
--
--    DESCRIPTION:
--       Creates the given table in the database.
--
--    PARAMETERS:
--       Tabla: Table. It is an object with all inFORmation about the table
--
--****************************************************************************
PROCEDURE CreateProjTable(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable) IS

    Llave BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
    Dato BSC_METADATA_OPTIMIZER_PKG.clsDataField;
    colCampos BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn;

    dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
    NomCampoPeriod VARCHAR2(100);
    NomCampoSubPeriod VARCHAR2(100);
    msg VARCHAR2(100);
    uv_name VARCHAR2(100);
    l_stmt VARCHAR2(1000);
    isBaseTable Boolean;
    createTable Boolean;

    Tabla_Keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
    Tabla_Data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;

    l_index NUMBER;

    New_clsdbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
    l_error VARCHAR2(1000);

    dimTable VARCHAR2(100);
    l_temp1 NUMBER;
    columnSize NUMBER;

BEGIN

    --BIS DIMENSIONS: From now on we cannot assume that USER CODE and CODE are
    --VARCHAR2 and NUMBER respectively. From now on I will get the data type
    --direclty from the dimension table.

    --Table should not exist
    IF bsc_mo_helper_pkg.tableexists(p_table.projectionTable) THEN
        bsc_mo_helper_pkg.droptable(p_table.projectionTable);
    END IF;

    --Create the table in the database
    Tabla_Keys := p_table.keys;
    Tabla_Data := p_table.data;
    --Keys
    l_index := Tabla_Keys.first;
    LOOP
        EXIT WHEN Tabla_Keys.count=0;
        Llave := Tabla_Keys(l_index);
        dbColumn := New_clsdbColumn;

        l_temp1 := BSC_MO_HELPER_PKG.FindKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, Llave.keyName);

        dimTable := BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp1).name;
        dbColumn.columnName := Llave.keyName;
        dbColumn.columnType := GetDimKeyDataType(dimTable, 'CODE', columnSize);
        dbColumn.columnlength := columnSize;
        dbColumn.isKey := TRUE;
        dbColumn.isTimeKey := FALSE;
        colCampos(colCampos.count) := dbColumn;

        EXIT WHEN l_index = Tabla_keys.last;
        l_index := Tabla_keys.next(l_index);

    END LOOP;
    --Year
    dbColumn := New_clsdbColumn;
    dbColumn.columnName := 'YEAR';
    dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
    dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_INTEGER;
    dbColumn.isKey := TRUE;
    dbColumn.isTimeKey := TRUE;
    colCampos(colCampos.count) := dbColumn;

    --Type
    dbColumn := New_clsdbColumn;
    dbColumn.columnName := 'TYPE';
    dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
    dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_BYTE;
    dbColumn.isKey := TRUE;
    dbColumn.isTimeKey := TRUE;
    colCampos(colCampos.count) := dbColumn;

    --Period
    dbColumn := New_clsdbColumn;
    dbColumn.columnName := 'PERIOD';
    dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
    dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_INTEGER;
    dbColumn.isKey := TRUE;
    dbColumn.isTimeKey := TRUE;
    colCampos(colCampos.count) := dbColumn;

    --Periodicity_Id
    dbColumn := New_clsdbColumn;
    dbColumn.columnName := 'PERIODICITY_ID';
    dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
    dbColumn.columnLength := 0;
    dbColumn.isKey := TRUE;
    dbColumn.isTimeKey := TRUE;
    colCampos(colCampos.count) := dbColumn;


    --Period_Type_Id
    --Fix bug#3353111 In Projection Tables created FOR target at dIFferent levels,
    --                 PERIOD_TYPE_ID should be not null and should not included in the index
    dbColumn := New_clsdbColumn;
    dbColumn.columnName := 'PERIOD_TYPE_ID';
    dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
    dbColumn.columnLength := 0;
    dbColumn.isKey := FALSE;
    colCampos(colCampos.count) := dbColumn;

    --Data columns
    sort_data_columns(Tabla_Data);
    l_index := Tabla_Data.first;
    LOOP
        EXIT WHEN Tabla_Data.count =0;
        Dato := Tabla_Data(l_index);
        dbColumn := New_clsdbColumn;
        dbColumn.columnName := Dato.fieldName;
        dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
        dbColumn.columnLength := 0;
        dbColumn.isKey := FALSE;
        colCampos(colCampos.count) := dbColumn;
        EXIT WHEN l_index = Tabla_Data.last;
        l_index := Tabla_data.next(l_index);
    END LOOP;
    CreateTableInDB(
	  p_table.projectionTable,
	  colCampos,
	  BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName,
	  BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName,
	  p_table,
          'PROJECTION');

    EXCEPTION WHEN OTHERS THEN
	   l_error := sqlerrm;
	   BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in CreateProjTable:'||l_error);
	   raise;
END ;




PROCEDURE AddPeriodicityId(BaseTable BSC_METADATA_OPTIMIZER_PKG.clsTable) IS
    l_stmt VARCHAR2(32000);
    IndexName VARCHAR2(1000);
    IndexedColumns VARCHAR2(4000);
    keyColumn BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
    BaseTable_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;

    l_index NUMBER;
    l_error VARCHAR2(1000);
    l_zero_code_cols VARCHAR2(1000) := null;
    l_prj_table varchar2(100);

    CURSOR cDropIndexes(p_table IN VARCHAR2, p_owner IN VARCHAR2) IS
    SELECT INDEX_NAME FROM ALL_INDEXES WHERE TABLE_NAME= p_table and table_owner=p_owner;
BEGIN

    IF bsc_mo_helper_pkg.tableExists(BaseTable.Name) THEN
        IF Not bsc_mo_helper_pkg.table_column_exists(BaseTable.Name, 'PERIODICITY_ID') THEN
            --Add periodicity_id
            l_stmt := 'ALTER TABLE ' || BaseTable.Name || ' ADD PERIODICITY_ID NUMBER';
            BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, BaseTable.Name);

            --Update periodicity_id
            l_stmt := 'UPDATE ' || BaseTable.Name||' SET PERIODICITY_ID =:1 ';
            EXECUTE IMMEDIATE l_stmt using BaseTable.Periodicity;

            --Set periodicity_id NOT NULL
            l_stmt := 'ALTER TABLE ' || BaseTable.Name || ' MODIFY PERIODICITY_ID NOT NULL';
            BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, BaseTable.Name);

            --Drop existing indexes
            OPEN cDropIndexes(BaseTable.Name, BSC_METADATA_OPTIMIZER_PKG.gBSCSchema);
            LOOP
              FETCH cDropIndexes INTO IndexName;
              EXIT WHEN cDropIndexes%NOTFOUND;
              --Drop index
              l_stmt := 'DROP INDEX ' || IndexName;
              BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.drop_index, IndexName);
            END LOOP;
            CLOSE cDropIndexes;
            --Re-create index to include PERIODICITY_ID
            IndexName := BaseTable.Name || '_U1';
            IndexedColumns := IndexedColumns || 'PERIODICITY_ID, YEAR, PERIOD, TYPE,';
            BaseTable_keys := BaseTable.keys;
            l_index := BaseTable_keys.first;
            LOOP
                EXIT WHEN BaseTable_keys.count = 0;
                keyColumn := BaseTable_Keys(l_index);
                if(BSC_IM_UTILS.needs_zero_code_b_pt(BaseTable.Name, keyColumn.keyName)) then
                  l_zero_code_cols := l_zero_code_cols||keyColumn.keyName||',';
                else
                  IndexedColumns := IndexedColumns ||keyColumn.keyName||',';
                end if;
                EXIT WHEN l_index = BaseTable_keys.last;
                l_index := BaseTable_keys.next(l_index);
            END LOOP;
            IndexedColumns := IndexedColumns ||l_zero_code_cols;
            IndexedColumns := substr(IndexedColumns, 1, Length(IndexedColumns)-1);
            begin
              -- just for safety, in case of corrupt left over tables
              bsc_mo_helper_pkg.do_ddl('drop index '||IndexName, ad_ddl.drop_index, IndexName);
              -- ignore all exceptions here
               exception when others then
               null;
            end;
            l_stmt := 'CREATE UNIQUE INDEX '|| IndexName||
                    ' ON ' || BaseTable.Name || ' (' || IndexedColumns || ') '||
                     ' TABLESPACE '||BSC_METADATA_OPTIMIZER_PKG.gBaseIndexTbsName||' ' || BSC_METADATA_OPTIMIZER_PKG.gStorageClause;
            bsc_mo_helper_pkg.Do_DDL (l_stmt, ad_ddl.create_index, IndexName);
        END IF;
    END IF;
    --  Bug#:5214589
    -- Alter B_PRJ Table if required
    l_prj_table := BSC_DBGEN_METADATA_READER.get_table_properties(BaseTable.Name,
                         BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE);
    if (l_prj_table is not null) then
      IF Not bsc_mo_helper_pkg.table_column_exists(l_prj_table, 'PERIODICITY_ID') THEN
        --Add periodicity_id
        l_stmt := 'ALTER TABLE ' || l_prj_table || ' ADD PERIODICITY_ID NUMBER';
        BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, BaseTable.Name);
        --Update periodicity_id
        l_stmt := 'UPDATE ' || l_prj_table||' SET PERIODICITY_ID =:1 ';
        EXECUTE IMMEDIATE l_stmt using BaseTable.Periodicity;
        --Set periodicity_id NOT NULL
        l_stmt := 'ALTER TABLE ' || l_prj_table || ' MODIFY PERIODICITY_ID NOT NULL';
        BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, BaseTable.Name);
      END IF;
    end if;
    EXCEPTION WHEN OTHERS THEN
	   l_error := sqlerrm;
	   BSC_MO_HELPER_PKG.writeTmp('Error in statement:'||l_stmt, FND_LOG.LEVEL_EXCEPTION, true);
	   BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in AddPeriodicityId:'||l_error);
	   raise;
END ;

--****************************************************************************
--  CreateDefMaterializedView
--
--    DESCRIPTION:
--       Create the definition of a materialized view corresponding to the
--       given system table. The table is FOR an EDW KPI.
--
--    PARAMETERS:
--       Tabla: clsTabla object with all info about the table
--****************************************************************************
PROCEDURE CreateDefMaterializedView(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable) IS
    l_stmt VARCHAR2(100);
    cal_id NUMBER;
    num_anos NUMBER;
    num_anosant NUMBER;
    fiscal_year NUMBER;
    start_year NUMBER;
    END_year NUMBER;
    l_index NUMBER;
    l_error VARCHAR2(1000);
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside CreateDefMaterializedView', FND_LOG.LEVEL_PROCEDURE);
	END IF;
    --Create the materialized view
    l_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, p_table.periodicity);
    cal_id := BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_index).CalENDarID;

    l_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gCalENDars, cal_id);
    num_anos := BSC_METADATA_OPTIMIZER_PKG.gCalENDars(l_index).NumOfYears;
    num_anosant := BSC_METADATA_OPTIMIZER_PKG.gCalENDars(l_index).PreviousYears;
    fiscal_year := BSC_METADATA_OPTIMIZER_PKG.gCalENDars(l_index).CurrFiscalYear;

    start_year := fiscal_year - num_anosant;
    END_year := start_year + num_anos - 1;

    -- EDW code, obsoleted
    --BSC_INTEGRATION_MV_GEN.Create_Def_Materialized_View(p_table.name, cal_id, start_year||'-'||END_year);
    --BSC_MO_HELPER_PKG.CHeckError('BSC_INTEGRATION_MV_GEN.Create_Def_Materialized_View');

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('Completed CreateDefMaterializedView FOR '||p_table.name, FND_LOG.LEVEL_PROCEDURE);
	END IF;

    EXCEPTION WHEN OTHERS THEN
	   l_error := sqlerrm;
	   BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in CreateDefMaterializedView:'||l_error);
	   raise;

END ;


--****************************************************************************
--  GetSubperiodColumnName : GetNombreCampoSubPeriod
--
--    DESCRIPTION:
--       RETURNs the subperiod column name of the given periodicity.
--       It is got from BSC_SYS_PERIODICITIES table
--
--    PARAMETERS:
--       Periodicidad: Periodicity code
--****************************************************************************
FUNCTION GetSubperiodColumnName(Periodicity IN VARCHAR2) RETURN VARCHAR2 IS

    l_RETURN VARCHAR2(100);
    CURSOR c1 IS
    SELECT SUBPERIOD_COL_NAME
    FROM BSC_SYS_PERIODICITIES
    WHERE PERIODICITY_ID = Periodicity;
    l_error varchar2(1000);
BEGIN

    OPEN c1;
    FETCH c1 INTO l_RETURN;
    IF (c1%FOUND) THEN
        IF (l_RETURN IS NULL) THEN
            l_RETURN := '';
         END IF;
    END IF;
    Close c1;

    RETURN l_RETURN;

    EXCEPTION WHEN OTHERS THEN
        l_error := sqlerrm ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in GetSubperiodColumnName, Periodicity = '||Periodicity||' : '||l_error);
        BSC_MO_HELPER_PKG.TerminateWithError ('BSC_SUBPERIOD_FAILED', 'GetSubperiodColumnName');
        RAISE;
END;


--****************************************************************************
--  GetPeriodColumnName : GetNombreCampoPeriod
--
--    DESCRIPTION:
--       RETURNs the period column name of the given periodicity.
--       It is got from BSC_SYS_PERIDIOCITIES table.
--
--    PARAMETERS:
--       Periodicidad: Periodicity code
--****************************************************************************
FUNCTION GetPeriodColumnName(Periodicity IN NUMBER) RETURN VARCHAR2 IS

    CURSOR c1 IS
    SELECT PERIOD_COL_NAME
    FROM BSC_SYS_PERIODICITIES
    WHERE PERIODICITY_ID = Periodicity;
    l_RETURN VARCHAR2(100);
    l_error VARCHAR2(1000);
BEGIN


    OPEN c1;
    FETCH c1 INTO l_RETURN;

    IF (c1%NOTFOUND) THEN
        l_RETURN := 'PERIOD';
    ELSE
        IF (l_RETURN IS NULL ) THEN
            l_RETURN := 'PERIOD';
        END IF;
    END IF;

    CLOSE C1;

    RETURN l_RETURN;

    EXCEPTION WHEN OTHERS THEN
	   l_error := sqlerrm;
	   FND_FILE.put_line(FND_FILE.LOG, 'Exception in GetPeriodColumnName:'||l_error);
	   BSC_MO_HELPER_PKG.TerminateWithError('BSC_RETR_PERIOD_FAILED' , 'GetPeriodColumnName');
       raise;
END ;

--****************************************************************************
--  GetKeyLength : GetTamanoCampoLlave
--
--    DESCRIPTION:
--       Get the lenght of the given key column. FOR that, it looks FOR the
--       lenght of the column USER_CODE of the dimension table associted to
--       the given key column.
--
--    PARAMETERS:
--       Llave: key column name
--****************************************************************************
/*
FUNCTION GetKeyLength(Llave IN VARCHAR2) RETURN NUMBER IS
    Maestra VARCHAR2(100);
    l_stmt VARCHAR2(300);
    l_temp NUMBER ;
    CURSOR c1 (p1 VARCHAR2) IS
    SELECT DATA_LENGTH FROM ALL_TAB_COLUMNS
    WHERE UPPER(TABLE_NAME)= p1
    AND UPPER(COLUMN_NAME) = 'USER_CODE'
    AND UPPER(OWNER) = BSC_METADATA_OPTIMIZER_PKG.gBSCSchema;

    l_error VARCHAR2(1000);
BEGIN

    l_temp := BSC_MO_HELPER_PKG.FindKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMastertable, Llave);
    IF (l_temp=-1) THEN
        Maestra := null;
        RETURN 256;
    ELSE
        Maestra := BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp).name;
    END IF;

    --APPS
    OPEN c1(Maestra);
    FETCH c1 INTO l_temp;
    IF (c1%NOTFOUND) THEN
        l_temp := 0;
    END IF;
    Close c1;

    RETURN l_temp;

    EXCEPTION WHEN OTHERS THEN
	   l_error := sqlerrm;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
	   bsc_mo_helper_pkg.writeTmp('Exception in GetKeyLength:'||l_error);
	END IF;
       raise;
END;
*/

PROCEDURE clearColumn(col IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.clsDBColumn) IS
BEGIN
    col.columnName := null;
    col.columnType := null;
    col.columnLength := null;
    col.isKey := null;
END;

FUNCTION getDataTypeForTimeFK(pCalendar IN NUMBER, pPeriodicity IN NUMBER) return VARCHAR2 IS
CURSOR cPeriodicityType IS
    SELECT periodicity_type
    FROM bsc_sys_periodicities
    where calendar_id = pCalendar
    and periodicity_id = pPeriodicity;

l_periodicity NUMBER;
BEGIN
    OPEN cPeriodicityType;
    FETCH cPeriodicityType INTO l_periodicity;
    CLOSE cPeriodicityType;

    IF (l_periodicity = 9) THEN -- daily
        return BSC_METADATA_OPTIMIZER_PKG.DTDate;
    ELSE
        return BSC_METADATA_OPTIMIZER_PKG.DTVarchar2;
    END IF;
END;


PROCEDURE addYearPeriodType (
        colCampos IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn,
        periodicity IN NUMBER,
        addSubPeriod IN BOOLEAN,
        tableType IN NUMBER -- 0 for input table
         ) IS

dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
NomCampoPeriod VARCHAR2(100);
NomCampoSubPeriod VARCHAR2(100);
periodicitySource VARCHAR2(100);
l_temp1 NUMBER;
l_temp2 NUMBER;

BEGIN

        l_temp1 := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, periodicity);
        l_temp2 := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gCalendars, BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp1).CalendarID);
        periodicitySource := BSC_METADATA_OPTIMIZER_PKG.gCalendars(l_temp2).Source;

        If periodicitySource = 'PMF' and tableType= 0 Then
            --TIME_FK
            dbColumn.columnName := 'TIME_FK';
            dbColumn.columnType := getDataTypeForTimeFK(
                                BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_temp1).CalendarID,
                                periodicity);
            IF (dbColumn.columnType = BSC_METADATA_OPTIMIZER_PKG.DTVarchar2 ) THEN
                dbColumn.columnLength := 4000;
            ELSE
                dbColumn.columnLength := 0;
            END IF;
            dbColumn.isKey := TRUE;
            dbColumn.isTimeKey := TRUE;
        ELSE
            dbColumn.columnName := 'YEAR';
            dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
            dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_INTEGER;
            dbColumn.isKey := TRUE;
            dbColumn.isTimeKey := TRUE;
        END IF;

        IF (colCampos.count > 0 ) THEN
            colCampos(colCampos.last+1) := dbColumn;
        ELSE
            colCampos(0) := dbColumn;
        END IF;

        --Type
        clearColumn(dbColumn);
        dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
        dbColumn.columnName := 'TYPE';
        dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
        dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_BYTE;
        dbColumn.isKey := TRUE;
        dbColumn.isTimeKey := TRUE;

        colCampos(colCampos.last+1) := dbColumn;

        If periodicitySource = 'PMF' and tableType= 0 Then
            null;
        ELSE
            --Period
            NomCampoPeriod := GetPeriodColumnName(Periodicity);
            clearColumn(dbColumn);
            dbColumn.columnName := NomCampoPeriod;
            dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
            dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_INTEGER;
            dbColumn.iskey := TRUE;
            dbColumn.isTimeKey := TRUE;
            colCampos(colCampos.last+1) := dbColumn;

            --SubPeriod
            IF (addSubPeriod) THEN
                NomCampoSubPeriod := GetSubperiodColumnName(Periodicity);
                IF NomCampoSubPeriod <> ''  AND NomCampoSubPeriod IS NOT NULL THEN
                    dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
                    dbColumn.columnName := NomCampoSubPeriod;
                    dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
                    dbColumn.columnLength := BSC_METADATA_OPTIMIZER_PKG.ORA_DATA_PRECISION_INTEGER;
                    dbColumn.isKey := TRUE;
                    dbColumn.isTimeKey := TRUE;
                    colCampos(colCampos.last+1) := dbColumn;
                END IF;
            END IF;
        END IF;

END;


PROCEDURE add_columns_to_tables(p_Table BSC_METADATA_OPTIMIZER_PKG.clsTable)IS
l_origin_tables DBMS_SQL.VARCHAR2_TABLE;
l_stmt VARCHAR2(1000);
l_table_type varchar2(10);
l_prj_table varchar2(100);
BEGIN
  bsc_mo_helper_pkg.writeTmp('Inside Alter Tables for '||p_Table.name||' with data.count= '||p_table.data.count, FND_LOG.LEVEL_STATEMENT, true);
  IF (p_table.data.count=0) THEN
    bsc_mo_helper_pkg.writeTmp('Completed Alter Tables zero data count= ', FND_LOG.LEVEL_STATEMENT, true);
    return;
  END IF;
  l_origin_tables := BSC_DBGEN_UTILS.get_source_table_names(p_table.name);
  l_origin_tables(l_origin_tables.count) := p_table.name;
  FOR i IN p_table.data.first..p_table.data.last LOOP
    IF p_table.data(i).changeType='NEW' THEN -- new column, insert into db_tables_cols
      --alter all tables in l_origin_tables as they need this new column, eg, T, B and I tables if p_table is a T table
      bsc_mo_helper_pkg.writeTmp('Measure '||p_table.data(i).fieldName||' needs to be added ', FND_LOG.LEVEL_STATEMENT, false);
      FOR j in l_origin_tables.first..l_origin_tables.last LOOP
        l_table_type := BSC_DBGEN_UTILS.get_table_type(l_origin_tables(j));
        IF BSC_METADATA_OPTIMIZER_PKG.g_BSC_mv AND l_table_type='T' THEN -- T tables do not exist in MV arch.
          null;
        ELSIF Not bsc_mo_helper_pkg.table_column_exists(l_origin_tables(j), p_table.data(i).fieldName) THEN
          l_stmt := 'ALTER TABLE ' || l_origin_tables(j) || ' ADD '||p_table.data(i).fieldName||' NUMBER';
          bsc_mo_helper_pkg.writeTmp(l_stmt, FND_LOG.LEVEL_STATEMENT, false);
          BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, l_origin_tables(j));
          --IF B table is being altered,, B_PRJ table also needs to b altered
        END IF;
        IF BSC_MO_LOADER_CONFIG_PKG.isBasicTable(l_origin_tables(j)) THEN
          -- Alter B_PRJ Table if required
          l_prj_table := BSC_DBGEN_METADATA_READER.get_table_properties(l_origin_tables(j), BSC_DBGEN_STD_METADATA.BSC_B_PRJ_TABLE);
          if (l_prj_table is not null) then
            IF Not bsc_mo_helper_pkg.table_column_exists(l_prj_table, p_table.data(i).fieldName) THEN
              l_stmt := 'ALTER TABLE ' || l_prj_table || ' ADD '||p_table.data(i).fieldName||' NUMBER';
              bsc_mo_helper_pkg.writeTmp(l_stmt, FND_LOG.LEVEL_STATEMENT, false);
              BSC_MO_HELPER_PKG.Do_DDL(l_stmt, ad_ddl.alter_table, l_prj_table);
            END IF;
          end if;
          l_stmt := 'ALTER MATERIALIZED VIEW LOG ON ' || BSC_METADATA_OPTIMIZER_PKG.gBSCSchema||'.'||l_origin_tables(j)
                    || ' ADD ('||p_table.data(i).fieldName||')';
          BEGIN
            execute immediate l_stmt;
            EXCEPTION WHEN OTHERS THEN
              IF (SQLCODE=-12002 -- mv log does not exist
                  OR SQLCODE=-1430  --  ORA-01430: column being added already exists in table
                  OR SQLCODE=-12027) -- ORA-12027: duplicate filter column
              THEN
                null;
              ELSE
                bsc_mo_helper_pkg.writeTmp('Exception while adding measure to MV log '||l_stmt, FND_LOG.LEVEL_STATEMENT, true);
                RAISE;
              END IF;
          END;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
  bsc_mo_helper_pkg.writeTmp('Completed Alter Tables zero data count= ', FND_LOG.LEVEL_STATEMENT, true);
END;

/*
  AddPartitionCols
*/
PROCEDURE addPartitionCols(
  p_cols IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn)
IS
  dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
  dbColumn_null BSC_METADATA_OPTIMIZER_PKG.clsDBColumn := null;

BEGIN
  -- batch column
  dbColumn := dbColumn_null;
  dbColumn.columnName := BSC_DBGEN_STD_METADATA.BSC_BATCH_COLUMN_NAME;
  dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
  dbColumn.columnLength := 0;
  dbColumn.iskey := false;
  p_cols(p_cols.count) := dbColumn;

END;

--****************************************************************************
-- CrearTabla : CreateOneTable
-- DESCRIPTION:
-- Creates thegiven table in the database.
-- PARAMETERS:
-- Tabla: Table. It is an object with all inFORmation about the table
--****************************************************************************
PROCEDURE CreateOneTable(
  l_table_rec BSC_METADATA_OPTIMIZER_PKG.clsTable,
  TableTBSName IN VARCHAR2,
  IndexTBSName IN VARCHAR2,
  p_table_type IN VARCHAR2) IS

    Llave BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
    Dato BSC_METADATA_OPTIMIZER_PKG.clsDataField;
    colCampos BSC_METADATA_OPTIMIZER_PKG.tab_clsDBColumn;
    dbColumn BSC_METADATA_OPTIMIZER_PKG.clsDBColumn;
    msg VARCHAR2(100);
    uv_name VARCHAR2(100);
    l_stmt VARCHAR2(1000);
    l_index1 NUMBER;
    l_index2 NUMBER;
    l_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
    l_data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
    l_error varchar2(1000);
    dimTable VARCHAR2(100);
    columnSize NUMBER;
    l_temp1 NUMBER;
BEGIN
  IF (l_table_rec.isProductionTable) THEN
    return;
  END IF;
  l_keys := l_table_rec.keys;
  l_data := l_table_rec.data;
  sort_data_columns(l_data);
  IF l_table_rec.Type = 0 THEN
    --It is an input table
    --Create the table in the database
    colCampos.delete;
    --Keys
    l_index1 := l_keys.first;
    LOOP
      EXIT WHEN l_keys.count=0;
      dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
      Llave := l_keys(l_index1);
      l_temp1 := BSC_MO_HELPER_PKG.FindKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, Llave.keyName);
      dimTable := BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp1).name;
      dbColumn.columnName := Llave.keyName;
      dbColumn.columnType := GetDimKeyDataType(dimTable, 'USER_CODE', columnSize);
      dbColumn.columnLength := columnSize;
      dbColumn.isKey := TRUE;
      dbColumn.isTimeKey := FALSE;
      IF (colCampos.count >0) THEN
        colCampos(colCampos.last+1) := dbColumn;
      ELSE
        colCampos(0) := dbColumn;
      END IF;
      EXIT WHEN l_index1 = l_keys.last;
      l_index1 := l_keys.next(l_index1);
    END LOOP;
    --Year
    dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
    AddYearPeriodType(colCampos, l_table_rec.periodicity, true, l_table_rec.type);
    --Data colunms

    IF (l_data.count > 0) THEN
      l_index1 := l_data.first;
    END IF;
    LOOP
      EXIT WHEN l_data.count = 0;
      Dato := l_data (l_index1);
      dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
      dbColumn.columnName := Dato.fieldName;
      dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
      dbColumn.columnLength := 0;
      dbColumn.isKey := FALSE;
      colCampos(colCampos.last+1) := dbColumn;
      EXIT WHEN l_index1 = l_data.last;
      l_index1 := l_data.next(l_index1);
    END LOOP;
    CreateTableInDB(
	  l_table_rec.Name,
	  colCampos,
	  TableTBSName,
	  IndexTBSName,
	  l_table_rec,
          p_table_type);
  ELSE
    --It is a system table (base, temporal or summary)
    --BSC-MV Note: EDW logic need to be re-visisted IF in the future
    --EDW integration happens.EDW integration was never
    --released. I will apply the same logic even IF it is a EDW table
    --I will create only base tables.
    colCampos.delete;
    IF (l_keys.count>0) THEN
      l_index1 := l_keys.first;
    END IF;
    LOOP
      EXIT WHEN l_keys.count = 0;
      Llave := l_keys(l_index1);
      dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
      l_temp1 := BSC_MO_HELPER_PKG.FindKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, Llave.keyName);
      IF (l_temp1 = -1) THEN
        bsc_mo_helper_pkg.writeTmp('l_temp1=-1 in FindKeyIndex for key = '||Llave.keyName);
      END IF;
      dimTable := BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_temp1).name;
      dbColumn.columnName := Llave.keyName;
      dbColumn.columnTYpe := GetDimKeyDataType(dimTable, 'CODE', columnSize);
      dbColumn.columnLength := columnSize;
      dbColumn.isKey := TRUE;
      dbColumn.isTimeKey := FALSE;
      colCampos(colCampos.count) := dbColumn;
      EXIT WHEN l_index1 = l_keys.last;
      l_index1 := l_keys.next(l_index1);
    END LOOP;
    AddYearPeriodType(colCampos, l_table_rec.periodicity, false, l_table_rec.type);
    --BSC-MV Note: Need new column: PERIODICITY_ID
    --Periodicity_id
    --BSC AW- B tables for AW dont require Periodicity id
    IF BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV and l_table_rec.impl_type <> 2 THEN
      dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
      dbColumn.columnName := 'PERIODICITY_ID';
      dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
      dbColumn.columnLength := 0;
      dbColumn.isKey := TRUE;
      dbColumn.isTimeKey := TRUE;
      colCampos(colCampos.count) := dbColumn;
    END IF;

    IF (l_table_rec.impl_type = 2 ) THEN -- B table for AW
      AddAWColumns(colCampos, false);
    END IF;
    IF (l_data.count >0) THEN
      l_index1 := l_data.first;
    END IF;
    --Data columns
    LOOP
      EXIT WHEN l_data.count = 0;
      Dato := l_data (l_index1);
      dbColumn := bsc_mo_helper_pkg.new_clsDBColumn;
      dbColumn.columnName := Dato.fieldName;
      dbColumn.columnType := BSC_METADATA_OPTIMIZER_PKG.DTNumber;
      dbColumn.columnLength := 0;
      dbColumn.isKey := FALSE;
      colCampos(colCampos.last+1) := dbColumn;
      EXIT WHEN l_index1 = l_data.last;
      l_index1 := l_data.next(l_index1);
    END LOOP;
    IF (p_table_type='B') THEN
      AddPartitionCols(colCampos);
    END IF;
    CreateTableInDB (
	  l_table_rec.name,
	  colCampos,
	  TableTBSName,
	  IndexTBSName,
	  l_table_rec,
          p_table_type);
  END IF;
  EXCEPTION WHEN OTHERS THEN
	l_error := sqlerrm;
	FND_FILE.put_line(FND_FILE.LOG, 'Exception in CreateOneTable:'||l_error);
    fnd_message.set_name ('BSC', 'BSC_TABLENAME_CREATION_FAILED');
    fnd_message.set_token('TABLE_NAME', l_table_rec.name);
    bsc_mo_helper_pkg.terminateWithMsg(fnd_message.get);
	raise;
END;


--****************************************************************************
--  CrearTablasDB
--
--    DESCRIPTION:
--       Create all system tables in the database.
--****************************************************************************
PROCEDURE CreateAllTables IS
  l_table_rec BSC_METADATA_OPTIMIZER_PKG.clsTable;
  l_index NUMBER;
  arrProjTables DBMS_SQL.VARCHAR2_TABLE;
  numProjTables NUMBER := 0;
  lTablesCount   NUMBER := 0;
  l_counter NUMBER := 0;

  l_varchar_table1 dbms_sql.varchar2_table;
  l_varchar_table2 dbms_sql.varchar2_table;
BEGIN
  lTablesCount := BSC_METADATA_OPTIMIZER_PKG.gTables.count;
  IF (lTablesCount = 0 ) THEN
    RETURN;
  END IF;

  IF (lTablesCount > g_parallel_threshold) THEN
    g_parallelize := true;
    select max_processes into g_max_buckets from fnd_concurrent_queues where concurrent_queue_name='STANDARD' and application_id=0;
    g_max_buckets := g_max_buckets/2 ; -- consume only 1/2 max processes
    -- each table can have two indexes
    g_bucket_size := ceil(lTablesCount*2/g_max_buckets);
    -- assuming
    BSC_MO_HELPER_PKG.writeTmp('Bucket size = '||lTablesCount||'*2/('||g_max_buckets||') ='||g_bucket_size);
    if g_max_buckets > 1 then
      CreateDDLTable;
    else
      g_parallelize := false;
    end if;
  END IF;



  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Inside CreateAllTables');
  END IF;
  --BSC-MV Note: From this implementation only base tables are created
  --in the database. Also, FOR some special cases summary tables are created
  --(Example FOR projection in kpi tables because of targets at dIFferent levels)
  --Also in this procedure we handle the case when it is running FOR upgrade
  l_index := BSC_METADATA_OPTIMIZER_PKG.gTables.first;

  LOOP
    l_counter := l_counter + 1;
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Table # :'||l_counter||' out of :'||BSC_METADATA_OPTIMIZER_PKG.gTables.count
        ||'... '||BSC_METADATA_OPTIMIZER_PKG.gTables(l_index).name||
        ' time is '||to_Char(sysdate, 'hh24:mi:ss'));
    END IF;
    l_table_rec := BSC_METADATA_OPTIMIZER_PKG.gTables(l_index);
    IF (l_table_rec.isProductionTable AND l_table_rec.isProductionTableAltered) THEN
      add_columns_to_tables(l_table_rec);
    END IF;

    IF l_table_rec.isProductionTable AND BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 1 And l_table_rec.upgradeFlag <> 1 THEN
      null;
    ELSIF l_table_rec.TYPE = 0 THEN
      --Input table
      IF BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 1 And l_table_rec.upgradeFlag = 1 THEN
        --In upgrade mode, the input table already exist, we cannot drop/create
        NULL;
      ELSE
        BSC_MO_HELPER_PKG.writeTmp('Calling CreateOneTable1 for '||l_table_rec.name);
        CreateOneTable(l_table_rec, BSC_METADATA_OPTIMIZER_PKG.gInputTableTbsName, BSC_METADATA_OPTIMIZER_PKG.gInputIndexTbsName, 'I');
      END IF;
    ELSIF BSC_MO_LOADER_CONFIG_PKG.isBasicTable(l_table_rec.name) THEN
      --Base table
      IF BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 1 and l_table_rec.isProductionTable THEN
        --In upgrade mode, we only need to add periodicity id to the table/index
        BSC_MO_HELPER_PKG.writeTmp('Calling AddPeriodicityId2 for '||l_table_rec.name);
        AddPeriodicityId (l_table_rec);
      ELSE
        CreateOneTable(l_table_rec, BSC_METADATA_OPTIMIZER_PKG.gBaseTableTbsName, BSC_METADATA_OPTIMIZER_PKG.gBaseIndexTbsName, 'B');
        BSC_MO_HELPER_PKG.writeTmp('Calling CreateOneTable3 for '||l_table_rec.name);
      END IF;
    ELSE
      --Summary table
      IF Not BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV THEN
        BSC_MO_HELPER_PKG.writeTmp('Calling CreateOneTable4 for '||l_table_rec.name);
        CreateOneTable(l_table_rec, BSC_METADATA_OPTIMIZER_PKG.gSummaryTableTbsName, BSC_METADATA_OPTIMIZER_PKG.gSummaryIndexTbsName, 'S');
      ELSE
        BSC_MO_HELPER_PKG.writeTmp('MV architecture, Not Calling CreateOneTable5 for '||l_table_rec.name);
        --BSC-MV New architecture: None of the summary tables are needed.
        --The only tables we need to create are the tables created FOR projection
        IF l_table_rec.projectionTable is not null THEN
          -- Need to check this because one projection table corresponds
          -- to many summary tables (same level but dIFferent periodicities)
          IF Not bsc_mo_helper_pkg.searchStringExists(arrProjTables, arrProjTables.count, l_table_rec.projectionTable) THEN
            CreateProjTable(l_table_rec);
            arrProjTables(arrProjTables.count) := l_table_rec.projectionTable;
            numProjTables := numProjTables + 1;
          END IF;
        END IF;

        IF BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 1 And l_table_rec.upgradeFlag = 1 THEN
          --In upgrade mode we need to drop the summary tables used
          --by production indicators
          BSC_MO_HELPER_PKG.dropTable(l_table_rec.Name);
        END IF;
      END IF;
    END IF;
    EXIT WHEN l_index = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
    l_index := BSC_METADATA_OPTIMIZER_PKG.gTables.next(l_index);
  END LOOP;
  commit;

  IF (g_parallelize) THEN -- tables need to be created by child processes
    spawn_child_processes;
  END IF;

  bsc_mo_helper_pkg.writeTmp('updating properties in bsc_db_tables, count='||g_update_tables.count);
  FOR i IN 1..g_update_tables.count LOOP
    l_varchar_table1(i) := g_update_tables(i).table_name;
    l_varchar_table2(i) := g_update_tables(i).property;
     bsc_mo_helper_pkg.writeTmp('table_name='||l_varchar_table1(i)||', property='||l_varchar_table2(i));
  END LOOP;
  -- Update Table Properties
  FORALL i IN 1..g_update_tables.count
    UPDATE BSC_DB_TABLES
       SET PROPERTIES=PROPERTIES||l_varchar_table2(i)||BSC_DBGEN_STD_METADATA.BSC_PROPERTY_SEPARATOR
     WHERE table_name = l_varchar_table1(i);

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('Completed CreateAllTables');
  END IF;
END ;



function get_child_job_status(
p_job_status_table varchar2,
p_object_name varchar2,
p_id out nocopy dbms_sql.number_table,
p_job_id out nocopy dbms_sql.number_table,
p_status out nocopy dbms_sql.varchar2_table,
p_message out nocopy dbms_sql.varchar2_table,
p_number_jobs out nocopy number
)return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt VARCHAR2(1000);
Begin
  if p_object_name is null then
    l_stmt:='select id,job_id,status,message from '||p_job_status_table;
  else
    l_stmt:='select id,job_id,status,message from '||p_job_status_table||' where object_name=:1';
  end if;
  p_number_jobs:=1;
  if bsc_metadata_optimizer_pkg.g_debug then
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp(l_stmt||' '||p_object_name);
	END IF;
  end if;
  if p_object_name is null then
    open cv for l_stmt;
  else
    open cv for l_stmt using p_object_name;
  end if;
  loop
    fetch cv into p_id(p_number_jobs),p_job_id(p_number_jobs),
    p_status(p_number_jobs),p_message(p_number_jobs);
    exit when cv%notfound;
    p_number_jobs:=p_number_jobs+1;
  end loop;
  close cv;
  p_number_jobs:=p_number_jobs-1;
  if bsc_metadata_optimizer_pkg.g_debug then
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('The job status');
	END IF;
    for i in 1..p_number_jobs loop
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp(p_id(i)||' '||p_job_id(i)||' '||p_status(i)||' '||p_message(i));
	END IF;
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
	  bsc_mo_helper_pkg.writeTmp('Exception in get_child_job_status '||g_status_message, fnd_log.level_statement, TRUE);
  return false;
End;


function check_all_child_jobs(
p_job_status_table varchar2,
p_job_id dbms_sql.number_table,
p_number_jobs number,
p_object_name varchar2
) return boolean is
l_id dbms_sql.number_table;
l_job_id dbms_sql.number_table;
l_status dbms_sql.varchar2_table;
l_message dbms_sql.varchar2_table;
l_number_jobs number;
Begin
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
   bsc_mo_helper_pkg.writeTmp('Starting check_all_child_jobs');
	END IF;

  if get_child_job_status(
    p_job_status_table,
    p_object_name,
    l_id,
    l_job_id,
    l_status,
    l_message,
    l_number_jobs)=false then
    return false;
  end if;
  for i in 1..l_number_jobs loop
    if l_status(i)='ERROR' then
      return false;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  bsc_mo_helper_pkg.writeTmp('Exception in check_all_child_jobs '||g_status_message, fnd_log.level_statement, TRUE);
  return false;
End;



-- create the tables stored in bsc_tmp_ddl_table
-- with bucket_id = pStripe


PROCEDURE create_tables_spawned(
            Errbuf         out NOCOPY Varchar2,
            Retcode        out NOCOPY Varchar2,
            pStripe        IN NUMBER,
            pTableName     IN VARCHAR2) IS
BEGIN
  g_ddl_table_name :=pTableName;
  fnd_file.put_names('gdb.log', 'gdb.out', null);
  create_tables_spawned(pStripe);

END;

procedure writelog(pmsg in varchar2) is
begin
  fnd_file.put_line(FND_FILE.log, pmsg);
end;

-- create the tables stored in bsc_tmp_mo_create_table
-- with bucket_id = pStripe

PROCEDURE create_tables_spawned(pStripe IN NUMBER) IS
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt VARCHAR2(100) := ' SELECT object_name, object_ddl, object_type FROM '|| g_ddl_table_name||' WHERE bucket_id = :1';
l_object_name VARCHAR2(100);
l_object_ddl VARCHAR2(4000);
l_object_type VARCHAR2(100);
l_error varchar2(4000);
BEGIN

     OPEN cv FOR l_stmt USING pStripe;
     LOOP
        FETCH cv INTO l_object_name, l_object_ddl, l_object_type;
        EXIT WHEN cv%NOTFOUND;
        BEGIN
           null;
            --BSC_MO_HELPER_PKG.Do_DDL('drop table '||l_table_name, ad_ddl.drop_table, l_table_name);
            EXCEPTION WHEN OTHERS THEN
                null;
        END;

	   BEGIN
	    IF (l_object_type='TABLE') THEN
          BSC_MO_HELPER_PKG.Do_DDL(l_object_ddl, ad_ddl.create_table, l_object_name);
        ELSE
	       BSC_MO_HELPER_PKG.Do_DDL(l_object_ddl, ad_ddl.create_index, l_object_name);
	    END IF;
	    writelog(l_object_type ||' '||l_object_name||' created successfully.');
        EXCEPTION WHEN OTHERS THEN
	    l_error := sqlerrm;
	    execute immediate 'UPDATE  '||g_ddl_table_name||' set status = :1 where bucket_id = :2 and object_name = :3'
		using 'ERROR', pStripe, l_object_name;
	   END;
     END LOOP;
     CLOSE cv;
END;


FUNCTION check_job_status(p_job_id number) RETURN varchar2 is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number;
l_stmt VARCHAR2(100);
l_fail number;
Begin
  l_stmt:='select 1, failures from all_jobs where job=:1';
  OPEN cv FOR l_stmt using p_job_id;
  fetch cv into l_var, l_fail;
  close cv;
  IF l_var=1 THEN -- still in process or failure
    IF (l_fail IS NULL ) THEN
      RETURN 'Y';--job running
    ELSE
      return 'ERROR';
    END IF;
  ELSE
    RETURN 'N';
  END IF;
Exception when others THEN
  g_status_message:=sqlerrm;
  bsc_mo_helper_pkg.writeTmp('Exception in check_job_status '||g_status_message, fnd_log.level_statement, TRUE);
  RETURN null;
END;

FUNCTION check_conc_process_status(p_conc_id number) RETURN varchar2 is
l_phase varchar2(400);
l_status varchar2(400);
l_dev_phase  varchar2(400);
l_dev_status varchar2(400);
l_message varchar2(4000);
l_conc_id number;
Begin
  l_conc_id:=p_conc_id;
  IF FND_CONCURRENT.get_request_status(l_conc_id,null,null,l_phase,l_status,
    l_dev_phase,l_dev_status,l_message)=FALSE THEN
    RETURN 'N';
  END IF;
  IF l_dev_phase is null or l_dev_phase='COMPLETE' THEN
    RETURN 'N';--there is no more this process
  ELSE
    RETURN 'Y';--still running
  END IF;
Exception when others THEN

  RETURN null;
END;


FUNCTION wait_on_jobs(
p_job_id DBMS_SQL.NUMBER_TABLE,
p_number_jobs number,
p_sleep_time number,
p_thread_type varchar2
) RETURN boolean is
l_found boolean;
l_status varchar2(2);
l_job_status DBMS_SQL.VARCHAR2_TABLE;
l_error VARCHAR2(1000);

l_start date := sysdate;
Begin

  IF p_number_jobs<=0 THEN
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Done wait_on_jobs, zero count');
    END IF;
    RETURN TRUE;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside wait_on_jobs, jobs are ');
  END IF;
  bsc_mo_helper_pkg.write_this(p_job_id);
  FOR i in 1..p_job_id.count LOOP
    l_job_status(i):='Y';
  END LOOP;
  LOOP
    l_found:=FALSE;
    -- ARUN TBC
    IF ((sysdate - l_start)*86400 > 900) THEN -- 15 mins for testing
      return false;
    END IF;
    DBMS_LOCK.SLEEP(g_sleep_time); -- ignore p_sleep_time
    FOR i in 1..p_job_id.count LOOP
      IF l_job_status(i)='Y' THEN
        IF p_thread_type='JOB' THEN
          l_status:=check_job_status(p_job_id(i));
        ELSE
          l_status:=check_conc_process_status(p_job_id(i));
        END IF;
        bsc_mo_helper_pkg.writeTmp('status returned for '||p_job_id(i)||':'||l_status||' l_job_status='||l_job_status(i));
        IF l_status is null THEN
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            bsc_mo_helper_pkg.writeTmp('Compl  wait_on_jobs, returning false');
          END IF;
          RETURN FALSE;
        ELSIF l_status='Y' THEN
          l_found:=TRUE;
        ELSE
          IF l_job_status(i)='Y' THEN
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
              bsc_mo_helper_pkg.writeTmp('Job '||p_job_id(i)||' has terminated '||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
            END IF;
            l_job_status(i):='N';
          ELSE -- error
            l_job_status(i) := 'ERROR';
            IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
               bsc_mo_helper_pkg.writeTmp('Compl wait_on_jobs, returning false');
             END IF;
             return false;
          END IF;
        END IF;
      END IF;
    END LOOP;
    IF l_found=FALSE THEN
      exit;
    END IF;

  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
     bsc_mo_helper_pkg.writeTmp('Compl wait_on_jobs, returning true');
  END IF;
  RETURN TRUE;
Exception when others THEN

  RETURN FALSE;
END;

FUNCTION check_ora_job_parameters return boolean IS
l_value NUMBER;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
CURSOR cParam(pParam IN VARCHAR2) IS
select value from v$parameter param
where param.name = pParam;

BEGIN

  OPEN cParam('job_queue_processes');
  FETCH cParam INTO l_value;
  CLOSE cParam;
  IF (l_value is null OR l_value = 0) THEN
    -- dont override system settings
    g_parallelize := false;
    return false;
  END IF;
  OPEN cParam('job_queue_interval');
  FETCH cParam INTO l_value;
  IF (l_value is null OR l_value = 0) THEN
    -- dont override system settings
    g_parallelize := false;
    return false;
  END IF;
  CLOSE cParam;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Done with check_ora_job_parameters, returning true');
  END IF;
  return true;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Exception in check_ora_job_parameters : '||sqlerrm, fnd_log.level_statement, TRUE);
    return false;
END;



PROCEDURE spawn_child_processes IS

l_try_serial boolean := false;
l_job_id DBMS_SQL.NUMBER_TABLE;
L_BSC_SHORT_NAME varchar2(10);
l_sleep_time NUMBER := 90 ; -- 1.5 minutes
errBuf VARCHAR2(100);
retCode VARCHAR2(100);
--L_NUMBER_JOBS NUMBER;

l_status boolean;
p_job_status_table VARCHAR2(1000);
l_error varchar2(1000);
BEGIN


   /*
   we will go FOR active polling. this main session will sleep FOR g_sleep_time and THEN
   wake up and check the status of each of the jobs. IF they are done, we can THEN proceed.
   DBMS_JOB.SUBMIT(id,'test_pack_2.run_pack;')
   */

   g_sleep_time := 5;-- check every 5 seconds

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside spawn_child_processes, system time is '||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
  END IF;

        -- INsert into Database
    --forall and execute immediate not compatible with 8i
    FORALL i IN g_ddl_bucket_id.first..g_ddl_bucket_id.last
        execute immediate 'INSERT INTO '||g_ddl_table_name||'(bucket_id, object_name, object_ddl, object_type)
        VALUES (:1, :2, :3, :4)'
        USING g_ddl_bucket_id(i), g_ddl_object(i), g_ddl_object_ddl(i), g_ddl_object_type(i);

    commit;

   bsc_metadata_optimizer_pkg.g_debug := true;
   bsc_metadata_optimizer_pkg.gThreadType := 'JOB';

   IF (fnd_global.CONC_REQUEST_ID <> -1) THEN
        bsc_metadata_optimizer_pkg.gThreadType := 'CONC';
        l_bsc_short_name:='BSC';
   ELSE
	IF (check_ora_job_parameters = false) THEN
		l_try_serial := true;
	END IF;
   END IF;

    bsc_mo_helper_pkg.writeTmp(
			' Type of thread='||bsc_metadata_optimizer_pkg.gThreadType);

   IF l_try_serial THEN
	bsc_mo_helper_pkg.writeTmp('Single thread ');
   ELSE
        bsc_mo_helper_pkg.writeTmp('Launch multiple threads ('||g_buckets||'). ');
   END IF;


   -- buckets are striped starting with 1 sequentially
   FOR bucket_num in 1..g_buckets LOOP

     l_job_id(bucket_num):=null;
     begin
       IF bsc_metadata_optimizer_pkg.gThreadType='CONC' THEN
         l_job_id(bucket_num):=FND_REQUEST.SUBMIT_REQUEST(
             application=>l_bsc_short_name,
             program=>g_conc_short_name,
             argument1=>bucket_num,
             argument2=>g_ddl_table_name);
         commit;
           bsc_mo_helper_pkg.writeTmp('Concurrent Request '||l_job_id(bucket_num)||' launched at '||
                to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
         IF l_job_id(bucket_num)<=0 THEN
           l_try_serial:=TRUE;
         END IF;
       ELSIF l_try_serial = false THEN --not  a concurrent program and job init.ora params ok
	 bsc_mo_helper_pkg.writeTmp('Not a Concurrent program, trying DBMS JOBS');
         DBMS_JOB.SUBMIT(l_job_id(bucket_num),
               'BSC_MO_DB_PKG.create_tables_spawned('||bucket_num||');',
               sysdate + (10/86400));  -- next second
         commit;--this commit is very imp
         bsc_mo_helper_pkg.writeTmp(' submitted dbms_job : id is '||l_job_id(bucket_num));
           bsc_mo_helper_pkg.writeTmp('Job '||l_job_id(bucket_num)||' launched '||
		to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
         IF l_job_id(bucket_num)<=0 THEN
           l_try_serial:=TRUE;
         END IF;
       END IF;
       exception when others THEN
         bsc_mo_helper_pkg.writeTmp('Error launching parallel slaves '||sqlerrm||'. Attempt serial load', fnd_log.level_statement, TRUE);
       l_try_serial:=TRUE;
     END;

     IF l_try_serial THEN
       IF bsc_metadata_optimizer_pkg.g_debug THEN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
         bsc_mo_helper_pkg.writeTmp('Attempt serial load');
	END IF;
       END IF;
       create_tables_spawned(bucket_num); -- serial
     END IF;
   END LOOP;


   IF (NOT l_try_serial) THEN
	   --wait to make sure that all threads launched are complete.
	   IF wait_on_jobs(
	     l_job_id,
	     g_buckets,
	     l_sleep_time,
	     bsc_metadata_optimizer_pkg.gThreadType)=FALSE THEN -- error
         l_status:=false;
         bsc_mo_helper_pkg.TerminateWithMsg('One or more spawned programs failed');
         raise bsc_metadata_optimizer_pkg.optimizer_exception;
	   END IF;

	/*IF l_status THEN
	     --just to note. l_job_id is not used in check_all_child_jobs

	     IF check_all_child_jobs(p_job_status_table,l_job_id,
	       g_buckets,null)=FALSE THEN
	       l_status:=FALSE;
	       RETURN;
	     END IF;
	   END IF;
	*/
   END IF;
   bsc_mo_helper_pkg.do_ddl('drop table '||g_ddl_table_name, ad_ddl.drop_table, g_ddl_table_name);

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
   bsc_mo_helper_pkg.writeTmp('Compl spawn_child_processes, system time is '||to_char(sysdate, 'mm/dd/yyyy hh24:mi:ss'));
	END IF;

   EXCEPTION WHEN OTHERS THEN

	bsc_mo_helper_pkg.writeTmp('Exception in spawn_child_processes :'||sqlerrm, fnd_log.level_statement, TRUE);
	raise;

END;

END BSC_MO_DB_PKG;

/
