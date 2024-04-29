--------------------------------------------------------
--  DDL for Package Body BSC_MO_INDICATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_MO_INDICATOR_PKG" AS
/* $Header: BSCMOIDB.pls 120.4.12000000.2 2007/01/29 12:44:12 abatham ship $ */
g_newline VARCHAR2(10):= '
';
g_error VARCHAR2(1000);
gRecDims VARCHAR2(1000) := null;
g_current_indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
g_current_dimset number;


TYPE cNumMeasuresMap IS RECORD(
value varchar2(2000));
TYPE tab_cNumMeasuresMap is table of cNumMeasuresMap index by VARCHAR2(300);

g_objective_measures tab_cNumMeasuresMap;
g_objective_measures_inited boolean := false;


Function GetProjectionTableName(TableName IN VARCHAR2) RETURN VARCHAR2 IS
    pos NUMBER;
    PTName VARCHAR2(100);

BEGIN
    pos := InStr(TableName, '_', -1);
    If pos > 0 Then
        PTName := substr(TableName, 1, pos) || 'PT';
    Else
        PTName := TableName || '_PT';
    End If;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Done with GetProjectionTable, returning '||PTName);
	END IF;

    return PTName;

    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
        bsc_mo_helper_pkg.TerminateWithMsg( 'Exception in GetProjectionTableName : '||g_error);
        raise;
End ;
--****************************************************************************
--GetFreeDivZeroExpression
--
--***************************************************************************
Function GetFreeDivZeroExpression(expression IN VARCHAR2) RETURN VARCHAR2 IS
l_stmt varchar2(1000);
l_res varchar2(1000);
cv CurTyp;
CURSOR cExp IS
SELECT BSC_UPDATE_UTIL.Get_Free_Div_Zero_Expression(expression) NEWEXPRESSION FROM DUAL;

BEGIN

    open cExp;
    fetch cExp into l_res;
    close cExp;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp( 'Done with GetFreeDivZeroExpression, returning '||l_res);
	END IF;

    return l_res;
    EXCEPTION WHEN OTHERS THEN
	g_error := sqlerrm;
	bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetFreeDivZeroExpression :' ||g_error);
	raise;
End;

--****************************************************************************
--  getTableLevel
--
--    DESCRIPTION:
--       This function is used only in the BSC-MV Architecture.
--****************************************************************************

Function getTableLevel(TableName IN VARCHAR2, colTables BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable) RETURN NUMBER IS
    l_level NUMBER;
    sourceTable VARCHAR2(100);
    l_index NUMBER;
BEGIN
    l_index := BSC_MO_HELPER_PKG.findIndex(colTables, TableName);
    sourceTable := colTables(l_index).originTable;
    If sourceTable IS NOT NULL Then
        l_level := 1 + getTableLevel(sourceTable, colTables);
    Else
        l_level := 1;
    End If;
    return l_level;
   EXCEPTION WHEN OTHERS THEN
     g_error := sqlerrm;
     bsc_mo_helper_pkg.writeTmp('Exception, tableName='||TableName||' colTables=', FND_LOG.LEVEL_EXCEPTION, true);
     bsc_mo_helper_pkg.write_this(colTables, FND_LOG.LEVEL_EXCEPTION, true);
     bsc_mo_helper_pkg.TerminateWithMsg('Exception in getTableLevel : '||g_error);
     raise;
End;

--***************************************************************************
--FindDimensionGroupIndexForKey
--
--  DESCRIPTION:
--     Returns the index of the dril family of the collection
--     p_dimension_families which the given dimension belongs to.
--
--  PARAMETERS:
--     p_dimension_families: drills families collection
--     Key: dimension key
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function FindDimensionGroupIndexForKey(p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels, p_Key IN VARCHAR2) return NUMBER IS
    iDimensionLevels NUMBER;
    DimensionLevels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
    Dril BSC_METADATA_OPTIMIZER_PKG.clsLevels;
    i NUMBER;

    l_groups DBMS_SQL.NUMBER_TABLE;
    l_group_id NUMBER;

BEGIN
  IF (p_dimension_families.count =0) THEN
    return -1;
  END IF;
  l_groups := BSC_MO_HELPER_PKG.getGroupIds(p_dimension_families);
  iDimensionLevels := l_groups.first;
  LOOP
    EXIT WHEN l_groups.count = 0;
    l_group_id := l_groups(iDimensionLevels);
    DimensionLevels := BSC_MO_HELPER_PKG.get_tab_clsLevels (p_dimension_families, l_group_id);
    IF (DimensionLevels.count >0) THEN
       i := DimensionLevels.first;
       LOOP
         Dril := DimensionLevels(i);
         If Dril.keyName = p_Key Then
           return iDimensionLevels;
         END IF;
    	 EXIT WHEN i=DimensionLevels.last;
         i := DimensionLevels.next(i);
      END LOOP;
    END IF;
    EXIT WHEN iDimensionLevels= l_groups.last;
    iDimensionLevels := l_groups.next(iDimensionLevels);
  END LOOP;
  return -1;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.writeTmp('Exception, p_key='||p_key||', Dimension families=', FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.write_this(p_dimension_families, FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in FindDimensionGroupIndexForKey : '||g_error);
    raise;
End;

FUNCTION get_n_parents(p_s_table IN VARCHAR2,
                        p_s_table_list BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable,
						p_level_num IN NUMBER)
RETURN DBMS_SQL.VARCHAR2_TABLE IS
  l_level NUMBER;
  sourceTable VARCHAR2(100);
  l_index NUMBER;
  l_table_name VARCHAR2(400);
  l_n_parents DBMS_SQL.VARCHAR2_TABLE ;
BEGIN
  l_n_parents(0) := p_s_table;
  l_table_name := p_s_table;
  FOR i IN 1..p_level_num LOOP
    l_index := BSC_MO_HELPER_PKG.findIndex(p_s_table_list, l_table_name);
    l_table_name  := p_s_table_list(l_index).originTable;
    IF (l_table_name IS NULL) THEN
      return l_n_parents;
    END IF;
    l_n_parents(l_n_parents.count) := l_table_name;
  END LOOP;
  return l_n_parents;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.writeTmp('Exception, p_s_table='||p_s_table||', p_s_table_list=', FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.write_this(p_s_table_list, FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in get_n_parents : '||g_error);
    raise;

END;

-- P1 4148992 for query configured in bsc_kpi_data_tables
--
PROCEDURE find_join_betweens_levels(p_key IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField,
   p_zmv_key IN BSC_METADATA_OPTIMIZER_PKG.clsKeyField,
   p_dimensions IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
   p_join_level OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
   p_join_parent OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
   p_join_parent_fk OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE)
IS
cursor cJoin (p_indicator NUMBER, p_dimset NUMBER, p_level_name VARCHAR2) IS
select distinct levels.level_table_name child_level, parent_levels.level_table_name parent_level,
relation_col parent_fk, level
from bsc_sys_dim_level_rels  rels,
bsc_sys_dim_levels_b levels,
bsc_sys_dim_levels_b parent_levels,
bsc_kpi_dim_levels_b kpi_levels
where rels.dim_level_id = levels.dim_level_id
and levels.level_table_name = kpi_levels.level_table_name
and rels.parent_dim_level_id = parent_levels.dim_level_id
and kpi_levels.indicator = p_indicator
and kpi_levels.dim_set_id = p_dimset
connect by prior rels.dim_level_id||rels.relation_type = rels.parent_dim_level_id||1 -- relation_type=1
start with parent_dim_level_id = (select dim_level_id from bsc_sys_dim_levels_b where level_table_name = p_level_name)
order by level;

l_dim VARCHAR2(100);
l_parent VARCHAR2(100);
l_dim_fk VARCHAR2(100);

l_dim_group_index number ;
l_dimension_levels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
l_index NUMBER;
l_level_table_high VARCHAR2(100);
l_level_table_low VARCHAR2(100);
BEGIN
  bsc_mo_helper_pkg.writeTmp('In Find join betweeen levels, p_key='||p_key.keyName||', p_zmv_key='||p_zmv_key.keyName, FND_LOG.LEVEL_STATEMENT, false);
  l_dim_group_index := FindDimensionGroupIndexForKey(p_dimensions, p_key.KeyName);
  l_dimension_levels := BSC_MO_HELPER_PKG.get_Tab_clsLevels(p_dimensions, l_dim_group_index) ;
  -- Find the dimension level for the lower level key
  l_index := BSC_MO_HELPER_PKG.FindIndex(l_dimension_levels,p_key.KeyName);
  l_level_table_high := l_dimension_levels(l_index).dimTable;
  l_index := BSC_MO_HELPER_PKG.FindIndex(l_dimension_levels,p_zmv_key.KeyName);
  l_level_table_low := l_dimension_levels(l_index).dimTable;
  bsc_mo_helper_pkg.writeTmp('l_level_table_high='||l_level_table_high||', l_level_table_low='||l_level_table_low, FND_LOG.LEVEL_STATEMENT, false);
  OPEN cJoin(g_current_indicator.code, g_current_dimset, l_level_table_high);
  LOOP
    FETCH cJoin INTO l_dim, l_parent, l_dim_fk, l_index;
    EXIT WHEN cJoin%NOTFOUND;
    EXIT WHEN l_dim_fk=p_zmv_key.keyName;
    p_join_level(p_join_level.count) := l_dim;
    p_join_parent(p_join_parent.count) := l_parent;
    p_join_parent_fk(p_join_parent_fk.count) := l_dim_fk;
  END LOOP;
  CLOSE cJoin;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in find_join_betweens_levels:'||sqlerrm);
    raise;
END;

PROCEDURE get_join_info(p_keys IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
p_zmv_keys IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
p_zero_code_states IN DBMS_SQL.NUMBER_TABLE,
p_dimensions IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
p_join_dimensions OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
p_join_parents OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
p_join_dimension_fk OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE,
p_zmv_fk OUT NOCOPY DBMS_SQL.VARCHAR2_TABLE) IS
 l_join_dimensions DBMS_SQL.VARCHAR2_TABLE;
 l_join_parent DBMS_SQL.VARCHAR2_TABLE;
 l_join_parent_fk DBMS_SQL.VARCHAR2_TABLE;
 l_stack varchar2(32000);
BEGIN
  FOR i IN p_keys.first..p_keys.last LOOP
    bsc_mo_helper_pkg.writeTmp('p_keys('||i||')='||p_keys(i).keyName, FND_LOG.LEVEL_STATEMENT, false);
    IF (p_keys(i).keyName <> p_zmv_keys(i).keyName AND p_zero_code_states(i) =0) THEN
      bsc_mo_helper_pkg.writeTmp('Find join betweeen levels', FND_LOG.LEVEL_STATEMENT, false);
      find_join_betweens_levels(
	      p_keys(i),
		  p_zmv_keys(i),
		  p_dimensions,
	      l_join_dimensions,
          l_join_parent ,
          l_join_parent_fk );
      bsc_mo_helper_pkg.writeTmp('Found join betweeen levels ', FND_LOG.LEVEL_STATEMENT, false);
      bsc_mo_helper_pkg.writeTmp('l_join_dimensions are ', FND_LOG.LEVEL_STATEMENT, false);
      bsc_mo_helper_pkg.write_this(l_join_dimensions, FND_LOG.LEVEL_STATEMENT, false);
      bsc_mo_helper_pkg.writeTmp('l_join_parents are ', FND_LOG.LEVEL_STATEMENT, false);
      bsc_mo_helper_pkg.write_this(l_join_parent, FND_LOG.LEVEL_STATEMENT, false);
      bsc_mo_helper_pkg.writeTmp('l_join_parent_fk are ', FND_LOG.LEVEL_STATEMENT, false);
      bsc_mo_helper_pkg.write_this(l_join_parent_fk, FND_LOG.LEVEL_STATEMENT, false);
      IF (l_join_dimensions.count>0) THEN
      FOR j IN l_join_dimensions.first..l_join_dimensions.last LOOP
        p_join_dimensions(p_join_dimensions.count) := l_join_dimensions(j);
        p_join_parents(p_join_parents.count) := l_join_parent(j);
        p_join_dimension_fk(p_join_dimension_fk.count) := l_join_parent_fk(j);
        p_zmv_fk(p_zmv_fk.count) := p_zmv_keys(i).keyName;
      END LOOP;
      END IF;
    END IF;
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('p_keys, p_zmv_keys, p_zero_code_states, p_dimensions in order', FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.write_this(p_keys, FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.write_this(p_zmv_keys, FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.write_this(p_zero_code_states, FND_LOG.LEVEL_EXCEPTION, true);
    bsc_mo_helper_pkg.write_this(p_dimensions, FND_LOG.LEVEL_EXCEPTION, true);
	bsc_mo_helper_pkg.TerminateWithMsg('Exception in get_join_info:'||sqlerrm);
    raise;
END;

--****************************************************************************
--  optimize_zmv_clause
--  Bug fix for : 3944813
--    DESCRIPTION:
--       This function is to generate optimized SQL statements for iViewer.
--       We will reuse ZMVs from lower levels to speed up the iViewer query
--       performance. For eg. if MV levels=2 and an iViewer zero code query
--       is on level 3, we redirect the query to the lower level ZMV to use
--       the aggregated results from the lower level. We will need to join to
--       dimensions levels.
--****************************************************************************
FUNCTION optimize_zmv_clause(p_dimensions IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
                             p_s_table_list IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable,
                             p_s_table IN VARCHAR2,
							 p_table_level IN NUMBER,
							 p_keys IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
							 p_zero_code_states IN DBMS_SQL.NUMBER_TABLE,
							 p_system_levels IN NUMBER,
							 p_sql_stmt IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
  l_nlevel_parents DBMS_SQL.VARCHAR2_TABLE;
  l_highest_table_with_zmv VARCHAR2(400);
  l_zmv_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  b_zmv_exists boolean := false;
  l_zmv VARCHAR2(400);

  l_dim_group_index NUMBER;
  l_index NUMBER;
  l_dimension_levels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;

  CURSOR cParentFK(p_lower_dim_table IN VARCHAR2, p_higher_dim_table IN VARCHAR2) IS
  SELECT RELATION_COL
  FROM BSC_SYS_DIM_LEVEL_RELS RELS, BSC_SYS_DIM_LEVELS_B LVLA, BSC_SYS_DIM_LEVELS_B LVLB
  WHERE LVLA.level_table_name = p_lower_dim_table
  AND LVLB.level_table_name = p_higher_dim_table
  AND LVLA.dim_level_id = rels.dim_level_id
  AND LVLB.dim_level_id = rels.parent_dim_level_id;

  b_dimensions_joined boolean := true;


  l_select_keys_clause VARCHAR2(4000);
  l_select_rest VARCHAR2(4000);
  l_from_clause VARCHAR2(4000);
  l_where_clause VARCHAR2(4000);
  l_group_by_clause VARCHAR2(4000);
  b_zero_code_key_exists boolean :=false;
  l_join_dimensions DBMS_SQL.VARCHAR2_TABLE;
  l_join_dimensions_fk DBMS_SQL.VARCHAR2_TABLE;
  l_join_parents DBMS_SQL.VARCHAR2_TABLE;
  l_zmv_fk DBMS_SQL.VARCHAR2_TABLE;

BEGIN
  IF (p_table_level<=p_system_levels) THEN
    return false;
  END IF;
  -- note that get_n_parents returns the current s_table at position 0, and then its parents
  -- at positions 1, 2 etc
  bsc_mo_helper_pkg.writeTmp('Inside Optimize ZMV clause, p_table_level='||p_table_level||', p_system_levels='||p_system_levels, FND_LOG.level_Statement, false);
  bsc_mo_helper_pkg.writeTmp('Zero Code states = ', FND_LOG.level_Statement, false);
  bsc_mo_helper_pkg.write_this(p_zero_code_states, FND_LOG.level_Statement, false);
  l_select_rest := p_sql_stmt;
  l_nlevel_parents := get_n_parents(p_s_table, p_s_table_list, p_table_level-p_system_levels);
  bsc_mo_helper_pkg.write_this(l_nlevel_parents, FND_LOG.level_Statement, false);
  IF l_nlevel_parents.count = 1 THEN -- no parents, only 1 level, itself
    bsc_mo_helper_pkg.writeTmp('Completed Optimize ZMV clause', FND_LOG.level_Statement, false);
    return false;
  END IF;
  l_highest_table_with_zmv := l_nlevel_parents(l_nlevel_parents.last);
  -- BSC Multiple Optimizers to run
  --l_zmv_keys := BSC_MO_HELPER_PKG.getAllKeyFields(l_highest_table_with_zmv);
  l_index := BSC_MO_HELPER_PKG.findIndex(p_s_table_list, l_highest_table_with_zmv);
  bsc_mo_helper_pkg.writeTmp('Highest table with zmv is '||l_highest_table_with_zmv||', with index='||l_index, FND_LOG.level_Statement, false);
  l_zmv_keys := p_s_table_list(l_index).keys;

  IF (p_keys.count <> l_zmv_keys.count) THEN -- MN rel
    bsc_mo_helper_pkg.writeTmp('Completed Optimize ZMV clause', FND_LOG.level_Statement, false);
    return false;
  END IF;
  b_zmv_exists := false;
  FOR i IN l_zmv_keys.first..l_zmv_keys.last LOOP
    If l_zmv_keys(i).CalculateCode0 and keyFieldExists(p_keys, l_zmv_keys(i).keyName) and p_zero_code_states(i) = 1 Then
      b_zmv_exists :=true;
      EXIT;
    END IF;
  END LOOP;
  IF (b_zmv_exists = false) THEN
    bsc_mo_helper_pkg.writeTmp('Completed Optimize ZMV clause, Zero code mv with values for this level comb does not exist, returning false', FND_LOG.level_Statement, false);
    return false;
  ELSE
    bsc_mo_helper_pkg.writeTmp('ZMV exists ', FND_LOG.level_Statement, false);
  END IF;
  l_zmv := l_highest_table_with_zmv||'_ZMV';
  -- Note: l_nlevel_parents(0) is the same as the current S table
  -- Only l_nlevel_parents(1) and higher are the real parents
  -- if all zero_code_states are 0, then go directly to ZMV
  b_dimensions_joined := false;
  FOR i IN p_Keys.first..p_Keys.last LOOP
    -- even if a value is selected (ie not zero code), we can ignore joining to the dimension
    -- if the key exists in the ZMV also
    IF (p_zero_code_states(i) = 0 AND keyFieldExists(l_zmv_keys, p_keys(i).keyName)=false) THEN
      b_dimensions_joined := true;
      EXIT;
    END IF;
  END LOOP;

  -- Generate the FROM clause
  l_from_clause := ' FROM '||l_zmv|| ' '||l_zmv||',';
  l_where_clause := ' WHERE ';

  IF (b_dimensions_joined) THEN
    get_join_info(p_keys, l_zmv_keys, p_zero_code_states, p_dimensions, l_join_dimensions, l_join_parents, l_join_dimensions_fk, l_zmv_fk);
    FOR i IN l_join_dimensions.first..l_join_dimensions.last LOOP
	  l_from_clause := l_from_clause || ' '||l_join_dimensions(i)||' '||l_join_dimensions(i)||',';
	  if bsc_im_utils.is_column_in_object(l_join_dimensions(i), 'LANGUAGE') then
        l_where_clause := l_where_clause||l_join_dimensions(i)||'.language='''||BSC_IM_UTILS.get_lang||''''||' AND ';
      end if;
    END LOOP;
    -- add rest of the joins
    FOR i IN l_join_dimensions.first..l_join_dimensions.last-1 LOOP
      IF (l_join_parents(i+1) = l_join_dimensions(i)) THEN-- Same dimension
	    l_where_clause := l_where_clause || ' '||l_join_dimensions(i)||'.CODE = '||l_join_dimensions(i+1)||'.'||l_join_dimensions_fk(i+1)||' AND ';
	  ELSE -- join to zmv
	    l_where_clause := l_where_clause || ' '||l_join_dimensions(i)||'.CODE = '||l_zmv||'.'||l_zmv_fk(i)||' AND ';
	  END IF;
    END LOOP;
    -- handle last join to ZMV
    l_where_clause := l_where_clause || ' '||l_join_dimensions(l_join_dimensions.last)||'.CODE = '||l_zmv||'.'||l_zmv_fk(l_zmv_fk.last)||' AND ';
  END IF;
  -- Remove the comma
  l_from_clause := substr(l_from_clause, 1, length(l_from_clause)-1);

  -- We need to add the ZMV. alias to the SELECT column keys
  IF (b_dimensions_joined) THEN
    bsc_mo_helper_pkg.writeTmp('Dimensions have been joined to, so we need to change the select clause', FND_LOG.level_Statement, false);
  END IF;
  l_select_keys_clause := 'SELECT ';
  l_group_by_clause := ' GROUP BY ';
  FOR j IN p_Keys.first..p_Keys.last LOOP
      If p_zero_code_states(j) = 1 Then
        l_select_keys_clause := l_select_keys_clause || '0 ' || p_keys(j).keyName || ', ';
        IF keyFieldExists(l_zmv_keys, p_keys(j).keyName) AND p_keys(j).calculateCode0 THEN
          l_where_clause := l_where_clause ||p_keys(j).keyName||' = 0 AND ';
        END IF;
      Else
        IF keyFieldExists(l_zmv_keys, p_keys(j).keyName) THEN
          l_select_keys_clause := l_select_keys_clause || l_zmv||'.';
        END IF;
        l_select_keys_clause := l_select_keys_clause ||p_keys(j).keyName || ', ';
        l_group_by_clause := l_group_by_clause ||p_keys(j).keyName||',';
      End If;
  END LOOP;
  IF (trim(l_where_clause) = 'WHERE') THEN
    l_where_clause := null;
  ELSE
    l_where_clause := substr(l_where_clause, 1, length(l_where_clause)-5);
  END IF;
  bsc_mo_helper_pkg.writeTmp('l_where_clause final='||l_where_clause, FND_LOG.level_Statement, false);

  bsc_mo_helper_pkg.writeTmp('l_select_keys_clause='||l_select_keys_clause, FND_LOG.level_Statement, false);
  bsc_mo_helper_pkg.writeTmp('Intermediate l_group_by_clause='||l_group_by_clause, FND_LOG.level_Statement, false);
  l_group_by_clause := l_group_by_clause ||' PERIODICITY_ID, YEAR, TYPE, PERIOD, PERIOD_TYPE_ID ';
  bsc_mo_helper_pkg.writeTmp('l_group_by_clause final='||l_group_by_clause, FND_LOG.level_Statement, false);
  p_sql_stmt := l_select_keys_clause||' '||l_select_rest||' '||l_from_clause||' '||l_where_clause||' '||l_group_by_clause;
  bsc_mo_helper_pkg.writeTmp('Completed Optimize ZMV clause, sql_stmt='||p_sql_stmt, FND_LOG.level_Statement, false);
  return true;
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp('Completed optimize_zmv_clause with error : '||sqlerrm, fnd_log.level_exception, true);
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in optimize_zmv_clause:'||sqlerrm);
    bsc_mo_helper_pkg.writeTmp('l_where_clause final='||l_where_clause, FND_LOG.level_exception, true);
    raise;
    return false;
END;


--****************************************************************************
--  GetColConfigKpiMV
--
--    DESCRIPTION:
--       This function is used only in the BSC-MV Architecture.
--       Given the table it will return a collection
--       with the configuration for all the combinations of zero codes
--       and the sql or mv to be used by iviewer
--
--****************************************************************************
Function GetColConfigKpiMV(
                          STable BSC_METADATA_OPTIMIZER_PKG.clsBasicTable,
                          TableLevel NUMBER,
						  p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
						  colSummaryTables IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable
                          )
  RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsConfigKpiMV IS
    colConfigKpiMV BSC_METADATA_OPTIMIZER_PKG.tab_clsConfigKpiMV;
    configKpiMV BSC_METADATA_OPTIMIZER_PKG.clsConfigKpiMV;
    MVName VARCHAR2(100);
    zmvName VARCHAR2(100);
    keyColumn BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
    Dato BSC_METADATA_OPTIMIZER_PKG.clsDataField;
    arrCombinationsB DBMS_SQL.VARCHAR2_TABLE;
    numCombinationsB NUMBER;
    arrCombinationsA DBMS_SQL.VARCHAR2_TABLE;
    numCombinationsA NUMBER;
    i NUMBER;
    anyKeyNeedZeroCode Boolean;
    isTotalCombination Boolean;
    newCombination VARCHAR2(100);
    sql_stmt VARCHAR2(4000);
    group_by VARCHAR2(1000);
    state VARCHAR2(100);
    New_clsConfigKpiMV BSC_METADATA_OPTIMIZER_PKG.clsConfigKpiMV;
    STable_Keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
    STable_Data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
	l_groups DBMS_SQL.NUMBER_TABLE;
	bForcedSQL boolean := false;

    -- added for bug 3944813

	l_zero_code_states DBMS_SQL.NUMBER_TABLE;
    l_select_key_clause VARCHAR2(4000);
    l_from_clause VARCHAR2(4000);
    l_where_clause VARCHAR2(4000);
    l_stack varchar2(32000);
    l_newline varchar2(10):='
';
BEGIN
  l_groups := BSC_MO_HELPER_PKG.getGroupIds(p_dimension_families);
  bsc_mo_helper_pkg.writeTmp('# of levels = '||l_groups.count||' while max allowed = '||BSC_BIA_WRAPPER.MAX_ALLOWED_LEVELS, FND_LOG.LEVEL_STATEMENT, false);
  -- AWs, assume ZMV exists
  IF (g_current_indicator.Impl_Type = 2) THEN
    bForcedSQL := false;
  ELSIF (l_groups.count > BSC_BIA_WRAPPER.MAX_ALLOWED_LEVELS) THEN
    bForcedSQL := true;
    bsc_mo_helper_pkg.writeTmp('Going to convert MVs to SQL because of DB limitation... # of levels = '||l_groups.count||' while max allowed = '||BSC_BIA_WRAPPER.MAX_ALLOWED_LEVELS, FND_LOG.LEVEL_statement, true);
    --l_stack := l_stack || 'Going to convert MVs to SQL because of DB limitation... # of levels = '||l_groups.count||' while max allowed = '||BSC_BIA_WRAPPER.MAX_ALLOWED_LEVELS||l_newline;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp(' ');
    bsc_mo_helper_pkg.writeTmp('In GetColConfigKpiMV , TableLevel = '||TableLevel||', LevelConfig ='||STable.LevelConfig);
  END IF;
  bsc_mo_helper_pkg.write_this(STable);
  MVName := STable.Name || '_MV';
  If STable.LevelConfig IS NULL Then
    --Table has no dimensions
    configKpiMV.LevelComb := '?';
    configKpiMV.DataSource := 'MV';
    configKpiMV.MVName := MVName;
    configKpiMV.SqlStmt := null;
    colConfigKpiMV(0) := configKpiMV;
    return colConfigKpiMV;
  End If;
  --Table has dimensions
  anyKeyNeedZeroCode := False;
  arrCombinationsA(0) := STable.LevelConfig;
  numCombinationsA := 1;
  --BSC Multiple Optimizers
  --STable_Keys := bsc_mo_helper_pkg.getAllKeyFields(STable.name);
  i := BSC_MO_HELPER_PKG.findIndex(colSummaryTables, STable.name);
  STable_Keys := colSummaryTables (i).keys;
  FOR i IN STable_Keys.first..STable_Keys.last LOOP
    keyColumn := STable_keys(i);
    bsc_mo_helper_pkg.write_this(keyColumn);
    If keyColumn.CalculateCode0 Then
      anyKeyNeedZeroCode := True;
      arrCombinationsB.delete;
      numCombinationsB := 0;
      For j IN 0..(numCombinationsA - 1) LOOP
        --By design if the key needs zero code the character corresponding to this
        -- key in STable.level_Comb is "?"
        --We need to create two entries one with 0 (selected) and one with 1 (all)
        newCombination := substr( arrCombinationsA(j), 1, keyColumn.dimIndex) ||
                                 '0' || substr(arrCombinationsA(j), keyColumn.dimIndex + 2);
        arrCombinationsB(numCombinationsB) := newCombination;
        numCombinationsB := numCombinationsB + 1;
        newCombination := substr(arrCombinationsA(j), 1, keyColumn.dimIndex) ||
                                 '1' || substr(arrCombinationsA(j), keyColumn.dimIndex + 2);
        arrCombinationsB(numCombinationsB) := newCombination;
        numCombinationsB := numCombinationsB + 1;
      END LOOP;
      arrCombinationsA := arrCombinationsB;
      numCombinationsA := arrCombinationsA.count;
    End If;
  END LOOP;
  If anyKeyNeedZeroCode Then
    bsc_mo_helper_pkg.writeTmp('Zero code is needed, no. of combinations = '||numCombinationsB, FND_LOG.level_Statement, false);
    For i IN 0..numCombinationsB - 1 LOOP
      bsc_mo_helper_pkg.writeTmp('Processing combination '||i||'='||arrCombinationsB(i), FND_LOG.level_Statement, false);
      l_stack := null;
      configKpiMV := New_clsConfigKpiMV;
      configKpiMV.LevelComb := arrCombinationsB(i);
      isTotalCombination := False;
      l_select_key_clause := 'SELECT ';
      --sql_stmt := 'SELECT ';
      group_by := null;
      l_zero_code_states.delete;
      l_stack := l_stack || 'check 1'||l_newline;
      FOR j IN STable_Keys.first..STable_Keys.last LOOP
        keyColumn := STable_Keys (j);
        l_stack := l_stack || 'key = '||keyColumn.keyName ||l_newline;
        If keyColumn.CalculateCode0 Then
          l_stack := l_stack || 'Calc zero code'||l_newline;
          state := substr(arrCombinationsB(i), keyColumn.dimIndex + 1, 1);
          -- BEGIN added for bug 3944813
          l_zero_code_states(l_zero_code_states.count) := state;
          -- END added for bug 3944813
          l_stack := l_stack || 'State='||state||l_newline;
          If state = 1 Then
            isTotalCombination := True;
            l_select_key_clause := l_select_key_clause || '0 ' || keyColumn.keyName || ', ';
          Else
            l_select_key_clause := l_select_key_clause || keyColumn.keyName || ', ';
            group_by := group_by || keyColumn.keyName || ', ';
          End If;
        Else
          l_stack := l_stack || 'Dont Calc zero code'||l_newline;
          l_zero_code_states(l_zero_code_states.count) := 0;
          l_select_key_clause := l_select_key_clause || keyColumn.keyName || ', ';
          group_by := group_by || keyColumn.keyName || ', ';
        End If;
      END LOOP;
      If (isTotalCombination=false) Then
        l_stack := l_stack || 'Total comb is false'||l_newline;
        --This combination does not get any zero code
        configKpiMV.DataSource := 'MV';
        configKpiMV.MVName := MVName;
        configKpiMV.SqlStmt := null;
      Else
        l_stack := l_stack || 'Total comb is true'||l_newline;
        -- bug 3835059, autogenerate sqls instead of MVs if # of levels > BSC_METADATA_OPTIMIZER_PKG.MAX_ALLOWED_LEVELS
        If (NOT bForcedSQL) AND TableLevel <= to_number(BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level) Then
          --There will be a MV for the zero code
          configKpiMV.DataSource := 'MV';
          configKpiMV.MVName := STable.name || '_ZMV';
          configKpiMV.SqlStmt := null;
          l_stack := l_stack || 'MV exists'||l_newline;
        Else
          l_stack := l_stack || 'Need to configure SQL for zero code combination'||l_newline;
          --Need to configure a SQL to get zero code for this combination
          sql_stmt := null;
          sql_stmt := sql_stmt || 'PERIODICITY_ID, YEAR, TYPE, PERIOD, PERIOD_TYPE_ID';
          group_by := group_by || 'PERIODICITY_ID, YEAR, TYPE, PERIOD, PERIOD_TYPE_ID';
          --BSC Multiple Optimizer
          --STable_Data := bsc_mo_helper_pkg.getAllDataFields(STable.name);
          STable_Data := STable.Data;
          FOR j IN STable_Data.first..STable_Data.last LOOP
            Dato := STable_Data(j);
            If Dato.AvgLFlag = 'Y' Then
              sql_stmt := sql_stmt || ', ' ||GetFreeDivZeroExpression('SUM(' || Dato.AvgLTotalColumn
                                    || ')/SUM(' || Dato.AvgLCounterColumn || ')') || ' ' || Dato.fieldName;
            Else
              sql_stmt := sql_stmt || ', ' ||Dato.aggFunction || '(' || Dato.fieldName || ') ' || Dato.fieldName;
              l_stack := l_stack || 'check 2, sql_stmt is  '||sql_stmt||l_newline;
            End If;
          END LOOP;
          -- BEGIN added for bug 3944813
          bsc_mo_helper_pkg.writeTmp('Calling Optimize ZMV clause', FND_LOG.level_Statement, false);
          l_stack := l_stack || 'Calling Optimize ZMV clause'||l_newline;
          IF (bForcedSQL =false) -- bug 4139837
               AND TableLevel > to_number(BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level)
               AND to_number(BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level) > 0
               AND g_current_indicator.Impl_Type = 1
			   AND (optimize_zmv_clause(p_dimension_families,
								   colSummaryTables,
								   STable.Name,
								   TableLevel,
								   STable_Keys,
								   l_zero_code_states,
								   to_number(BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level),
								   sql_stmt)=true) THEN
            bsc_mo_helper_pkg.writeTmp('Optimized sql_stmt='||sql_stmt, FND_LOG.level_Statement, false);

          ELSE
	        sql_stmt := l_select_key_clause || sql_stmt || ' FROM ' || MVName;
            sql_stmt := sql_stmt || ' GROUP BY ' || group_by;
          END IF;
          l_stack := l_stack || 'sql_stmt is '||sql_stmt||l_newline;
          -- END added for bug 3944813
          configKpiMV.DataSource := 'SQL';
          configKpiMV.MVName := MVName;
          configKpiMV.SqlStmt := sql_stmt;
        End If;
      End If;
      colConfigKpiMV(colConfigKpiMV.count) := configKpiMV;
    END LOOP;
  Else
    --No key needs zero code
    --Iviewer will read from the MV
    configKpiMV.LevelComb := STable.LevelConfig;
    configKpiMV.DataSource := 'MV';
    configKpiMV.MVName := MVName;
    configKpiMV.SqlStmt := null;
    colConfigKpiMV(colConfigKpiMV.count) := configKpiMV;
  End If;
  return colConfigKpiMV;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
	bsc_mo_helper_pkg.writeTmp('Exception in GetColConfigKpiMV : '||g_error, FND_LOG.LEVEL_STATEMENT, true);
	bsc_mo_helper_pkg.writeTmp('Stack is '||l_stack, FND_LOG.LEVEL_STATEMENT, true);
	bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetColConfigKpiMV : '||g_error);
    raise;
End ;


PROCEDURE clearDrill(pDrill IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.clsLevels) IS
l_new BSC_METADATA_OPTIMIZER_PKG.clsLevels;
BEGIn
    pDrill := l_new;
END;


--****************************************************************************
--fieldExistsInLov
--
--  DESCRIPTION:
--     Return TRUE if the given field exist in the collection gLov
--
--  PARAMETERS:
--     measure: field name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function fieldExistsInLov(measure IN VARCHAR2,
-- BSC Autogen
p_source IN VARCHAR2) RETURN BOOLEAN IS
    measure_field BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV;
    i NUMBER ;

BEGIN
  IF (BSC_METADATA_OPTIMIZER_PKG.gLOV.count = 0) THEN
    return false;
  END IF;
  i :=  BSC_METADATA_OPTIMIZER_PKG.gLov.first;
  LOOP
    measure_field := BSC_METADATA_OPTIMIZER_PKG.gLOV(i);
    IF (upper(measure_field.fieldName) = upper(measure)
    -- BSC Autogen
	AND upper(measure_field.source) = upper(p_source)) THEN
	  return True;
    END IF;
    EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gLov.last;
    i := BSC_METADATA_OPTIMIZER_PKG.gLOV.next(i);
  END LOOP;
  return false;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
	bsc_mo_helper_pkg.TerminateWithMsg('Exception in fieldExistsInLov for field '||measure||' : '||g_error);
    raise;
End ;



--***************************************************************************
-- IndexRelation1N : IndexRelacion1N
--  DESCRIPTION:
--     Returns the index of the 1n relation from the colletion of parents
--     of the given dimension. Returns -1 if it is not found
--  PARAMETERS:
--     Maestra: dimension name
--     maestrapadre: name of the parent dimension
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IndexRelation1N(tablename IN VARCHAR2, masterTableName IN VARCHAR2 ) RETURN NUMBER IS
 i NUMBER;
 j NUMBER;
 l_parent_name DBMS_SQL.VARCHAR2_TABLE;
 l_dummy NUMBER;

BEGIN
    i := BSC_MO_HELPER_PKG.findindex(BSC_METADATA_OPTIMIZER_PKG.gMastertable, tablename);


    IF (BSC_METADATA_OPTIMIZER_PKG.gMastertable(i).parent_name IS NULL ) THEN
	   return -1;
    END IF;

    l_dummy := BSC_MO_HELPER_PKG.decomposestring(BSC_METADATA_OPTIMIZER_PKG.gMastertable(i).parent_name, ',', l_parent_name);

    j := l_parent_name.first;
    LOOP
        IF UPPER(l_parent_name(j)) = UPPER(masterTableName) Then
		    return i;
        END IF;
	EXIT WHEN j = l_parent_name.last;
	j := l_parent_name.next(j);
    END LOOP;

    return -1;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
	    bsc_mo_helper_pkg.TerminateWithMsg('Exception in IndexRelation1N : '||g_error||', tablename='||tablename||', masterTableName='||masterTableName);
            bsc_mo_helper_pkg.writeTmp('Dimension tables are  ', FND_LOG.LEVEL_ERROR, true);
            bsc_mo_helper_pkg.write_this(BSC_METADATA_OPTIMIZER_PKG.gMastertable, FND_LOG.LEVEL_ERROR, true);
        raise;
End;



--****************************************************************************
--IndexRelacionMN
--
--  DESCRIPTION:
--     Returns the index of the MN relation from the collection gRelacioneMN.
--     Returns 0 if it is not found.
--     A relation exists no matter the order of the dimension tables
--  PARAMETERS:
--     TablaA: name of the dimension table A
--     TablaB: name of the dimension table B
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IndexRelationMN(TableA IN VARCHAR2, TableB IN VARCHAR2) return NUMBER IS
i NUMBER;
j NUMBER;

BEGIN
    i :=  BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.count;

    IF (i = 0) THEN
	   return -1;
    END IF;

    i := BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.first;
    LOOP

        If ((UPPER(BSC_METADATA_OPTIMIZER_PKG.gRelationsMN(i).TableA) = UPPER(TableA)) And
           (UPPER(BSC_METADATA_OPTIMIZER_PKG.gRelationsMN(i).TableB) = UPPER(TableB))) Or
           ((UPPER(BSC_METADATA_OPTIMIZER_PKG.gRelationsMN(i).TableA) = UPPER(TableB)) And
           (UPPER(BSC_METADATA_OPTIMIZER_PKG.gRelationsMN(i).TableB) = UPPER(TableA))) Then
		   return i;
        END IF;
        EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.last;
        i := BSC_METADATA_OPTIMIZER_PKG.gRelationsMN.next(i);
    END LOOP;

    return -1;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
	    bsc_mo_helper_pkg.TerminateWithMsg('Exception in IndexRelationMN : '||g_error);
        raise;
End;




--****************************************************************************
--GetPeriodicityOrigin
--  DESCRIPTION:
--     Return the code of the periodicity within colPeriodicidades
--     where the given periodicity can be originated from.
--     Return -1 if it can not be originated from any of them.
--
--  PARAMETERS:
--     colPeriodicidades: collection of periodicities
--     Periodicidad: periodicity code
--     forTargetLevel: true  -Only see periodicities with TargetLevel = 1
--                       false -See all periodicities
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function GetPeriodicityOrigin(colPeriodicities IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity,
				Periodicity IN NUMBER,
                               forTargetLevel IN Boolean) RETURN NUMBER IS
    PERIODIC BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity;
    l_return NUMBER := -1;
    l_count NUMBER := -1;
    l_per_table DBMS_SQL.NUMBER_TABLE;
    l_dummy NUMBER;

    l_stack VARCHAR2(32000);


    l_index number;
BEGIN
    IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
        bsc_mo_helper_pkg.writeTmp('Starting GetPeriodicityOrigin for Periodicity='|| Periodicity
                ||', forTargetLevel='||bsc_mo_helper_pkg.boolean_decode(forTargetLevel));
        bsc_mo_helper_pkg.write_this(colPeriodicities);
    END IF;
    l_count := colPeriodicities.first;


    LOOP
        IF (length(l_stack) > 31000) THEN
            l_stack := null;
        END IF;

        l_stack := 'Looping...';
	    EXIT WHEN colPeriodicities.count =0;
	    PERIODIC := colPeriodicities(l_count);
        l_stack := l_stack||g_newline||'check2, l_count = '||l_count||', periodic.code = '||periodic.code||', peridociity = '||periodicity;

        IF PERIODIC.Code <> Periodicity Then
            IF (Not forTargetLevel) Or (forTargetLevel And PERIODIC.TargetLevel = 1) Then
                l_stack := l_stack||g_newline||'check 2b';
                l_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities, Periodicity);
                l_stack := l_stack||g_newline||'check 2c, l_index = '||l_index;
                l_per_table := BSC_MO_HELPER_PKG.decomposestringtonumber(BSC_METADATA_OPTIMIZER_PKG.gPeriodicities(l_index).PeriodicityOrigin, ',');
                l_stack := l_stack||g_newline||'check 3';
                IF  BSC_MO_HELPER_PKG.FindIndex(l_per_table, PERIODIC.Code) >= 0 Then
                      l_stack := l_stack||g_newline||'check4';
		              l_return := PERIODIC.Code;
                      IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
                        bsc_mo_helper_pkg.writeTmp('returning '||l_return);
                        END IF;
		              return l_return;
                END IF;
                l_stack := l_stack||g_newline||'check5';
            END IF;
        END IF;
        l_stack := l_stack||g_newline||'l_count = '||l_count||', colPeriodicities.last = '||colPeriodicities.last;
	    EXIT WHEN l_count = colPeriodicities.last;
        l_count := colPeriodicities.next(l_count);
        l_stack := l_stack||g_newline||'l_count = '||l_count;
        IF (length(l_stack) > 30000) THEN
           if (BSC_METADATA_OPTIMIZER_PKG.g_log) Then
              bsc_mo_helper_pkg.writeTmp(l_stack);
           else
              -- retain last 20000 chars
              l_stack := substr(l_stack, 10000, length(l_stack));
           end if;
        END IF;
    END LOOP;
    IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
      bsc_mo_helper_pkg.writeTmp('returning '||l_return);
    END IF;
    RETURN L_RETURN;

    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
	    bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetPeriodicityOrigin, '||g_error);
	    bsc_mo_helper_pkg.writeTmp('Stack is '||l_stack, fnd_log.level_exception, true);
        raise;
END;

--****************************************************************************
--IsFilteredIndicator
--  DESCRIPTION:
--     This function returns TRUE if the given indicator and configuration
--     has filters.
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function IsFilteredIndicator(Indicator IN NUMBER, Configuration IN NUMBER) RETURN Boolean IS

	l_stmt VARCHAR2(1000);
 	l_temp1 number;
	l_temp2 number;
    cv CurTyp;

    CURSOR cFilter(pIndicator IN NUMBER, pConfig IN NUMBER)  IS
    SELECT count(1)
	 FROM BSC_KPI_DIM_LEVELS_B K, BSC_SYS_DIM_LEVELS_B S
	WHERE UPPER(K.LEVEL_TABLE_NAME) = UPPER(S.LEVEL_TABLE_NAME)
	AND K.INDICATOR = pIndicator
	AND K.DIM_SET_ID = pConfig
	AND UPPER(S.LEVEL_VIEW_NAME) <> UPPER(K.LEVEL_VIEW_NAME)
	AND K.STATUS = 2;
BEGIN
null;
    --Since MLS Dimensions, the level_table_name is always different
    --from level_view_name. So we need to change this query.


    OPEN cFilter(Indicator, Configuration);
    FETCH cFilter INTO l_temp1;
    CLOSE cFilter;

    IF (l_temp1 =0 )  THEN
	   return false;
    Else
	   return true;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
	    bsc_mo_helper_pkg.TerminateWithMsg('Exception in IsFilteredIndicator : '||g_error);
        raise;
End;


PROCEDURE init_measure_counts(l_list IN DBMS_SQL.number_table) IS
  l_dummy varchar2(1000);
  l_stmt varchar2(4000) := 'SELECT kpi.indicator||''_''|| i.dim_set_id hash_index, COUNT(M.MEASURE_COL) NUM_DATA_COLUMNS
    FROM BSC_SYS_MEASURES M, '||BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table||' I,
    BSC_KPIS_VL kpi
    WHERE I.MEASURE_ID = M.MEASURE_ID
    AND kpi.indicator = i.indicator
    AND M.TYPE = 0
    AND NVL(M.SOURCE, ''BSC'') IN (''BSC'', ''PMF'')
    AND NVL(M.SOURCE, ''BSC'') <> decode(kpi.short_name, null, ''PMF'', ''-1'')
    GROUP BY kpi.indicator||''_''|| i.dim_set_id ';
    numDataColumns number;
  l_hash_index dbms_sql.varchar2_table;
  l_num_measures dbms_sql.number_table;
  cv CurTyp;
BEGIN
  l_dummy := bsc_mo_helper_pkg.Get_New_Big_In_Cond_Number(4, 'INDICATOR');
  bsc_mo_helper_pkg.Add_Value_Bulk(4, l_list);
  OPEN cv FOR l_stmt;
  FETCH cv BULK COLLECT INTO l_hash_index, l_num_measures;
  CLOSE cv;
  FOR i IN 1..l_hash_index.count LOOP
    g_objective_measures(l_hash_index(i)).value := l_num_measures(i);
  END LOOP;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in init_measure_count : '||g_error||', stmt='||l_stmt);
    raise;
END;

--***************************************************************************
--GetNumDataColumns
--  DESCRIPTION:
--     Get the number of data columns of the indicator for the given
--     dimension set.
--  PARAMETERS:
--     Indic: indicator code
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--**************************************************************************
Function GetNumDataColumns(Indic IN NUMBER, DimSet IN NUMBER) RETURN NUMBER IS

    l_stmt varchar2(10000) :=
    'SELECT COUNT(M.MEASURE_COL) NUM_DATA_COLUMNS
    FROM BSC_SYS_MEASURES M, '||BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table||' I
    WHERE I.MEASURE_ID = M.MEASURE_ID
    AND I.DIM_SET_ID = :1
    AND I.INDICATOR = :2
    AND M.TYPE = 0
	AND NVL(M.SOURCE, ''BSC'') IN (''BSC'', ''PMF'')
	AND NVL(M.SOURCE, ''BSC'') <> :3';
    numDataColumns number;
    cv CurTyp;
    CURSOR cExists IS
    select count(1) from user_objects where object_name = BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table;

    CURSOR cNumCols(pIgnore VARCHAR2) IS
    SELECT COUNT(M.MEASURE_COL) NUM_DATA_COLUMNS
    FROM BSC_SYS_MEASURES M, BSC_DB_MEASURE_BY_DIM_SET_V I
    WHERE I.MEASURE_ID = M.MEASURE_ID
    AND I.DIM_SET_ID = DimSet
    AND I.INDICATOR = Indic
    AND M.TYPE = 0
    AND NVL(M.SOURCE, 'BSC') in('BSC', 'PMF')
    AND NVL(M.SOURCE, 'BSC') <> pIgnore;
    l_short_name VARCHAR2(400);
BEGIN

  IF (g_objective_measures.exists(Indic||'_'||DimSet)) THEN
    return g_objective_measures(Indic||'_'||DimSet).value;
  END IF;
  SELECT short_name INTO l_short_name FROM bsc_kpis_vl where indicator = Indic;

  --BSC-PMF Integration: Even though a PMF measure cannot be present in a BSC
  --dimension set, I am going to do the validation to filter out PMF measures
  -- Bug 4301819
  -- Dont include PMF measures if this is created by objective definer
  IF (l_short_name is null) THEN -- created by objective definer, so source shouldnt be = 'PMF'
    OPEN cv FOR l_stmt USING DimSet, Indic, 'PMF';
  ELSE
    OPEN cv FOR l_stmt USING DimSet, Indic, '-1';
  END IF;
  FETCH cv INTO numDataColumns;
  CLOSE cv;
  g_objective_measures(Indic||'_'||DimSet).value := numDataColumns;

  return numDataColumns;

  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetNumDataColumns : '||g_error);
    raise;
End;


Function GetSourceDimensionSet(Indic IN NUMBER, DimSet IN NUMBER) return VARCHAR2 IS

   CURSOR cSourceDimSet IS
   SELECT NVL(SOURCE, 'BSC') DSSOURCE
			FROM BSC_SYS_DIM_LEVELS_B S, BSC_KPI_DIM_LEVELS_B K
			WHERE S.LEVEL_TABLE_NAME = K.LEVEL_TABLE_NAME
			AND K.INDICATOR = Indic AND K.DIM_SET_ID = DimSet  AND K.STATUS = 2;
    l_ret VARCHAR2(100);
    cv CurTyp;

BEGIN

    --BSC-PMF Integration: In a dimension set there is no BSC and PMF dimensions
    -- at the same time. The criteria to get the source of a dimension set is
    -- the source of the fisrt dimension level of the dimension set

    OPEN cSourceDimSet;

	FETCH cSourceDimSet INTO l_ret;
    If cSourceDimSet%NOTFOUND Then
        l_ret := 'BSC';
    END IF;
	close cSourceDimSet;

	return l_ret;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
	    bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetSourceDimensionSet : '||g_error);
        raise;
End;



--***************************************************************************
--GetConfigurationsForIndic : GetColConfiguracionesIndic
--  DESCRIPTION:
--     Get the collection with the configurations of the indicator
--  PARAMETERS:
--     Indic: indicator code
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--*************************************************************************
Function GetConfigurationsForIndic(Indic IN NUMBER) return DBMS_SQL.NUMBER_TABLE IS
    colConfigurationes dbms_sql.number_table;
    colMeasures BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
    Configuration NUMBER;
    CURSOR cConfigs IS
        SELECT DISTINCT DIM_SET_ID
        FROM BSC_DB_DATASET_DIM_SETS_V
        WHERE INDICATOR = Indic
        ORDER BY DIM_SET_ID;

    DimSet NUMBER;
    cv CurTyp;
    l_src VARCHAR2(100);
    l_num number := 0;

BEGIN

    OPEN cConfigs;

    LOOP
        --BSC-PMF Integration: Only get BSC dimension sets
        FETCH cConfigs INTO DimSet;
        EXIT WHEN cConfigs%NOTFOUND;
        --l_src := GetSourceDimensionSet(Indic, DimSet) ;

        --BIS DIMENSIONS: We need to consider dimension sets that have
        --BSC meaures not matter if the dimensions are from BIS or BSC.
        --So we do not need this validatino anymore.
        --If l_src = 'BSC' Then
            --We need to validate that there is at least one BSC data column
            --associated to this dimension set.
            L_NUM := GetNumDataColumns(Indic, DimSet) ;

            If l_num > 0 Then
                Configuration := DimSet;
                colConfigurationes(colConfigurationes.count) := Configuration;
            END IF;
        --END IF;
    END LOOP;
    close cConfigs;

    --bsc_mo_helper_pkg.write_this(colConfigurationes);
    return colConfigurationes;


    EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetConfigurationsForIndic for Indic='||Indic||', error is '||g_error);
    fnd_message.set_name('BSC', 'BSC_RETR_DIMSET_KPI_FAILED');
	fnd_message.set_token('INDICATOR', Indic);
    app_exception.raise_exception;


End;

--***************************************************************************
--ConfigureTablesSharedIndicatorsNoFilters
--  DESCRIPTION:
--     Configure shared indicators without filters same tables as master indicator
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

PROCEDURE ConfigureMasterSharedIndics IS
    Indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
    colConfigurationes dbms_sql.number_table;
    Configuration NUMBER;
    i NUMBER;
    j NUMBER;

    l_stmt VARCHAR2(3000);

BEGIN

null;


    IF (BSC_METADATA_OPTIMIZER_PKG.gIndicators.count =0) THEN
	   return;
    END IF;
    i := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;


    LOOP
	   Indicator := BSC_METADATA_OPTIMIZER_PKG.gIndicators(i);
        --Only consider new indicators or indicators that have been modified.
        --BSC-MV Note: If there is change of summarization level
        --we need to process all the indicators.

        If (Indicator.Action_Flag = 3) Or (Indicator.Action_Flag <> 2 And BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0) Then
            --Get the list of configurations of the kpi

            colConfigurationes := GetConfigurationsForIndic(Indicator.Code);
		    j := colConfigurationes.first;
	        LOOP
		          EXIT WHEN colConfigurationes.count=0;
		          Configuration := colConfigurationes(j);

                If Indicator.Share_Flag = 2 And (Not IsFilteredIndicator(Indicator.Code, Configuration))
				And  (Not IsFilteredIndicator(Indicator.source_indicator, Configuration))Then
                    DELETE FROM BSC_KPI_DATA_TABLES WHERE INDICATOR = Indicator.code  AND DIM_SET_ID = Configuration;

                    --BSC-MV Note: include columns MV_NAME and PROJECTION_SOURCE, DATA_SOURCE, SQL_STMT
                    -- and PROJECTION_DATA
                    --3182722
                    l_stmt := 'INSERT INTO BSC_KPI_DATA_TABLES ( INDICATOR,PERIODICITY_ID,
                                DIM_SET_ID, LEVEL_COMB, TABLE_NAME, FILTER_CONDITION  ';
                    If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
                        l_stmt := l_stmt ||', MV_NAME, PROJECTION_SOURCE , DATA_SOURCE , SQL_STMT , PROJECTION_DATA ';
                    End If;
                    l_stmt := l_stmt ||' )  SELECT :1,  PERIODICITY_ID, :2, LEVEL_COMB, TABLE_NAME, FILTER_CONDITION ';
                    If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
                        l_stmt := l_stmt ||', MV_NAME, PROJECTION_SOURCE , DATA_SOURCE , SQL_STMT, PROJECTION_DATA ';
                    End If;
                    l_stmt := l_stmt ||' FROM BSC_KPI_DATA_TABLES WHERE INDICATOR = :3 AND DIM_SET_ID = :4';

                    execute immediate l_stmt using Indicator.code, Configuration, Indicator.Source_Indicator, Configuration;

                End If;
                EXIT WHEN j=colConfigurationes.last;
		        j := colConfigurationes.next(j);
            END LOOP;

        End If;
        EXIT WHEN i =BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
	    i := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(i);
    END LOOP;

    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
        bsc_mo_helper_pkg.TerminateWithMsg('Exception in ConfigureMasterSharedIndics : '||g_error);
        raise;
END;

--***************************************************************************
--keyFieldExists - ExisteCampoLlave
--
--  DESCRIPTION:
--     Returns TRUE if exists the key in the collection. The collection
--     is of objects of class clsCampoLlave.
--  PARAMETERS:
--     colCamposLlaves: collection
--     Llave: key name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function keyFieldExists(colCamposLlaves IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField, keyName IN VARCHAR2) return Boolean IS
   CampoLlave BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
   i NUMBER;

BEGIN

    IF (colCamposLlaves.count = 0) THEN
	   return false;
    END IF;
    i := colCamposLlaves.first;
    LOOP
	    CampoLlave:= colCamposLlaves(i);
        If Upper(CampoLlave.keyName) = Upper(keyName) Then
	       return true;
        END IF;
	    EXIT WHEN i = colCamposLlaves.last;
	    i := colCamposLlaves.next(i);
    END LOOP;

    return false;
    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
        bsc_mo_helper_pkg.TerminateWithMsg('EXCEPTION IN keyFieldExists : '||g_error);
        raise;
End;

--****************************************************************************
--SameDisaggregatioins : sonMismasDesagregaciones
--
--  DESCRIPTION:
--     Say if the dissagregations are the same
--
--  PARAMETERS:
--     PeriodicityA: periodicity A
--     keysA: Dissagregation A
--     PeriodicityB: peridiodicity B
--     keysB: Dissagregation B
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function SameDisaggregations(PeriodicityA IN NUMBER,
  --tableA IN VARCHAR2,
  tableA BSC_METADATA_OPTIMIZER_PKG.clsTable,
			PeriodicityB IN NUMBER,
			--tableB IN VARCHAR2
			tableB BSC_METADATA_OPTIMIZER_PKG.clsTable
			) return Boolean IS
    keyNameIgual Boolean;
    keyNameA BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
    l_res boolean := false;
    i NUMBER;
    keysA BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
    keysB BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;

BEGIN

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside SameDisaggregations, PeriodicityA='||PeriodicityA||', PeriodicityB='||PeriodicityB);
  END IF;
  --BSC Multiple optimizers
  keysA := tableA.keys;
  keysB := tableB.keys;
  If PeriodicityA = PeriodicityB Then
    If keysA.Count = keysB.Count Then
      keyNameIgual := True;
      IF (keysA.count>0) THEN
        i := keysA.first;
        LOOP
          keyNameA := keysA(i);
          If Not keyFieldExists(keysB, keyNameA.keyName) Then
            keyNameIgual := False;
            EXIT;
          END IF;
          EXIT WHEN i = keysA.last;
          i := keysA.next(i);
        END LOOP;
      END IF;
      If keyNameIgual Then
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp('Completed SameDisaggregations, returning true');
        END IF;
        return true;
      END IF;
    END IF;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed SameDisaggregations, returning '||bsc_mo_helper_pkg.boolean_decode(l_res));
  END IF;
  return l_res;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('EXCEPTION in SameDisaggregations : '||g_error);
    raise;
End ;

--****************************************************************************
--GetTargetTable
--  DESCRIPTION:
--     Return the name of the taregt table corresponding to the given table.
--     It looks the target tables in gTablas for tables of the same indicator
--     and configuration. The target table must have the same periodicity and
--     same dimension levels of the given table.
--     It returns '' in case there is no target table.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetTargetTable(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable) return VARCHAR2 IS

    tbl BSC_METADATA_OPTIMIZER_PKG.clsTable;
    targetTable varchar2(100);
    keyField BSC_METADATA_OPTIMIZER_PKG.clskeyField;
    i NUMBER;

BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside GetTargetTable, pTable is');
  END IF;
  bsc_mo_helper_pkg.write_this(p_table);
  targetTable := null;
  i := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
  LOOP
    EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gTables.count=0;
    tbl := BSC_METADATA_OPTIMIZER_PKG.gTables(i);
    If tbl.Indicator = p_table.Indicator And tbl.Configuration = p_table.Configuration And tbl.IsTargetTable Then
      If SameDisaggregations(tbl.Periodicity, tbl, p_table.Periodicity, p_table) Then
        targetTable := tbl.Name;
        Exit;
      END IF;
    END IF;
    EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
    i := BSC_METADATA_OPTIMIZER_PKG.gTables.next(i);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Completed GetTargetTable, returning '||targetTable);
  END IF;
  return targetTable;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetTargetTable : '||g_error);
    raise;
End;

Function OriginTableHasTarget(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable) return Boolean IS
  res Boolean;
  tableOri VARCHAR2(1000);
  l_res boolean :=false;
  i NUMBER;
  l_index NUMBER;
  l_origin_table DBMS_SQL.VARCHAR2_TABLE;
  l_dummy NUMBER;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Inside OriginTableHasTarget, p_table = ');
  END IF;
  l_dummy := BSC_MO_HELPER_PKG.decomposestring(p_table.originTable, ',', l_origin_table);
  i := l_origin_table.first;
  LOOP
    EXIT WHEN l_origin_table.count =0;
    tableOri := l_origin_table(i);
    l_res := True;
    l_index := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, tableOri);
    If Not BSC_METADATA_OPTIMIZER_PKG.gTables(l_index).HasTargets Then
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp('Compl OriginTableHasTarget, returning false');
      END IF;
      return false;
    END IF;
    EXIT WHEN i = l_origin_table.last;
    i := l_origin_table.next(i);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp('Compl OriginTableHasTarget, returning '||bsc_mo_helper_pkg.boolean_decode(l_res));
  END IF;
  return l_res;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in OriginTableHasTarget : '||g_error);
    raise;
End;

--****************************************************************************
--TableAlreadyVisited
--
--  DESCRIPTION:
--     Return true if all origin tables are already been visited (They are
--     in the array arrVisitedTables())
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function TableAlreadyVisited(p_table IN BSC_METADATA_OPTIMIZER_PKG.clsTable, arrVisitedTables in dbms_sql.varchar2_table,
			 numVisitedTables in number) return Boolean is
  OriTable VARCHAR2(1000);
  i NUMBER;
  l_origin_table DBMS_SQL.VARCHAR2_TABLE;
  l_dummy NUMBER;
BEGIN

  l_dummy := BSC_MO_HELPER_PKG.decomposestring(p_table.originTable, ',', l_origin_table);
  i := l_origin_table.first;
  LOOP
    EXIT WHEN l_origin_table.count=0;
    OriTable := l_origin_table(i);
    If Not BSC_MO_HELPER_PKG.searchStringExists(arrVisitedTables, numVisitedTables, OriTable) Then
      return false;
    END IF;
    EXIT WHEN i = l_origin_table.last;
    i := l_origin_table.next(i);
  END LOOP;
  return true;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in TableAlreadyVisited : '||g_error);
    raise;
End;
--****************************************************************************
--ConnectTargetTables
--  DESCRIPTION:
--     Connect the target tables of the indicator to the summary tables of
--     the indicator.
--     Tables are already in collection gTablas
--     Some of the target tables can be deleted from gTablas becuase
--     are not used.
--  PARAMETERS:
--     Indicator: indicator
--     Configuration: configuration
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE ConnectTargetTables(Indicator IN BSC_METADATA_OPTIMIZER_PKG.clsIndicator, Configuration IN NUMBER) IS
  arrVisitedTables dbms_sql.varchar2_table;
  numVisitedTables NUMBER;
  anyTableVisited  Boolean;
  l_table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  targetTable varchar2(100);
  tableOri varchar2(100);
  i NUMBER;
  pt_name VARCHAR2(100);
  l_stmt VARCHAR2(1000);
  l_index1 NUMBER;
  l_next number;
BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'In ConnectTargetTables, Configuration='||Configuration||', Indicator='||', System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
  END IF;
  bsc_mo_helper_pkg.write_this(Indicator);
  numVisitedTables := 0;
  anyTableVisited := True;
  --BSC-MV Note: There is a special case in this Implementation with Targets at different
  --levels. When a table for targets merge into the summary table, we need to calculate
  --projection. That is the current logic. But the projection cannot be done in MV. Also
  --it cannot be done in base tables. For this special case we are going to create the
  --summary tables in the database and calculate the projection. Then iViewer needs to
  --read actuals and tagets from MV and projection from the summary table.

  --We need to visist the indicator tables in source-<target order
  --and connect the target table
  While anyTableVisited LOOP
    anyTableVisited := False;
    IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count >0) THEN
      i := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
    END IF;
    LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gTables.count=0;
      l_table := BSC_METADATA_OPTIMIZER_PKG.gTables(i);
      --Check only tables of the given indicator and configuration and are not target tables
      IF (l_table.Indicator = Indicator.Code) And (l_table.Configuration = Configuration) And
            (Not l_table.IsTargetTable) THEN
        --Check if the table has not already been visited
        IF Not BSC_MO_HELPER_PKG.searchStringExists(arrVisitedTables, numVisitedTables, l_table.Name) THEN
          IF TableAlreadyVisited(l_table, arrVisitedTables, numVisitedTables) THEN
            IF Not OriginTableHasTarget(l_table) THEN
              --If the origin table has targets then we do not need to
              --connect target table to this table
              targetTable := GetTargetTable(l_table);
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                BSC_MO_HELPER_PKG.writeTmp('Target table is :' ||targetTable);
              END IF;
              IF targetTable IS NOT NULL THEN
                IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                  BSC_MO_HELPER_PKG.writeTmp('assigning target table is');
                END IF;
                tableOri := targetTable;
                IF (l_table.originTable1 IS NOT NULL) THEN
                  l_table.originTable1 := l_table.originTable1 ||',';
                END IF;
                l_table.originTable1 := l_table.originTable1||tableOri;
                l_table.HasTargets := True;
                l_index1 := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, targetTable);
                BSC_METADATA_OPTIMIZER_PKG.gTables(l_index1).UsedForTargets := True;
                --BSC-MV Note: This table receives target. For that reason
                --it needs to calculate projection. The projection table needs to be
                --created in the database.
                --Also configure iViewer to read projection from this table.
                If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV and l_table.impl_type=1 Then
                  pt_name := GetProjectionTableName(l_table.name);
                  l_Table.projectionTable := pt_name;
                  UPDATE BSC_KPI_DATA_TABLES SET PROJECTION_SOURCE = 1,
                                    PROJECTION_DATA = pt_name
                                    WHERE INDICATOR = Indicator.code
                                    AND DIM_SET_ID = COnfiguration
                                    AND TABLE_NAME = l_table.name;
                END IF;
              END IF;
            ELSE
              --If the origin table has targets then this table has targets
              l_table.HasTargets := True;
              --BSC-MV Note: This table does not receives direclty targets
              --but we need this table to maintain the projections
              --at higher levels. This table needs to be created in the database.
              --Also configure iViewer to read projection from this table.
              If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV and l_table.impl_type=1 Then
                pt_name := GetProjectionTableName(l_Table.Name);
                l_Table.projectionTable := pt_name;
                UPDATE BSC_KPI_DATA_TABLES SET PROJECTION_SOURCE = 1,
                                PROJECTION_DATA = pt_name
                                WHERE INDICATOR = Indicator.code
                                AND DIM_SET_ID = COnfiguration
                                AND TABLE_NAME = l_table.name;
              End If;
            END IF;
            --Add the table to array of visited tables
            arrVisitedTables(numVisitedTables):= l_table.Name;
            numVisitedTables := numVisitedTables + 1;
            anyTableVisited := True;
          END IF;
        END IF;
        BSC_METADATA_OPTIMIZER_PKG.gTables(i) := l_table;
      END IF;
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
	  i := BSC_METADATA_OPTIMIZER_PKG.gTables.next(i);
	END LOOP;
  END LOOP;    -- END OF WHILE
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    BSC_MO_HELPER_PKG.writeTmp('remove target tables not being used');
  END IF;
  --remove target tables not being used
  i := BSC_METADATA_OPTIMIZER_PKG.gTables.first;
  LOOP
    EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gTables.Count = 0;
    IF (BSC_METADATA_OPTIMIZER_PKG.gTables(i).Indicator = Indicator.Code) And (BSC_METADATA_OPTIMIZER_PKG.gTables(i).Configuration = Configuration) And
      BSC_METADATA_OPTIMIZER_PKG.gTables(i).IsTargetTable And (Not BSC_METADATA_OPTIMIZER_PKG.gTables(i).UsedForTargets) Then
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('1 Going to delete '||BSC_METADATA_OPTIMIZER_PKG.gTables(i).name);
      END IF;
      IF (i = BSC_METADATA_OPTIMIZER_PKG.gTables.last) THEN
        BSC_METADATA_OPTIMIZER_PKG.gTables.delete(i);
        EXIT;
      ELSE
        l_next := BSC_METADATA_OPTIMIZER_PKG.gTables.next(i);
        BSC_METADATA_OPTIMIZER_PKG.gTables.delete(i);
        i := -1;
      END IF;
    END IF;
    IF (i <> -1) THEN
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gTables.last;
      i := BSC_METADATA_OPTIMIZER_PKG.gTables.next(i);
    ELSE
      i := l_next;
    END IF;
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Done with ConnectTargetTables, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
  END IF;
  EXCEPTION WHEN OTHERS THEN
	g_error := sqlerrm;
	bsc_mo_helper_pkg.TerminateWithMsg('Exception in ConnectTargetTables :' ||g_error);
	raise;
END;

--****************************************************************************
--GetKeyNum: GetNumeroLlave
--  DESCRIPTION:
--     Get the drill number corresponding to the given key
--  PARAMETERS:
--     p_dimension_families: collection of drill families
--     NomLlave: key name
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetKeyNum(p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels, NomkeyName IN VARCHAR2)
return NUMBER IS
    Dril BSC_METADATA_OPTIMIZER_PKG.clsLevels;
    DimensionLevels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
    i NUMBER;
    j NUMBER;
    l_res NUMBER := -1;
    l_groups DBMS_SQL.NUMBER_TABLE;
    group_id NUMBER;

 BEGIN

    l_groups := BSC_MO_HELPER_PKG.getGroupIds(p_dimension_families);
	i := l_groups.first;

	LOOP
      EXIT WHEN l_groups.count = 0;
	  DimensionLevels := BSC_MO_HELPER_PKG.get_Tab_clsLevels(p_dimension_families, i) ;
	  j := DimensionLevels.first;
	  LOOP
          EXIT WHEN DimensionLevels.count=0;
		  Dril := DimensionLevels(j);
	      If UPPER(Dril.keyName) = UPPER(NomkeyName) Then
               return Dril.Num;
          END IF;
		  EXIT WHEN j = DimensionLevels.last;
		  j := DimensionLevels.next(j);
	  END LOOP;

	  EXIT WHEN i = l_groups.last;
	  i := l_groups.next(i);
    END LOOP;

    return l_res;

    EXCEPTION WHEN OTHERS THEN
        g_error := sqlerrm;
        bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetKeyNum : '||g_error);
        raise;
End;

--****************************************************************************
--deduce_and_configure_s_tables : ConfigurarTablasIndicatorConfiguration
--  DESCRIPTION:
--     Deduce each one of the tables needed by the kpi in the given
--     configuration.
--     For this tables are added to the collection gTablas.
--     Also configure metadata in order to the indicator reads from them.
--  PARAMETERS:
--     Indicator: indicator
--     Configuration: configuration
--     colBasicaTablas: collection of base tables
--     colPeriodicidades: colection of periodicities
--     p_dimension_families: collection of drill families
--     forTargetLevel: true -Tables are for Targets
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE deduce_and_configure_s_tables (Indicator IN BSC_METADATA_OPTIMIZER_PKG.clsIndicator,
                       Configuration IN NUMBER,
                       colSummaryTables IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable,
                       colPeriodicities IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity,
                       p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
                       forTargetLevel IN Boolean)IS

  L_Periodicity BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity;
  L_Periodicity_Origin NUMBER;
  Basica BSC_METADATA_OPTIMIZER_PKG.clsBasicTable;
  L_Table BSC_METADATA_OPTIMIZER_PKG.clsTable;
  keyBasica BSC_METADATA_OPTIMIZER_PKG.clskeyField;
  key BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  DatoBasica BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  Dato BSC_METADATA_OPTIMIZER_PKG.clsDataField;

  l_stmt VARCHAR2(1000);
  cond   VARCHAR2(1000);
  CodPrimerDril NUMBER;
  msg VARCHAR2(1000);
  TableName VARCHAR2(1000);
  i NUMBER;
  j NUMBER;
  k NUMBER;
  l NUMBER;

  l_test NUMBER;
  basic_keys BSC_METADATA_OPTIMIZER_PKG.tab_clskeyField;
  basic_data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;

  table_keys BSC_METADATA_OPTIMIZER_PKG.tab_clskeyField;
  table_data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
  TableLevel NUMBER;
  configKpiMV BSC_METADATA_OPTIMIZER_PKG.clsConfigKpiMV;
  colConfigKpiMV BSC_METADATA_OPTIMIZER_PKG.tab_clsConfigKpiMV;
  l_counter NUMBER;
  first_periodicity_id NUMBEr := 0;

  TYPE tab_clsKPIData IS TABLE OF BSC_KPI_DATA_TABLES%ROWTYPE index by binary_integer;
  l_kpidata_record BSC_KPI_DATA_TABLES%ROWTYPE ;
  l_tbl_kpidata tab_clsKPIData;
BEGIN
  bsc_mo_helper_pkg.writeTmp( ' ');
  bsc_mo_helper_pkg.writeTmp( 'Inside deduce_and_configure_s_tables, Configuration = '||Configuration ||', forTargetLevel='
      ||bsc_mo_helper_pkg.boolean_decode(forTargetLevel)||', System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_procedure, false);
  --Delete from BSC_KPI_DATA_TABLES the records for this indicator and configuration
  If Not forTargetLevel Then
    --The tables are not for targets
    DELETE FROM BSC_KPI_DATA_TABLES WHERE INDICATOR = Indicator.Code
    AND DIM_SET_ID = Configuration;
  END IF;
  IF (colPeriodicities.count >0) THEN
    i := colPeriodicities.first;
  ELSE
    bsc_mo_helper_pkg.writeTmp( 'Compl. deduce_and_configure_s_tables, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_procedure, false);
	return;
  END IF;
  LOOP
    L_Periodicity := colPeriodicities(i);
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      BSC_MO_HELPER_PKG.writeTmp('Periodicity = '||l_periodicity.code);
      BSC_MO_HELPER_PKG.writeTmp('---------------');
    END IF;
    If (Not forTargetLevel) Or (forTargetLevel And l_periodicity.TargetLevel = 1) Then
      If Indicator.OptimizationMode <> 0 Then
        --if the indicator is no-precalculated then it can have change of periodicity
        L_Periodicity_Origin := GetPeriodicityOrigin(colPeriodicities, L_Periodicity.Code, forTargetLevel);
      Else
        --the indicator is pre-calculated. All tables of the indicator will be base tables.
        L_Periodicity_Origin := -1;
      END IF;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        BSC_MO_HELPER_PKG.writeTmp('L_Periodicity_Origin = '||L_Periodicity_Origin);
      END IF;
      j := colSummaryTables.first;
      LOOP
        EXIT WHEN colSummaryTables.count =0;
        L_Table := bsc_mo_helper_pkg.new_clsTable;
        Basica := colSummaryTables(j);
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp( 'Processing table '||Basica.name);
          bsc_mo_helper_pkg.write_this(Basica);
        END IF;
        --BSC Multiple Optimizers
        --basic_keys := BSC_MO_HELPER_PKG.getAllKeyFields(Basica.Name);
        --basic_data := BSC_MO_HELPER_PKG.getAllDataFields(Basica.Name);
        basic_keys := Basica.keys;
        basic_data := Basica.data;
        L_Table.Name := Basica.Name || '_'|| L_Periodicity.Code;
        L_Table.Type := 1;
        L_Table.Periodicity := L_Periodicity.Code;
        If L_Periodicity_Origin <> -1 And Basica.OriginTable IS NULL Then
          --The periodicity is originated from another one and
          --this table is not originated from another in the same periodicity
          --Keys
          k := basic_keys.first;
          LOOP
            EXIT WHEN basic_keys.count=0;
            keyBasica.keyName := null;
            keyBasica := basic_keys(k);
            key := bsc_mo_helper_pkg.new_clsKeyField;
            key.keyName := keyBasica.keyName;
            key.Origin := keyBasica.keyName;
            key.NeedsCode0 := keyBasica.NeedsCode0;
            --BSC-MV Note: In BSC-MV architecture we need to configure zero code
            --on all the tables needing zero code.
            If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
              key.CalculateCode0 := keyBasica.CalculateCode0;
            Else
              key.CalculateCode0 := False;
            End If;
            key.FilterViewName := keyBasica.FilterViewName;
            Table_keys(Table_keys.count) := key;
            EXIT WHEN k = basic_keys.last;
            k := basic_keys.next(k);
          END LOOP;
          --Data and L_TablesOri
          IF (L_Table.originTable IS NOT NULL) THEN
            L_Table.originTable := L_Table.originTable || ','||L_Table.originTable ||Basica.Name || '_'||  L_Periodicity_Origin;
          ELSE
            L_Table.originTable := L_Table.originTable ||Basica.Name || '_'||  L_Periodicity_Origin;
          END IF;
          k := basic_data.first;
          LOOP
            EXIT WHEN basic_data.count =0;
            DatoBasica := basic_data(k);
            If DatoBasica.AvgLFlag = 'Y' Then
              --Note: removed the name of the table as prefix of the column
              --I do not see that the same column could be in two origin tables.
              DatoBasica.Origin := GetFreeDivZeroExpression('SUM(' || DatoBasica.AvgLTotalColumn ||
                        ')/SUM(' || DatoBasica.AvgLCounterColumn || ')');
            Else
              DatoBasica.Origin := DatoBasica.aggFunction || '(' || DatoBasica.fieldName || ')';
            END IF;
            Table_Data(Table_Data.count) :=  DatoBasica ;
            EXIT WHEN k = basic_data.last;
            k := basic_data.next(k);
          END LOOP;
        Else
          --Keys
          k := basic_keys.first;
          table_keys := basic_keys;
          --Data and TablasOri
          If Basica.originTable IS NOT NULL Then
            --The table is originated from another indicator table
            --in the same periodicity
            IF (L_Table.originTable IS NOT NULL) THEN
              L_Table.originTable := L_Table.originTable||','||Basica.originTable || '_'|| L_Periodicity.Code;
            ELSE
              L_Table.originTable := Basica.originTable || '_'|| L_Periodicity.Code;
            END IF;
            k := basic_data.first;
            LOOP
              EXIT WHEN basic_data.count = 0;
              Dato := basic_data(k);
              If Dato.AvgLFlag = 'Y' Then
                --Note: removed the name of the table as prefix of the column
                --I do not see that the same column could be in two origin tables.
                Dato.Origin := GetFreeDivZeroExpression('SUM(' ||
                Dato.AvgLTotalColumn||')/SUM('||Dato.AvgLCounterColumn||')');
              Else
                Dato.Origin := Dato.aggFunction|| '('|| Dato.fieldName || ')';
              END IF;
              Table_Data(Table_Data.count) := Dato;
              EXIT WHEN k = basic_data.last;
              k := basic_data.next(k);
            END LOOP;
          Else -- Basica.origile IS NULL
            --The table is not generated from another indicator table
            --This is a base table o the indicator.
            --We calculate average at lowest level and formula at lowest level
            --where the lowest level is the lowest level of the kpi.
            --No set L_Table.TablasOri, we do not know the name yet
            k :=basic_data.first;
            LOOP
              EXIT WHEN basic_data.count =0;
              Dato := basic_data(k);
              --Note: removed the name of the table as prefix of the column
              --I do not see that the same column could be in two origin tables.
              IF ( Dato.InternalColumnType=0) THEN
                Dato.Origin := Dato.aggFunction|| '(' || Dato.fieldName || ')';
              ELSIF (Dato.InternalColumnType=1) THEN
                Dato.Origin := GetFreeDivZeroExpression(Dato.aggFunction ||'(' || Dato.InternalColumnSource ||')');
              ELSIF (Dato.InternalColumnType=2) THEN
                Dato.Origin := GetFreeDivZeroExpression('SUM(' ||Dato.InternalColumnSource || ')');
              ELSIF (Dato.InternalColumnType=3) THEN
                Dato.Origin := GetFreeDivZeroExpression('COUNT('||Dato.InternalColumnSource || ')');
              END IF;
              IF (Table_Data.count>0) THEN
                Table_Data(Table_Data.last+1) := Dato;
              ELSE
                Table_Data(0) := Dato;
              END IF;
              EXIT WHEN k = basic_data.last;
              k := basic_data.next(k);
            END LOOP;
          END IF;--Basica.originTable IS NOT NULL
        END IF; --L_Periodicity_Origin <> -1
        --Indicator and configuration
        L_Table.Indicator := Indicator.Code;
        L_Table.Configuration := Configuration;
        L_Table.EDW_Flag := Indicator.EDW_Flag;
        L_Table.IsTargetTable := forTargetLevel;
        L_Table.HasTargets := False;
        L_Table.UsedForTargets := False;
        --BSC-MV Note: If we are in upgrade (sum level changes from NULL to NOTNULL)
        --and the indicator is in production the falg this table with upgradeFlag = 1
        If (BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change = 1) And (Indicator.Action_Flag <> 3) Then
          L_Table.upgradeFlag := 1;
        End If;

        L_Table.impl_type := g_current_indicator.Impl_Type;
        --Add the table to gTablas
        IF (BSC_METADATA_OPTIMIZER_PKG.gTables.count>0)THEN
          l_test := BSC_MO_HELPER_PKG.findIndex(BSC_METADATA_OPTIMIZER_PKG.gTables, L_Table.name);
          IF (l_test >0 ) THEN --corruption
            l_test := -1;
          END IF;
          BSC_MO_HELPER_PKG.addTable(L_Table, Table_Keys, Table_data, 'deduce_and_configure_s_tables');
        ELSE
          BSC_MO_HELPER_PKG.addTable(L_Table, Table_keys, Table_data, 'deduce_and_configure_s_tables');
        END IF;
        Table_keys.delete; -- cleanup
        Table_data.delete; -- cleanup
        --Configure metadata in order to the indicator read from this table
        If Not forTargetLevel Then
          --Tables for targets only are not read by the indicator
          If first_periodicity_id = 0 Then
            --This is the first periodicity. Only in this case we insert records
            --one by one in BSC_KPI_DATA_TABLES. For other periodicities
            --we will insert all the records with one query based on the records of this  periodicity
            cond := null;
            k := basic_keys.first;
            LOOP
              EXIT WHEN basic_keys.count = 0;
              keyBasica := basic_keys(k);
              If cond IS NULL Then
                cond := 'D'|| GetKeyNum(p_dimension_families, keyBasica.keyName);
              Else
                cond := cond || ', D' || GetKeyNum(p_dimension_families, keyBasica.keyName);
              END IF;
              EXIT when k = basic_keys.last;
              k := basic_keys.next(k);
            END LOOP;
            --EDW Note: For EDW KPIs we need to user the union view name in BSC_KPI_DATA_TABLES
            If L_Table.EDW_Flag = 1 Then
              TableName := L_Table.Name || BSC_METADATA_OPTIMIZER_PKG.EDW_UNION_VIEW_EXT;
            Else
              TableName := L_Table.Name;
            END IF;
            --BSC-MV Note: We need to configure one entry for each combination
            --of zero codes. If the level of the table is greater than
            --g_adv_sum_level then we configure a SQL statement else we
            --configure to read from the ZMV (MV for zero codes)
            If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
              IF (g_current_indicator.Impl_Type=2) THEN -- AW, so set tablelevel as 0
                TableLevel := 0;
              ELSE
                TableLevel := getTableLevel(Basica.Name, colSummaryTables);
              END IF;
              -- bug 3835059, we need to create sql stmts instead of mv if # of
              -- levels > BSC_METADATA_OPTIMIZER_PKG.MAX_ALLOWED_LEVELS
              colConfigKpiMV := GetColConfigKpiMV(Basica, TableLevel, p_dimension_families, colSummaryTables);
              l_stmt := 'INSERT INTO BSC_KPI_DATA_TABLES (INDICATOR, PERIODICITY_ID, DIM_SET_ID, LEVEL_COMB,
                          TABLE_NAME, FILTER_CONDITION, MV_NAME, PROJECTION_SOURCE, DATA_SOURCE, SQL_STMT, PROJECTION_DATA)
                          VALUES(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11)';
              l_counter := colConfigKpiMV.first;
              LOOP
                EXIT WHEN colConfigKpiMV.count = 0;
                configKpiMV := colConfigKpiMV (l_counter);
                l_kpidata_record.INDICATOR := Indicator.Code;
                l_kpidata_record.PERIODICITY_ID :=  L_Periodicity.Code;
                l_kpidata_record.DIM_SET_ID := Configuration;
                l_kpidata_record.LEVEL_COMB :=  configKpiMV.LevelComb;
                l_kpidata_record.TABLE_NAME :=   TableName;
                l_kpidata_record.FILTER_CONDITION := cond;
                l_kpidata_record.MV_NAME := configKpiMV.MVName;
                l_kpidata_record.PROJECTION_SOURCE := 0;
                l_kpidata_record.DATA_SOURCE := configKpiMV.DataSource;
                l_kpidata_record.SQL_STMT :=  configKpiMV.SqlStmt;
                l_kpidata_record.PROJECTION_DATA := null;
                l_tbl_kpidata(l_tbl_kpidata.count+1):= l_kpidata_record;
                /*Execute IMMEDIATE l_stmt USING
                              Indicator.Code , L_Periodicity.Code, Configuration, configKpiMV.LevelComb, TableName , cond,
                              configKpiMV.MVName, 0,  configKpiMV.DataSource, configKpiMV.SqlStmt, '';*/
                EXIT WHEN l_counter = colConfigKpiMV.last;
                l_counter := colConfigKpiMV.next(l_counter);
              END LOOP;
            Else
              l_kpidata_record.INDICATOR := Indicator.Code;
                l_kpidata_record.PERIODICITY_ID :=  L_Periodicity.Code;
                l_kpidata_record.DIM_SET_ID := Configuration;
                l_kpidata_record.LEVEL_COMB :=  nvl(Basica.levelConfig, '?');
                l_kpidata_record.TABLE_NAME :=   TableName;
                l_kpidata_record.FILTER_CONDITION := cond;
                l_kpidata_record.MV_NAME := null;
                l_kpidata_record.PROJECTION_SOURCE := null;
                l_kpidata_record.DATA_SOURCE := null;
                l_kpidata_record.SQL_STMT :=  null;
                l_kpidata_record.PROJECTION_DATA := null;
                l_tbl_kpidata(l_tbl_kpidata.count+1):= l_kpidata_record;
                /*INSERT INTO BSC_KPI_DATA_TABLES
                        (INDICATOR, PERIODICITY_ID, DIM_SET_ID,
                        LEVEL_COMB, TABLE_NAME, FILTER_CONDITION)
                        VALUES(Indicator.Code,  L_Periodicity.Code, Configuration,
                        nvl(Basica.levelConfig, '?'), TableName, cond);*/
            End If;
          End If;
        End If;
        EXIT WHEN j = colSummaryTables.last;
        j := colSummaryTables.next(j);
      END LOOP;
      FORALL ii IN 1..l_tbl_kpidata.count
        INSERT INTO BSC_KPI_DATA_TABLES values l_tbl_kpidata(ii);
      l_tbl_kpidata.delete;
      --BSC_KPI_DATA_TABLES was already configured for the fisrt periodicity
      --For this periodcity we can insert same set of records based on the first
      --periodicity so we avoid to do one by one again
      --3135168
      If Not forTargetLevel Then
        If first_periodicity_id <> 0 Then
          INSERT INTO BSC_KPI_DATA_TABLES
                  (INDICATOR, PERIODICITY_ID, DIM_SET_ID, LEVEL_COMB,
                  TABLE_NAME, FILTER_CONDITION, MV_NAME, PROJECTION_SOURCE,
                  DATA_SOURCE, SQL_STMT, PROJECTION_DATA)
                  SELECT INDICATOR, L_Periodicity.Code , DIM_SET_ID, LEVEL_COMB,
                  SUBSTR(TABLE_NAME,1,INSTR(TABLE_NAME, '_', -1))||L_Periodicity.Code TABLE_NAME,
                  FILTER_CONDITION, MV_NAME, PROJECTION_SOURCE, DATA_SOURCE, SQL_STMT, PROJECTION_DATA
                  FROM BSC_KPI_DATA_TABLES
                  WHERE INDICATOR = Indicator.Code
                  AND PERIODICITY_ID = first_periodicity_id
                  AND DIM_SET_ID = Configuration;
        Else
          first_periodicity_id := L_Periodicity.Code;
        End If;
      End If;
    END IF;
    EXIT WHEN i = colPeriodicities.last;
    i := colPeriodicities.next(i);
  END LOOP;
  bsc_mo_helper_pkg.writeTmp( 'Compl. deduce_and_configure_s_tables, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_procedure, false);

  EXCEPTION WHEN OTHERS THEN
  l_stmt := sqlerrm;
  bsc_mo_helper_pkg.writeTmp( 'exception in deduce_and_configure_s_tables:'||l_stmt, FND_LOG.LEVEL_UNEXPECTED, true);
  fnd_message.set_name('BSC', 'BSC_KPICONFIG_SYSTABLES_FAILED');
	fnd_message.set_token('INDICATOR', Indicator.code);
  fnd_message.set_token('DIMENSION_SET', Configuration);
  g_error := fnd_message.get;
  bsc_mo_helper_pkg.terminatewithMsg(g_error);
  raise;

End ;


--****************************************************************************
--GetKeyOrigin : GetLlaveOrigen
--  DESCRIPTION:
--   Return the name of the key where the given key is originated from, within
--   the given list of keys.
--   We know that the key is originated from one of them.
--
--  PARAMETERS:
--   keyNameOri: collection of keys
--   Llave: key name
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetKeyOrigin(keyNamesOri IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField, keyName IN VARCHAR2) return VARCHAR2 IS
  keyNameOri BSC_METADATA_OPTIMIZER_PKG.clskeyField;
  i NUMBER;
  l_index1 number;
  l_index2 number;

BEGIN

  --First check if the same key exists in the list of origin keys
  IF (keyNamesOri.count= 0) THEN
     return null;
  END IF;
	i := keyNamesOri.first;

  LOOP
       keyNameOri :=  keyNamesOri(i);
       If Upper(keyNameOri.keyName) = Upper(keyName) Then
          return keyNameOri.keyName;
       END IF;
	     EXIT WHEN i = keyNamesOri.last;
	     i := keyNamesOri.next(i);
   END LOOP;

  --If it was not found, It looks a parent.
  i := keyNamesOri.first;
  LOOP
  	   keyNameOri := keyNamesOri(i);

  	   l_index1 := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, keyNameOri.keyName);
   	   l_index2 := BSC_MO_HELPER_PKG.findKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, keyName);
       If (l_index1>=0 AND l_index2>=0 AND
          IndexRelation1N(BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_index1).Name,
                   BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_index2).Name) >= 0 ) Then
          return keyNameOri.keyName;
       END IF;
	     EXIT WHEN i = keyNamesOri.last;
	     i:= keyNamesOri.next(i);
  END LOOP;

  return null;
  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetKeyOrigin : '||g_error);
      raise;
End;


--***************************************************************************
-- keyOriginExists: SePuedeOriginarLlaves
--  DESCRIPTION:
--   Returns TRUE if the list of keys in LlavesDest can be originated
--   from the list of drill in LlavesOri.
--   This is possible if all keys in the target can be originated from
--   'some key in the source and only one change of dissagregation
--
--   Bug 2911828: Also need to see if the keys belong to the same family
--   within the kpi. For that reason we are passing p_dimension_families
--  PARAMETERS:
--   LlavesDest: target keys collection
--   LlavesOri: source keys collection
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function keyOriginExists(keyNameDest IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
                keyNameOri IN BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField,
          p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels) return Boolean IS
  DrilOri BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  DrilDest BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  numChanges NUMBER;
  originExists boolean;
  FamilyIndex number;
  i NUMBER;
  j NUMBER;
  k NUMBER;
  l_index1 NUMBER;
  l_index2 NUMBER;
BEGIN
  --Bug#3361564 08-JAN-2004 Metadata is creating a loop between summary tables
  -- in some cases with MN relations.
  -- We can enforce a rule where a table with x number of dimensions never
  -- can be generated from a table with less number of dimensions
  If keyNameOri.Count < keyNameDest.Count Then
    return false;
  End If;
  numChanges := 0;
  IF (keyNameDest.count > 0) THEN
    i := keyNameDest.first;
  END IF;
  LOOP
    EXIT WHEN keyNameDest.count =0;
    DrilDest := keyNameDest(i);
    originExists := False;
    FamilyIndex := FindDimensionGroupIndexForKey(p_dimension_families, DrilDest.keyName);
    IF (keyNameOri.count>0) THEN
      j := keyNameOri.first;
      LOOP
        DrilOri := keyNameOri(j);
        If Upper(DrilDest.keyName) = Upper(DrilOri.keyName) Then
          originExists := True;
          Exit;
        END IF;
        If FindDimensionGroupIndexForKey(p_dimension_families, DrilOri.keyName) = FamilyIndex Then
          --Both keys origin and target belong to the same familiy of drill within the kpi.
          l_index1 := BSC_MO_HELPER_PKG.findKeyindex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, DrilOri.keyName);
      	  l_index2 := BSC_MO_HELPER_PKG.findKeyindex(BSC_METADATA_OPTIMIZER_PKG.gMasterTable, DrilDest.keyName);
          If IndexRelation1N(BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_index1).Name ,
                       BSC_METADATA_OPTIMIZER_PKG.gMasterTable(l_index2).Name) >= 0 Then
            originExists := True;
            numChanges := numChanges + 1;
            Exit;
          END IF;
        END IF;
	    EXIT WHEN j = keyNameOri.last;
	    j := keyNameOri.next(j);
      END LOOP;
	END IF;
    If Not originExists Then
      return false;
    END IF;
	EXIT WHEN i = keyNameDest.last;
	i := keyNameDest.next(i);
  END LOOP;
  If numChanges > 1 Then
    return False;
  Else
     return true;
  END IF;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in keyOriginExists : '||g_error);
    raise;
End ;

--****************************************************************************
--DeduceInternalGraph
--  DESCRIPTION:
--     Deduce the internal tables tree of the indicator.
--
--  PARAMETERS:
--     colSummaryTables: base tables collection
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE DeduceInternalGraph(
  colSummaryTables IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable,
  p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
  forTargetLevel IN Boolean) IS
  l_s_table BSC_METADATA_OPTIMIZER_PKG.clsBasicTable;
  Basica1 BSC_METADATA_OPTIMIZER_PKG.clsBasicTable;
  keyName BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  originExists Boolean;
  i NUMBER;
  j NUMBER;
  k NUMBER;
  l_index NUMBER;
  l_s_table_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  l_s_table_measures BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
  Basic1_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  Basic1_data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;

BEGIN

  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp(' ');
    bsc_mo_helper_pkg.writeTmp('Inside DeduceInternalGraph, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
    bsc_mo_helper_pkg.writeTmp('  colSummaryTables is as above', FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (colSummaryTables.count >0) THEN
    i := colSummaryTables.first;
  END IF;
  LOOP
    EXIT WHEN colSummaryTables.count=0;
    l_s_table := colSummaryTables(i);
    l_s_table_keys := l_s_table.keys;
    l_s_table_measures := l_s_table.data;
    --For each base table, look if it possible to be originated from any other table
    originExists := False;
    j := colSummaryTables.first;
    LOOP
      Basica1 := colSummaryTables(j);
      --different than itself
      If Basica1.Name <> l_s_table.Name Then
        Basic1_keys := Basica1.keys;
        Basic1_data := Basica1.data;
        If keyOriginExists(l_s_table_keys, Basic1_keys, p_dimension_families) Then
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            bsc_mo_helper_pkg.writeTmp( ' ');
          END IF;
          --l_s_table can be originated from Basica1
          --For each key assign the properties Origen and CalcularCod0
          IF (l_s_table_keys.count > 0) THEN
             k := l_s_table_keys.first;
             LOOP
               keyName := l_s_table_keys(k);
               IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                  bsc_mo_helper_pkg.writeTmp( 'Processing key');
                  bsc_mo_helper_pkg.write_this(keyName);
               END IF;
               --assign the origin field with the name of the key where it is originated from.
               keyName.Origin := GetKeyOrigin(Basic1_keys, keyName.keyName);
               --BSC-MV Note: In BSC-MV architecture we need to configure zero code
               --on all the tables needing zero code.
               --Tables for targets only there is no need to calculate zero code.
               If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
                 --BSC-MV/V Architecture
                 If Not forTargetLevel Then
                   If keyName.NeedsCode0 Then
                     keyName.CalculateCode0 := True;
                   End If;
                 End If;
               ELSE
                 --Table architecture
                 --If there is key change and the key needs code 0 then CalculateCode0 = True
                 IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                   bsc_mo_helper_pkg.writeTmp( 'Table architecture, keyName.Origin='||
                     keyName.Origin||', keyName.keyName='||keyName.keyName);
                 END IF;
                 If Upper(keyName.Origin) <> UPPER(keyName.keyName) Then
                   If keyName.NeedsCode0  Then
                     IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                       bsc_mo_helper_pkg.writeTmp('1 Switching CalculateCode0 to TRUE for table '||
                         l_s_table.name||', key='||keyName.keyName);
                     END IF;
                     keyName.calculateCode0 := True;
                   End If;
                 Else
                   --If there is no key change and needs code 0 but the origin
                   --key does not need code 0 then CalcularCod0 = true
                   If keyName.NeedsCode0 Then
                     l_index := BSC_MO_HELPER_PKG.findindex(Basic1_keys, keyName.Origin);
                     IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                       bsc_mo_helper_pkg.writeTmp( 'l_index = '||l_index||', Basic1_keys('||l_index||') = ');
                       bsc_mo_helper_pkg.write_this(Basic1_Keys(l_index));
                     END IF;
                     If L_INDEX>=0 THEN
                       IF   (Basic1_keys(l_index).NeedsCode0) Then
                         null;
                       ELSE
                         IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                           bsc_mo_helper_pkg.writeTmp('2 Switching CalculateCode0 to TRUE for table '||l_s_table.name||', key='||keyName.keyName);
                         END IF;
                         keyName.calculateCode0 := True;
                       END IF;
                     End If;
                   End If;
                 End If;
               END IF;
               l_s_table_keys(k) := keyName ;
               EXIT WHEN k =l_s_table_keys.last;
               k := l_s_table_keys.next(k);
             END LOOP;
             -- will delete and insert keys
             --BSC Multiple Optimizers
             --BSC_MO_HELPER_PKG.insertKeys(l_s_table.name, l_s_table_keys);
             l_s_table.keys := l_s_table_keys;
           END IF;
           --assign the property TablaOri with the name of the origin table
           l_s_table.originTable := Basica1.Name;
           originExists := True;
           Exit;
         END IF;
       END IF;
       EXIT WHEN j = colSummaryTables.last;
       j := colSummaryTables.next(j);
     END LOOP;
     If Not originExists Then
       IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
         bsc_mo_helper_pkg.writeTmp('It was not possible to generate the table from another one.');
       END IF;
       --It was not possible to generate the table from another one.
       --For each key, assign the properties Origen and CalcularCod0
       IF (l_s_table_keys.count>0) THEN
         j := l_s_table_keys.first;
         LOOP
           keyName := l_s_table_keys(j);
           --Leave the field Origen in ''
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            bsc_mo_helper_pkg.writeTmp( 'Processing key');
            bsc_mo_helper_pkg.write_this(keyName);
          END IF;
          If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
            --BSC-MV Note: In this architecture
            -- No zero code needed in tables for targets
            If Not forTargetLevel Then
              --If the key needs code 0 then CalcularCod0 = True
              If keyName.NeedsCode0 Then
              	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                  bsc_mo_helper_pkg.writeTmp('3 Switching CalculateCode0 to TRUE for table '||l_s_table.name||', key='||keyName.keyName);
               	END IF;
                keyName.calculateCode0 := True;
              End If;
            End If;
          Else
            --If the key needs code 0 then CalcularCod0 = True
            If keyName.NeedsCode0 Then
              keyName.CalculateCode0 := True;
              IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp('4 Switching CalculateCode0 to TRUE for table '||l_s_table.name||', key='||keyName.keyName);
              END IF;
            END IF;
          END IF;
          l_s_table_keys(j) := keyName;
        EXIT WHEN j = l_s_table_keys.last;
        j :=  l_s_table_keys.next(j);
   	  END LOOP;
      -- will delete and insert keys
      --BSC Multiple Optimizers
      --BSC_MO_HELPER_PKG.insertKeys(l_s_table.name, l_s_table_keys);
      l_s_table.keys := l_s_table_keys;
    END IF;
    --leave the property TablaOri in ''
  END IF;

    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( ' ');
    END IF;
    colSummaryTables(i) := l_s_table;
    EXIT WHEN i = colSummaryTables.last;
    i := colSummaryTables.next(i);
  END LOOP;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Completed DeduceInternalGraph, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
      bsc_mo_helper_pkg.writeTmp('  colSummaryTables is ', FND_LOG.LEVEL_STATEMENT);
      bsc_mo_helper_pkg.write_this(colSummaryTables);
	END IF;

    EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg('Exception in DeduceInternalGraph : '||g_error);
    fnd_message.set_name('BSC', 'BSC_REL_DEDUCTION_FAILED');
    app_exception.raise_exception;
End;



--****************************************************************************
--  order_level_string
--  DESCRIPTION:
--     Order the string of levels configuration.
--     Example:
--       ConfDriles = '?0?0'
--       Looking into p_dimension_families we know that the string
--       of level configuration is in this order: 0,2,1,3
--       This function returns the character in the right order
--       0,1,2,3 --> '??00'
--
--  PARAMETERS:
--     ConfDriles: drills configuration
--     p_dimension_families: collection of drill families of the indicator
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function order_level_string(p_level_string IN VARCHAR2,
p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels) return VARCHAR2
IS
  arrOrdenDrilesActual  dbms_sql.number_table;
  arrOrdenDriles      dbms_sql.number_table;
  arrConfDriles       dbms_sql.varchar2_table;
  numDriles           NUMBER;
  i               NUMBER;
  j               NUMBER;
  temp              NUMBER;
  l_ordered_level_string       varchar2(1000);
  tempC             varchar2(1000);
  DimLevels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
  l_groups DBMS_SQL.NUMBER_TABLE;
  l_group_id NUMBER;

BEGIN

  l_groups := bsc_mo_helper_pkg.getGroupIds(p_dimension_families);
  numDriles := 0;
  For i IN 0..l_groups.Count-1 loop
    DimLevels := bsc_mo_helper_pkg.get_tab_clsLevels(p_dimension_families, l_groups(i));
    For j IN 0..DimLevels.Count-1  LOOP
      arrOrdenDrilesActual(numDriles) := DimLevels(j).Num;
      arrOrdenDriles(numDriles) := DimLevels(j).Num;
      arrConfDriles(numDriles) := Trim(substr(p_level_string, numDriles + 1, 1));
      numDriles := numDriles + 1;
    END LOOP;
  END LOOP;

  --order arrOrdenDriles() and arrConfDriles()
  For i in 0..numDriles - 1 LOOP
    For j in i + 1.. numDriles - 1 LOOP
      If arrOrdenDriles(i) > arrOrdenDriles(j) Then
        temp := arrOrdenDriles(i);
        arrOrdenDriles(i) := arrOrdenDriles(j);
        arrOrdenDriles(j) := temp;
        tempC := arrConfDriles(i);
        arrConfDriles(i) := arrConfDriles(j);
        arrConfDriles(j) := tempC;
      END IF;
    END LOOP;
  END LOOP;

  l_ordered_level_string := null;
  For i in 0..numDriles - 1 LOOP
    l_ordered_level_string := l_ordered_level_string || arrConfDriles(i);
  END LOOP;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Done with order_level_string, returning '||l_ordered_level_string, FND_LOG.LEVEL_PROCEDURE);
  END IF;

  return l_ordered_level_string;

  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in order_level_string : '||g_error);
	RAISE;
End;



--****************************************************************************
--  GetFilterViewName
--
--  DESCRIPTION:
--     Returns the name of the filter view for the given indicator,
--     configuration and key
--
--  PARAMETERS:
--     Indicator: indicator code
--     Configuration: configuration
--     CampoLlave: key name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetFilterViewName(Indicator IN NUMBER, Configuration IN NUMBER, CampoLlave IN VARCHAR2) return VARCHAR2 IS
  l_stmt varchar2(1000);
  l_return varchar2(1000) := null;
  cv CurTyp;
  CURSOR cLevelViewName (pIndicator IN NUMBER, pConfiguration IN NUMBER, pKeyCol IN VARCHAR2) IS
  SELECT LEVEL_VIEW_NAME FROM BSC_KPI_DIM_LEVELS_B
  WHERE INDICATOR = pIndicator
  AND DIM_SET_ID = pConfiguration
  AND LEVEL_PK_COL = pKeyCol;
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Inside GetFilterViewName, Indicator='||Indicator||', Configuration='||Configuration
       ||', CampoLlave='||CampoLlave , FND_LOG.LEVEL_PROCEDURE);
   	END IF;


	OPEN cLevelViewName(Indicator, Configuration, upper(CampoLlave));
	FETCH cLevelViewName INTO l_return;
	CLOSE cLevelViewName;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Completed GetFilterViewName, returning '||l_return, FND_LOG.LEVEL_PROCEDURE);
	END IF;

	return l_return;

  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in GetFilterViewName : '||g_error);
	RAISE;

End ;



--****************************************************************************
--  IsIndicatorPnL
--  DESCRIPTION:
--     Return TRUE if the indicator is type PnL
--  PARAMETERS:
--     Ind: Indicator code
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IsIndicatorPnL(Ind IN Integer, pUseGIndics boolean) return Boolean IS
l_index NUMBER;
l_indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
BEGIN

	if (pUseGIndics) then
 	  l_index := BSC_MO_HELPER_PKG.findindex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, Ind);
 	  l_indicator := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index);
  else
    l_index := BSC_MO_HELPER_PKG.findindex(BSC_MO_DOC_PKG.gDocIndicators, Ind);
    l_indicator := BSC_MO_DOC_PKG.gDocIndicators(l_index);
  end if;

  If l_indicator.IndicatorType = 1 And l_indicator.ConfigType = 3 Then
      return true;
  Else
      return false;
  END IF;

  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in IsIndicatorPnL for '||Ind||' : '||g_error);
	RAISE;

End;

--****************************************************************************
--  EsIndicatorBalance
--
--  DESCRIPTION:
--     Returns TRUE is the indicator is type Balance
--
--  PARAMETERS:
--     Ind: Indicator code
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IsIndicatorBalance(Ind IN NUMBER, pUseGIndics boolean) return Boolean IS
l_index NUMBER;
l_indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
BEGIN

	if (pUseGIndics) then
    l_index := BSC_MO_HELPER_PKG.findindex(BSC_METADATA_OPTIMIZER_PKG.gIndicators, Ind);
    l_indicator := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_index);
  else
    l_index := BSC_MO_HELPER_PKG.findindex(BSC_MO_DOC_PKG.gDocIndicators, Ind);
    l_indicator := BSC_MO_DOC_PKG.gDocIndicators(l_index);
  end if;

  If l_indicator.IndicatorType = 1 And l_indicator.ConfigType = 2 Then
      return true;
  Else
	   return false;
  END IF;
  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in IsIndicatorBalance for '||ind||' : '||g_error);
	RAISE;
End;

--****************************************************************************
--  IsIndicatorBalanceOrPnL : EsIndicatorBalanceoPyg
--
--  DESCRIPTION:
--     Return TRUE if the indicator is type Balance or PnL
--
--  PARAMETERS:
--     Ind: indicator code
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function IsIndicatorBalanceOrPnL(Ind IN Integer, pUseGIndics boolean)  return Boolean IS
Begin
  If IsIndicatorBalance(Ind, pUseGIndics) Or IsIndicatorPnL(Ind, pUseGIndics) Then
	   return true;
  Else
	   return false;
  END IF;

  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in IsIndicatorBalanceOrPnL for '||ind||' : '||g_error);
	RAISE;

End;

--****************************************************************************
--  CopyOfColDataColumns
--
--  DESCRIPTION:
--     Returns a copy of the given data columns collection
--     colDataColumns is collection of object of class clsDataField
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function CopyOfColDataColumns(colDataColumns IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField)
return BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField IS
Begin
	return colDataColumns;
End ;


--****************************************************************************
--  CalcCartesianProduct : CalcProdCartesiano
--
--  DESCRIPTION:
--     Calculate in the multidimensional array p_cartesian_product() all points
--     of a n-dimensional space. The number of dimensions is given in the
--     perameter p_num_dimensions.
--     The number of intervals in the dimension i is in the array
--     dimensionSizes(i)
--     Example: If p_num_dimensions = 3 and dimensionSizes = |3|2|1|
--     p_cartesian_product = |1|1|1|
--               |1|2|1|
--                |2|1|1|
--                |2|2|1|
--                |3|1|1|
--                |3|2|1|
--     Note: The intervals in the dimension i are enumerated from 1 to
--     dimensionSizes(i). It does not include 0.
--
--  PARAMETERS:
--     p_cartesian_product(): Matrix to initialize.
--     p_num_dimensions: Number of dimensions
--     dimensionSizes(): Array with the size of each dimension
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************


PROCEDURE CalcCartesianProduct(p_cartesian_product IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE,
                   p_num_dimensions IN Integer,
                   dimensionSizes IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE) IS

  l_num_tables NUMBER;
  iTimes NUMBER;
  l_repeat_count NUMBER;
  iRow NUMBER;
BEGIN

  If p_num_dimensions = 0 Then
      return;
  END IF;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Inside CalcCartesianProduct, p_num_dimensions='||p_num_dimensions||' p_cartesian_product is ');
    bsc_mo_helper_pkg.write_this(p_cartesian_product, FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.writeTmp( 'dimensionSizes is ', FND_LOG.LEVEL_STATEMENT);
    bsc_mo_helper_pkg.write_this(dimensionSizes, FND_LOG.LEVEL_STATEMENT);
  END IF;

  l_num_tables := 1;
  For i in  0..p_num_dimensions - 1 LOOP
      l_num_tables := l_num_tables * dimensionSizes(i);
  END LOOP;


  iTimes := 1;
  l_repeat_count := l_num_tables;
  For i in  0..p_num_dimensions - 1 LOOP
      iRow := 0;
      l_repeat_count := floor(l_repeat_count / dimensionSizes(i));
      For iIterations in 1.. iTimes LOOP
        For iPoints IN  1..dimensionSizes(i) LOOP
          For iRepeat in 1..l_repeat_count LOOP
              p_cartesian_product(i*l_num_tables+iRow) := iPoints;
              iRow := iRow + 1;
          END LOOP;
        END LOOP;
      END LOOP;
      iTimes := iTimes * dimensionSizes(i);

  END LOOP;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Compl. CalcCartesianProduct, Cartesian product is ', FND_LOG.LEVEL_PROCEDURE);
      bsc_mo_helper_pkg.write_this(p_cartesian_product, FND_LOG.LEVEL_STATEMENT);
      bsc_mo_helper_pkg.writeTmp( 'dimensionSizes is ', FND_LOG.LEVEL_STATEMENT);
      bsc_mo_helper_pkg.write_this(dimensionSizes, FND_LOG.LEVEL_STATEMENT);
	END IF;

  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in CalcCartesianProduct '||g_error);
	RAISE;

End ;

FUNCTION getRecursiveDimensions return VARCHAR2 IS
l_dim_list bsc_varchar2_table_type;
l_num_dim_list number := 0;
l_error varchar2(1000);
BEGIN
  bsc_olap_main.get_list_of_rec_dim(l_dim_list, l_num_dim_list, l_error);
  gRecDims := null;
  for i in 1..l_num_dim_list loop
    gRecDims := gRecDims||''''||l_dim_list(i)||'''';
    if (i <> l_num_dim_list) then
      gRecDims := gRecDims ||',';
    end if;
  end loop;
  return gRecDims;
  EXCEPTION when others then
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in getRecursiveDimensions');
  RAISE;
END;

FUNCTION IsRecursiveKey(pIndicator IN NUMBER, pKey IN VARCHAR2) return BOOLEAN IS
l_stmt VARCHAR2(1000);
l_temp VARCHAR2(1000);
cv CurTyp;
l_num number;
BEGIN
  IF (gRecDims IS NULL) THEN
    gRecDims := getRecursiveDimensions;
  END IF;
  l_stmt := 'select 1 from bsc_kpi_dim_levels_b where indicator =:1
	and level_pk_col = :2
	and level_table_name in	(
	select level_table_name  from bsc_sys_dim_levels_b
	where short_name in ('|| gRecDims||')
           or dim_level_id in
              (select dim_level_id from bsc_sys_dim_level_rels
                where dim_level_id = parent_dim_level_id))
        ';

  OPEN CV for l_stmt using pIndicator, pKey;
  FETCH CV INTO l_num;
  IF (CV%FOUND) THEN -- this is a recursive key
    CLOSE CV;
    bsc_mo_helper_pkg.writeTmp(pKey||' is a recursive key..', FND_LOG.LEVEL_STATEMENT, false);
    return true;
  END IF;
  CLOSE CV;
  return false;
  EXCEPTION when others then
  g_error := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg('Exception in isRecursiveKey for Indicator='||pIndicator||', key='||pKey||':'||g_error);
  RAISE;
END;

--****************************************************************************
--GetBasicTables : GetColBasicaTablas
--
--  DESCRIPTION:
--   Generates the collection of base tables of the indicator.
--   This collection is of objects of class clsBasicaTablas
--
--  PARAMETERS:
--   Indicator: indicator code
--   Configuration: configuration
--   colDimLevelCombinations: collection of combinations of drill families
--   p_dimension_families: collection of families of drills of the indicator
--   forTargetLevel: true  -The procedure is called to get base tables for targets
--   colDataColumns: collection of data columns
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetBasicTables(Indicator IN  BSC_METADATA_OPTIMIZER_PKG.clsIndicator, Configuration IN NUMBER,
                   colDimLevelCombinations IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations,
                   p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
                   forTargetLevel IN Boolean,
                   colDataColumns IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField)
                   RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable IS

  colBasicaTablas  BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable;
  Basica BSC_METADATA_OPTIMIZER_PKG.clsBasicTable;
  Basic_keys BSC_METADATA_OPTIMIZER_PKG.tab_clsKeyField;
  Basic_data BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;

  CampoLlave BSC_METADATA_OPTIMIZER_PKG.clsKeyField;
  p_cartesian_product DBMS_SQL.NUMBER_TABLE;

  NumDimensions NUMBER;
  NumLevels NUMBER;
  dimensionSizes dbms_sql.number_table;
  idimension NUMBER;
  i NUMBER;
  j NUMBER;

  l_index1 NUMBER;
  l_index2 NUMBER;

  iPoints NUMBER;
  lstCodsDriles varchar2(1000);
  cLevel varchar2(1000);
  ConfDriles varchar2(1000);
  NumFamilias NUMBER;
  ifamilia NUMBER;
  Dril BSC_METADATA_OPTIMIZER_PKG.clsLevels;
  Dril1 BSC_METADATA_OPTIMIZER_PKG.clsLevels;
  msg varchar2(1000);
  TableNameStart varchar2(1000);
  l_temp NUMBER;
  l_tempv VARCHAR2(100);

  l_groups DBMS_SQL.NUMBER_TABLE;
  l_group_id NUMBER;
  l_drillCombination BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations;
  l_drillCombination2 BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations;

  l_drillString VARCHAR2(4000);
  l_drillTable DBMS_SQL.VARCHAR2_TABLE;

  l_level_groups DBMS_SQL.NUMBER_TABLE;
  l_level_group_id NUMBER;
  l_dimLevels  BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;

BEGIN
  l_groups := BSC_MO_HELPER_PKG.getGroupIDs(colDimLevelCombinations);
  l_level_groups := BSC_MO_HELPER_PKG.getGroupIDs(p_dimension_families);
  NumDimensions := l_groups.count;
  bsc_mo_helper_pkg.writeTmp( 'Inside GetBasicTables, Configuration ='||Configuration||', forTargetLevel ='
        ||bsc_mo_helper_pkg.boolean_decode(forTargetLevel ) ||', System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_PROCEDURE, FALSE);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
	bsc_mo_helper_pkg.writeTmp( 'Indicator is ');
    bsc_mo_helper_pkg.write_this(Indicator);
    bsc_mo_helper_pkg.writeTmp( 'colDimLevelCombinations is as above');
    bsc_mo_helper_pkg.writeTmp( 'p_dimension_families is as above');
    bsc_mo_helper_pkg.writeTmp( 'colDataColumns is as above');
  END IF;
  If forTargetLevel Then
    TableNameStart := 'BSC_SB_';
  Else
    TableNameStart := 'BSC_S_';
  END IF;


  If NumDimensions = 0 Then
    --The indicator does not have dimensions. It does not have any level.
    --Only one table
    --Name
    Basica := BSC_MO_HELPER_PKG.new_clsBasicTable;
    Basica.Name := TableNameStart || Indicator.Code || '_'||  Configuration || '_'|| '0';
    --Keys
    --It does not have. The table only has YEAR TYPE PERIOD
    --Confdriles is  ''
    --TablaOri is ''
    IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('  ');
      bsc_mo_helper_pkg.writeTmp('Adding colBasicaTablas, Basica is ');
      bsc_mo_helper_pkg.write_this(Basica);
    END IF;
    Basica.keys := Basic_keys;
    Basica.data := colDataColumns;
    --BSC_MO_HELPER_PKG.insertBasicTable(Basica, Basic_keys, colDataColumns);
    colBasicaTablas(colBasicaTablas.count) := Basica;
  Else
    --The indicator has at least one dimension
    --Calculate the cartesian product between the combinations of each dimension level
    NumLevels := 0;
    For i in 0..NumDimensions-1 LOOP
      l_drillCombination := BSC_MO_HELPER_PKG.get_tab_clsLevelCombinations(colDimLevelCombinations, l_groups(i));
      dimensionSizes(i) := l_drillCombination.Count;
      If NumLevels = 0 Then
        NumLevels := dimensionSizes(i);
      Else
        NumLevels := NumLevels * dimensionSizes(i);
      END IF;
    END LOOP;
    CalcCartesianProduct( p_cartesian_product, NumDimensions, dimensionSizes );
    --One table for each element of the cartesian product
    For iPoints in 0..NumLevels - 1        LOOP
      --Keys
      --Add level from each dimension
      lstCodsDriles := null;
      ConfDriles := null;
      Basica := BSC_MO_HELPER_PKG.new_clsBasicTable;
      Basic_keys.delete;
      For idimension IN 0..NumDimensions - 1 LOOP
        l_index1 := to_number(p_cartesian_product(idimension*NumLevels + iPoints))-1;
        l_drillCombination := BSC_MO_HELPER_PKG.get_tab_clsLevelCombinations(colDimLevelCombinations, l_groups(idimension));
        l_drillString := l_drillCombination(l_index1).Levels;
        l_drillTable := bsc_mo_helper_pkg.getDecomposedString(l_drillString, ',');
        j := l_drillTable.first;
        l_tempv :=null;
        LOOP
          EXIT WHEN l_drillTable.count = 0;
          cLevel := l_drillTable(j);
          CampoLlave := bsc_mo_helper_pkg.new_clsKeyField;
          CampoLlave.keyName := cLevel;
          --NecesitaCod0
          --If the level is the first one in the dimension
          --is unique in the combination --> true
          IF l_DrillTable.Count = 1 Then
            l_dimLevels := bsc_mo_helper_pkg.get_tab_clsLevels(p_dimension_families, l_groups(idimension));
            If UPPER(l_dimLevels(0).keyName) = UPPER(cLevel)
              -- AND (NOT IsRecursiveKey(Indicator.code, cLevel))
              Then
              --If the indicator is a Balance or PnL:
              --If the drill is the account drill (the first drill of the first family) then we dont need to calculate zero code
              If IsIndicatorBalanceOrPnL(Indicator.Code, true) And idimension = 0 Then
                CampoLlave.NeedsCode0 := False;
              Else
                CampoLlave.NeedsCode0 := True;
              END IF;
            Else
              CampoLlave.NeedsCode0 := False;
            END IF;
          END IF;
          --CalcularCod0 is false
          CampoLlave.CalculateCode0 := False;
          --FilterViewName
          If Indicator.OptimizationMode <> 0 Then
            --non pre-calculated
            CampoLlave.FilterViewName := null;
          Else
            --pre-calculated
            CampoLlave.FilterViewName := GetFilterViewName(Indicator.Code, Configuration, CampoLlave.keyName);
          END IF;
          --BSC-MV Note: Need this property to store the index of dimension
          --within the kpi
          l_dimLevels := bsc_mo_helper_pkg.get_tab_clsLevels(p_dimension_families, l_groups(idimension));
          CampoLlave.dimIndex := l_dimLevels(bsc_mo_helper_pkg.findIndex(l_dimLevels,  CampoLlave.keyName)).Num;
          --Add the key to the list of keys of the base table
          Basic_keys(Basic_keys.count) := CampoLlave;
          l_temp := BSC_MO_HELPER_PKG.findIndex(l_dimLevels, CampoLlave.keyName);
          lstCodsDriles := lstCodsDriles || l_dimLevels(l_temp).Num;
          EXIT WHEN j = l_drillTable.last;
          j:= l_drillTable.next(j);
        END LOOP;
        ConfDriles := ConfDriles || l_drillCombination(l_index1).levelConfig;
      END LOOP;
      --Name
      --Bug 3108495 If the indicator has several dimensions (more that 10 independent) the
      --name of the table results too long
      Basica.Name := TableNameStart || Indicator.Code || '_' || Configuration || '_' || iPoints;
      IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
        bsc_mo_helper_pkg.writeTmp( ' ');
        bsc_mo_helper_pkg.writeTmp( ' ');
      END IF;
      --ConfDriles
      Basica.levelConfig := order_level_string(ConfDriles, p_dimension_families);
      --Put ? at the begining in case the indicator is Balance or PnL because the drill 0
      --is the Type of Account drill
      If IsIndicatorBalanceOrPnL(Indicator.Code, true) Then
        Basica.levelConfig := '?'|| Basica.levelConfig;
      END IF;
      --TablaOri
      --TablaOri is ''
      Basica.keys := Basic_Keys;
      Basica.Data := colDataColumns;
      colBasicaTablas(colBasicaTablas.count) := Basica;
      --BSC_MO_HELPER_PKG.insertBasicTable(Basica, Basic_Keys, colDataColumns);
    END LOOP;
  END IF;
  bsc_mo_helper_pkg.writeTmp( 'Compl GetBasicTables, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_procedure, false);
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
	  bsc_mo_helper_pkg.writeTmp( 'Returning colBasicaTablas as ');
      bsc_mo_helper_pkg.write_this(colBasicaTablas);
  END IF;
  return colBasicaTablas;

  EXCEPTION WHEN OTHERS THEN
  bsc_mo_helper_pkg.TerminateWithError('BSC_BASICTABLE_DEDUCT_FAILED');
  fnd_message.set_name('BSC', 'BSC_BASICTABLE_DEDUCT_FAILED');
	fnd_message.set_token('INDICATOR', Indicator.code);
  fnd_message.set_token('DIMENSION_SET', Configuration);

  app_exception.raise_exception;


End;



--****************************************************************************
--InsertDataColumnInDBMeasureCols
--
--  DESCRIPTION:
--   Creates the record for the internal column in BSC_DB_MEASURE_COLS_TL
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE  InsertInDBMeasureCols(p_measure IN BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV) IS

l_stmt VARCHAR2(1000);
i NUMBER;

BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
   bsc_mo_helper_pkg.writeTmp( 'Inside InsertInDBMeasureCols, p_measure = ');
	END IF;

   bsc_mo_helper_pkg.write_this(p_measure);
  --Delete the records if exists
  l_stmt := 'DELETE FROM BSC_DB_MEASURE_COLS_TL WHERE MEASURE_COL = :1';
  EXECUTE IMMEDIATE l_stmt using p_measure.fieldName;

  --Because it is a TL table, we need to insert the record for every supported language
  i := BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.first;

  LOOP
      EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.count = 0;
      INSERT INTO BSC_DB_MEASURE_COLS_TL (
      	  MEASURE_COL, LANGUAGE, SOURCE_LANG,
        HELP, MEASURE_GROUP_ID, PROJECTION_ID, MEASURE_TYPE)
		VALUES (p_measure.fieldName, BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages(i),  BSC_METADATA_OPTIMIZER_PKG.gLangCode,
			 p_measure.Description, p_measure.groupCode, p_measure.prjMethod,p_measure.measureType );
      EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.last;
      i := BSC_METADATA_OPTIMIZER_PKG.gInstalled_Languages.next(i);
  END LOOP;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  bsc_mo_helper_pkg.writeTmp( 'Compl. InsertInDBMeasureCols');
	END IF;


  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in InsertInDBMeasureCols '||g_error);
	RAISE;

End;


--****************************************************************************
--AddInternalColumnInDB
--
--  DESCRIPTION:
--   Creates the record for the internal column in BSC_DB_MEASURE_COLS_TL
--   and also added to the collection gLov.
--   Projection method and type (balance or statistic) are deduced from
--   the base columns.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE AddInternalColumnInDB(internalColumn IN VARCHAR2, InternalColumnType NUMBER,
                  baseColumns IN dbms_sql.varchar2_table , numBaseColumns IN NUMBER) IS
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsMeasureLOV;
  i NUMBER;
  prjMethod NUMBER;
  l_temp number;
BEGIN
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Inside AddInternalColumnInDB, internalColumn='||internalColumn
        ||', InternalColumnType='||InternalColumnType||', numBaseColumns='||numBaseColumns||' baseColumns=');
      bsc_mo_helper_pkg.write_this(baseColumns);
	END IF;

  l_measure.fieldName := internalColumn;
  l_measure.source := 'BSC';
  l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(baseColumns.first), 'BSC');

  l_measure.groupCode := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode;
  l_measure.Description :=  BSC_MO_HELPER_PKG.Get_LookUp_Value('BSC_UI_BACKEND', 'INTERNAL_COLUMN');

  IF (InternalColumnType =1) THEN
        --Formula
        --The projection method of the calculated column is deduced from the
        --projection method of the operands:
        --If the projection method for one of the operands is 'No forecast'
        --then the projection method for the calculated column is 'No forecast'
        --Else, If the projection method of one of the operands is 'Custom' then:
        --If the projection method of one of the operands is 'Plan-based' then
        --the projection method of the calculated column is 'Plan-based'
        --Else, the projection method is 'Moving Average'
        --Else, if the projection method of one of the operands is 'Plan-based' then
        --the projection method of the calculated column is 'Plan-based'.
        --Else, the projection method of the calculated column is 'Moving Average'
        --Projection methods:
        --0: No Forecast
        --1: Moving Averge
        --3: Plan-Based
        --4: Custom
        l_measure.prjMethod := 1; --Moving average has the lowest priority
        i := baseColumns.first;
        LOOP
          EXIT WHEN baseColumns.count = 0;
          l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(i), 'BSC');
          prjMethod := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod;
          If prjMethod = 0 Then
              --No forecast
              l_measure.prjMethod := 0;
              EXIT;
          END IF;

          If prjMethod = 3 Then
              --Plan-Based
              l_measure.prjMethod := 3;
          Else
              --Moving Average of Custom
              If l_measure.prjMethod <> 3 Then
                l_measure.prjMethod := 1;
              END IF;
          END IF;
          EXIT WHEN i = baseColumns.last;
          i := baseColumns.next(i);
        END LOOP;

        --The type of the calculated column (Balance or Statistics) is
        --deduced from the type of the operands. If at least one of the operands
        --is Balance Type, then the calculated column is Balance.
        --Measure types:
        --1: Statistic
        --2: Balance
        i := baseColumns.first;
        LOOP
          EXIT WHEN baseColumns.count = 0;
          l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(i), 'BSC');
          l_measure.measureType := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).measureType;
          If l_measure.measureType = 2 Then
              EXIT;
          END IF;
          EXIT WHEN i = baseColumns.last;
          i := baseColumns.next(i);
        END LOOP;
  ELSIF (InternalColumnType=2 OR InternalColumnType=3) THEN
        --Total and counter for Average at Lowest Level

        --Projection method and type are the same of the base column
        --In this case there is only one base column
        l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, baseColumns(baseColumns.first), 'BSC');
        l_measure.prjMethod := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod;
        l_measure.measureType := BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).measureType;
  END IF;

  If Not FieldExistsInLoV(internalColumn, 'BSC') Then
      IF (BSC_METADATA_OPTIMIZER_PKG.gLov.count>0) THEN
        BSC_METADATA_OPTIMIZER_PKG.gLov(BSC_METADATA_OPTIMIZER_PKG.gLov.last+1) := l_measure;
      ELSE
        BSC_METADATA_OPTIMIZER_PKG.gLov(0) := l_measure;
      END IF;
  Else
      --Update the filed with the new information
      l_temp := bsc_mo_helper_pkg.findIndex(BSC_METADATA_OPTIMIZER_PKG.gLov, internalColumn, 'BSC');
      BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).groupCode := l_measure.groupCode;
      BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).Description := l_measure.Description;
      BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).measureType := l_measure.measureType;
      BSC_METADATA_OPTIMIZER_PKG.gLov(l_temp).prjMethod := l_measure.prjMethod;
  END IF;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Going to InsertInDBMeasureCols');
	END IF;

  InsertInDBMeasureCols( l_measure);

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Compl AddInternalColumnInDB');
	END IF;


  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in AddInternalColumnInDB : '||g_error||', l_temp='||l_temp||', baseColumns(baseColumns.first)='||baseColumns(baseColumns.first)||' list of values is ');
    BSC_MO_HELPER_PKG.write_this(BSC_METADATA_OPTIMIZER_PKG.gLov, FND_LOG.LEVEL_EXCEPTION, true);
      raise;
End;



--****************************************************************************
--SetMeasurePropertyDB
--  DESCRIPTION:
--   Update the given proeprty of the meaaure in the column
--   S_COLOR_FORMULA of BSC_SYS_MEAURES
--   given data column
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

PROCEDURE SetMeasurePropertyDB(dataColumn IN VARCHAR2, propertyName IN VARCHAR2, propertyValue IN VARCHAR2)
IS
   l_stmt VARCHAR2(1000);

BEGIN
  UPDATE BSC_SYS_MEASURES
	SET S_COLOR_FORMULA = BSC_APPS.SET_PROPERTY_VALUE(S_COLOR_FORMULA, propertyName, propertyValue)
	WHERE UPPER(MEASURE_COL) =  upper(dataColumn)
	AND TYPE = 0 AND NVL(SOURCE, 'BSC') = 'BSC';

  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in SetMeasurePropertyDB : '||g_error);
      raise;
End;



--***************************************************************************
--GetAgregFunction : GetAggregateFunction
--  DESCRIPTION:
--   Returns in FuncAgreg and pAvgL the aggregation function of the
--   given data column
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE GetAggregateFunction(dataColumn IN VARCHAR2, FuncAgreg IN OUT NOCOPY VARCHAR2, pAvgL IN OUT NOCOPY VARCHAR2,
              AvgLTotalColumn IN OUT NOCOPY VARCHAR2, AvgLCounterColumn IN OUT NOCOPY VARCHAR2) IS

  l_stmt VARCHAR2(1000);
  aggFunction VARCHAR2(1000);
CURSOR C1(p1 VARCHAR2, p2 VARCHAR2, p3 VARCHAR2, p4 VARCHAR2) IS
SELECT NVL(OPERATION, 'SUM') AS OPER,
 NVL(BSC_APPS.GET_PROPERTY_VALUE(S_COLOR_FORMULA, p1),'N') AS PAVGL,
 BSC_APPS.GET_PROPERTY_VALUE(S_COLOR_FORMULA, p2) AS PAVGLTOTAL,
 BSC_APPS.GET_PROPERTY_VALUE(S_COLOR_FORMULA, p3) AS PAVGLCOUNTER
 FROM BSC_SYS_MEASURES
 WHERE UPPER(MEASURE_COL) = UPPER(p4)
 AND TYPE = 0
 AND NVL(SOURCE, 'BSC') = 'BSC';

cRow c1%ROWTYPE;

BEGIN
  OPEN c1(BSC_METADATA_OPTIMIZER_PKG.C_PAVGL,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER,
		dataColumn);
  FETCH c1 INto cRow;
  If c1%NOTFOUND Then
      FuncAgreg := null;
      pAvgL := null;
      AvgLTotalColumn := null;
      AvgLCounterColumn := null;
  Else
      FuncAgreg := cRow.OPER;
      pAvgL := cRow.PAVGL;
      AvgLTotalColumn := null;
      If (crow.PAVGLTOTAL is not null) Then
        AvgLTotalColumn := cRow.PAVGLTOTAL;
      END IF;
      AvgLCounterColumn := null;
      If (cRow.PAVGLCOUNTER IS NOT NULL) Then
        AvgLCounterColumn := cRow.PAVGLCOUNTER;
      END IF;
  END IF;
  close c1;

  EXCEPTION WHEN OTHERS THEN
  g_error := sqlerrm;
  BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in GetAggregateFunction '||g_error);
	RAISE;

End;

--***************************************************************************
--getNextInternalColumnName
--  DESCRIPTION:
--   Returns the next Internal Column Name
--   BSCIC<next value from sequence BSC_INTERNAL_COLUMN_S>
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function getNextInternalColumnName RETURN VARCHAR2 IS
l_seq NUMBER;


BEGIN
  SELECT BSC_INTERNAL_COLUMN_S.NEXTVAL INTO l_seq FROM DUAL;
	return 'BSCIC'||l_seq;
End;

--****************************************************************************
--DataFieldExists : ExisteCampoDato
--  DESCRIPTION:
--   Returns TRUE if the field exist in the collection. The collection
--   if of objects of class clsDataField
--
--  PARAMETERS:
--   colMeasures: collection
--   measure: field name
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function dataFieldExists(colMeasures IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField, measure IN VARCHAR2)
RETURN BOOLEAN IS
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  i NUMBER;

BEGIn

  IF colMeasures.count = 0 THEN
      return FALSE;
  END IF;
  i := colMeasures.first;
  LOOP
	   l_measure := colMeasures(i);
     If (UPPER(l_measure.fieldName) = UPPER(measure)) Then
		  return true;
     END IF;
	   EXIT WHEN i = colMeasures.last;
	   i := colMeasures.next(i);
  END LOOP;
  return false;

  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception dataFieldExists, '||g_error);
      raise;
End;

--****************************************************************************
--DataFieldExists : ExisteCampoDato
--  DESCRIPTION:
--   Returns TRUE if the field exist in the collection. The collection
--   if of objects of class clsCampoDatos
--
--  PARAMETERS:
--   colMeasures: collection
--   measure: field name
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function dataFieldExistsForSource(colMeasures IN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField,
  measure IN VARCHAR2,
  p_source IN VARCHAR2
  )
RETURN BOOLEAN IS
  l_measure BSC_METADATA_OPTIMIZER_PKG.clsDataField;
  i NUMBER;
BEGIn
  IF colMeasures.count = 0 THEN
    return FALSE;
  END IF;
  i := colMeasures.first;
  LOOP
	l_measure := colMeasures(i);
    If (UPPER(l_measure.fieldName) = UPPER(measure) and l_measure.source=p_source) Then
	  return true;
    END IF;
	EXIT WHEN i = colMeasures.last;
	i := colMeasures.next(i);
  END LOOP;
  return false;
  EXCEPTION WHEN OTHERS THEN
      g_error := sqlerrm;
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception dataFieldExistsForSource, '||g_error);
      raise;
End;

--****************************************************************************
--  GetCamposExpresion
--
--   DESCRIPTION:
--     Get in an array the list of fields in the given expression.
--     Return the number of fields.
--     Example. Expresion = 'IIF(Not IsNull(SUM(A)), C, B)'
--     CamposExpresion() = |A|C|B|, GetCamposExpresion = 3
--  PARAMETERS:
--     CamposExpresion(): array to be populated
--     Expresion: expression
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--****************************************************************************
Function GetFieldExpresion(CamposExpresion IN OUT NOCOPY dbms_sql.varchar2_table, Expresion IN VARCHAR2) return NUMBER IS
  i NUMBER;

  NumCamposExpresion VARCHAR2(1000);
  Campos dbms_sql.varchar2_table;
  NumCampos NUMBER;
  cExpresion VARCHAR2(1000);
BEGIN

  cExpresion := Expresion;
  --Replace the operators by ' '
  i := BSC_METADATA_OPTIMIZER_PKG.gReservedOperators.first;

  LOOP
	   cExpresion := Replace(cExpresion, BSC_METADATA_OPTIMIZER_PKG.gReservedOperators(i), ' ');
     EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gReservedOperators.last;
     i := BSC_METADATA_OPTIMIZER_PKG.gReservedOperators.next(i);
  END LOOP;

  --Break down the expression which is separated by ' '

  NumCampos := BSC_MO_HELPER_PKG.DecomposeString(cExpresion, ' ', Campos);
  NumCampos := Campos.count;
  NumCamposExpresion := 0;
  i:= Campos.first;
  LOOP
      EXIT WHEN Campos.count = 0;
      If Campos(i) IS NOT NULL Then
        If BSC_MO_HELPER_PKG.FindIndexVARCHAR2(BSC_METADATA_OPTIMIZER_PKG.gReservedFunctions, Campos(i)) = -1 Then
          --The word campos(i) is not a reserved function
          If UPPER(Campos(i)) <> 'NULL' Then
              --the word is not 'NULL'
              If Not  BSC_MO_HELPER_PKG.IsNumber(Campos(i)) Then
                --the word is not a constant
                CamposExpresion(NumCamposExpresion) := Campos(i);
                NumCamposExpresion := NumCamposExpresion + 1;
              END IF;
          END IF;
        END IF;
      END IF;
      EXIT WHEN i = Campos.last;
      i := Campos.next(i);
  END LOOP;
	return NumCamposExpresion;

  EXCEPTION WHEN OTHERS THEN
      BSC_MO_HELPER_PKG.TerminateWithMsg('Exception in GetFieldExpresion : '||sqlerrm);
      raise;

End;


--***************************************************************************
--clearDataFields
--  DESCRIPTION:
--   Get the list of data fields for an indicator. It is returned in a
--   collection of object of class clsDataField
--
--  PARAMETERS:
--   Indic: indicator code
--   Configuration: configuration
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

PROCEDURE clearDataField(dataField IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.clsDataField) IS
  dataField_null BSC_METADATA_OPTIMIZER_PKG.clsDataField;
BEGIN
  dataField:=dataField_null ;
END;


--****************************************************************************
--GetDataFields
--  DESCRIPTION:
--   Get the list of data fields for an indicator. It is returned in a
--   collection of object of class clsDataField
--
--  PARAMETERS:
--   Indic: indicator code
--   Configuration: configuration
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function GetDataFields(Indic IN NUMBER, Configuration IN NUMBER, WithInternalColumns IN Boolean)
 RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField IS

    l_stmt  VARCHAR2(1000);
    l_measure_name varchar2(1000);
    l_measure_names_list dbms_sql.varchar2_table;
    l_num_measures NUMBER;
    FuncAgreg varchar2(1000);
    l_measure_column BSC_METADATA_OPTIMIZER_PKG.clsDataField;
    l_col_measure_columns BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
    TenerEnCuentaCampo NUMBER;
    i  NUMBER;
    msg VARCHAR2(1000);

    pFormulaSource VARCHAR2(1000);
    pAvgL VARCHAR2(1000);
    pAvgLTotal VARCHAR2(1000);
    pAvgLCounter VARCHAR2(1000);
    FuncAgregSingleColumn VARCHAR2(1000);
    pAvgLSingleColumn VARCHAR2(1000);
    AvgLTotalColumn VARCHAR2(1000);
    AvgLCounterColumn VARCHAR2(1000);
    baseColumn dbms_sql.varchar2_table;

 l_stmt2 VARCHAR2(10000):= 'SELECT M.MEASURE_COL, NVL(M.OPERATION, ''SUM'') AS OPER,
 BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :1) AS PFORMULASOURCE,
 NVL(BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :2 ),''N'') AS PAVGL,
 BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :3) AS PAVGLTOTAL,
 BSC_APPS.GET_PROPERTY_VALUE(M.S_COLOR_FORMULA, :4) AS PAVGLCOUNTER '||
 -- BSC Autogen
 ', nvl(M.SOURCE, ''BSC'')
 FROM BSC_SYS_MEASURES M, '||BSC_METADATA_OPTIMIZER_PKG.g_dbmeasure_tmp_table||' I
 WHERE I.MEASURE_ID = M.MEASURE_ID
 AND I.DIM_SET_ID = :5
 AND I.INDICATOR = :6
 AND M.TYPE = 0';

 L_MEASURE_COL VARCHAR2(4000);
 L_OPER VARCHAR2(100);
 L_PFORMULASOURCE VARCHAR2(1000);
 L_PAVGL VARCHAR2(1000);
 L_PAVGLTOTAL VARCHAR2(1000);
 L_PAVGLCOUNTER VARCHAR2(1000);
 l_source VARCHAR2(100);
 cv CurTyp;

BEGIN
  bsc_mo_helper_pkg.writeTmp( 'Inside GetDataFields, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, false);
  select short_name into l_source from bsc_kpis_vl
  where indicator=Indic;
  -- Bug 4301819
  -- Dont include PMF measures if this is created by objective definer
  IF (l_source is null) THEN -- created by objective definer
    l_stmt2 := l_stmt2 ||' AND NVL(M.SOURCE, ''BSC'') = ''BSC''';
  ELSE -- created by Report definer
    l_stmt2 := l_stmt2 ||' AND NVL(M.SOURCE, ''BSC'') IN (''BSC'',''PMF'')';
  END IF;
  l_stmt2 := l_stmt2 ||' ORDER BY MEASURE_COL ';
  l_source := null;
  -- BSC Autogen, comment below no longer valid
  --BSC-PMF Integration: Even though a PMF measure cannot be present in a BSC
  --dimension set, I am going to do the validation to filter out PMF measures
  OPEN cv for l_stmt2 USING BSC_METADATA_OPTIMIZER_PKG.C_PFORMULASOURCE,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGL,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL,
		BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER, Configuration, Indic;
  LOOP
    FETCH cv INTO L_MEASURE_COL, L_OPER, L_PFORMULASOURCE, L_PAVGL, L_PAVGLTOTAL, L_PAVGLCOUNTER, l_source ;
    EXIT WHEN cv%NOTFOUND;
    FuncAgreg := L_OPER;
    l_measure_name := L_MEASURE_COL;
    pFormulaSource := null;
    If (L_PFORMULASOURCE IS NOT NULL) Then
    pFormulaSource := L_PFORMULASOURCE;
    END IF;
    pAvgL := L_PAVGL;
    pAvgLTotal := null;
    If (L_PAVGLTOTAL IS NOT NULL) Then
      pAvgLTotal := L_PAVGLTOTAL;
    END IF;
    pAvgLCounter := null;
    If (L_PAVGLCOUNTER IS NOT NULL) Then
      pAvgLCounter := L_PAVGLCOUNTER;
    END IF;
    l_num_measures := GetFieldExpresion(l_measure_names_list, l_measure_name);
    l_num_measures := l_measure_names_list.count;
	FOR i IN l_measure_names_list.first..l_measure_names_list.last LOOP
	  If fieldExistsINLOV(l_measure_names_list(i), l_source) Then
        If Not DataFieldExists(l_col_measure_columns, l_measure_names_list(i)) Then
        --Get the aggregation function and Avgl flag of the column (single column)
          bsc_mo_helper_pkg.writeTmp('Getting the aggregate function for '||l_measure_names_list(i));
		  GetAggregateFunction (l_measure_names_list(i), FuncAgregSingleColumn, pAvgLSingleColumn, AvgLTotalColumn, AvgLCounterColumn);
          bsc_mo_helper_pkg.writeTmp('FuncAgregSingleColumn='||FuncAgregSingleColumn||', pAvgLSingleColumn='||pAvgLSingleColumn
            ||', AvgLTotalColumn='||AvgLTotalColumn||', AvgLCounterColumn='||AvgLCounterColumn);
          If FuncAgregSingleColumn IS NULL Then
		    FuncAgregSingleColumn := FuncAgreg;
		  END IF;
          If pAvgLSingleColumn IS NULL Then
		    pAvgLSingleColumn := pAvgL;
		  END IF;
		  l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
          l_measure_column.fieldName := l_measure_names_list(i);
          l_measure_column.source := nvl(l_source, 'BSC');
          l_measure_column.aggFunction := FuncAgregSingleColumn;
          --l_measure_column.Origen is not set
          l_measure_column.AvgLFlag := pAvgLSingleColumn;
          bsc_mo_helper_pkg.writeTmp('l_measure_column.fieldName='||l_measure_column.fieldName||',l_measure_column.aggFunction='||
	      l_measure_column.aggFunction||', pAvgLSingleColumn='||pAvgLSingleColumn);
		  If pAvgLSingleColumn = 'Y' And WithInternalColumns Then
            --This is a single column, we can have AvgL on a single column.
            --We need to internal columns: one for total and one for counter
            --Also we need to add the internal columns in gLov and in
            --BSC_DB_MEASURES_COLS_TL table
            baseColumn(0) := l_measure_names_list(i);
            If AvgLTotalColumn IS NULL Then
              AvgLTotalColumn := getNextInternalColumnName;
              --Update the measure property pAvgLTotal in the database
              SetMeasurePropertyDB (l_measure_names_list(i), BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL, AvgLTotalColumn);
            END IF;
            l_measure_column.AvgLTotalColumn := AvgLTotalColumn;
            AddInternalColumnInDB(AvgLTotalColumn, 2, baseColumn, 1);
            If AvgLCounterColumn IS NULL Then
              AvgLCounterColumn := getNextInternalColumnName;
              --Update the measure property pAvgLCounter in the database
              SetMeasurePropertyDB (l_measure_names_list(i), BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER, AvgLCounterColumn);
            END IF;
            l_measure_column.AvgLCounterColumn := AvgLCounterColumn;
            AddInternalColumnInDB(AvgLCounterColumn, 3, baseColumn, 1);
          END IF;
          l_measure_column.InternalColumnType := 0 ; --Normal
          l_col_measure_columns(l_col_measure_columns.count) :=  l_measure_column;
          If pAvgLSingleColumn = 'Y' And WithInternalColumns Then
            --Add the two internal column for AvgL in the collection
            --Column for Total
            l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
            l_measure_column.fieldName := AvgLTotalColumn;
            l_measure_column.source := nvl(l_source, 'BSC');
            l_measure_column.aggFunction := 'SUM';
            --l_measure_column.Origen is not set
            l_measure_column.AvgLFlag := 'N';
            --l_measure_column.avgLTotalColumn does not apply
            --l_measure_column.avgLCounterColumn does not apply
            l_measure_column.InternalColumnType := 2; --Internal column for Total of AvgL
            l_measure_column.InternalColumnSource := l_measure_names_list(i);
            l_col_measure_columns(l_col_measure_columns.count) := l_measure_column;
            --Column for Counter
            l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
            l_measure_column.fieldName := AvgLCounterColumn;
            l_measure_column.source := nvl(l_source, 'BSC');
            l_measure_column.aggFunction := 'SUM';
            --l_measure_column.Origen is not set
            l_measure_column.AvgLFlag := 'N';
            --l_measure_column.avgLTotalColumn does not apply
            --l_measure_column.avgLCounterColumn does not apply
            l_measure_column.InternalColumnType := 3; --Internal column for Counter of AvgL
            l_measure_column.InternalColumnSource := l_measure_names_list(i);
            l_col_measure_columns(l_col_measure_columns.last + 1) := l_measure_column;
          END IF;-- END OF If pAvgLSingleColumn = 'Y' And WithInternalColumns
        --BSC Autogen
		ELSE
		  --Bug 4273572
		  If DataFieldExistsForSource(l_col_measure_columns, l_measure_names_list(i), l_source) THEN
		    null;--ignore this as we may have a, b and (a+b)
		  ELSE
		    -- raise error, two measures with same name (possibly one PMF and one BSC)
            fnd_message.set_name('BSC', 'BSC_PMA_OPT_DUP_MEASURE');
            fnd_message.set_token('OBJECTIVE', Indic);
            fnd_message.set_token('MEASURE_NAME', l_measure_names_list(i));
            g_error := fnd_message.get;
            bsc_mo_helper_pkg.writeTmp('ERROR BSC_PMA_OPT_DUP_MEASURE(Duplicate measure names) : '||g_error, FND_LOG.LEVEL_EXCEPTION, true);
            bsc_mo_helper_pkg.terminateWithMsg(g_error);
            raise bsc_metadata_optimizer_pkg.optimizer_exception ;
	        EXIT ;
	      END IF;
		END IF;
      Else
        fnd_message.set_name('BSC', 'BSC_FIELDNME_NOT_REGISTERED');
        fnd_message.set_token('FIELD_NAME', l_measure_names_list(i));
        fnd_message.set_token('INDICATOR_CODE', Indic);
        g_error := fnd_message.get;
        IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
          bsc_mo_helper_pkg.writeTmp(g_error);
		  bsc_mo_helper_pkg.writeTmp('ERROR : BSC_FIELDNME_NOT_REGISTERED : '||g_error);
        END IF;
	    bsc_mo_helper_pkg.terminateWithMsg(g_error);
        raise bsc_metadata_optimizer_pkg.optimizer_exception ;
	    EXIT ;
      END IF;
    END LOOP;
    --Now add internal column if the formula needs to calculated in another column
    If WithInternalColumns Then
      If pFormulaSource IS NOT NULL Then
        --Add the internal column in gLov and in BSC_DB_MEASURES_COLS_TL table
        AddInternalColumnInDB(pFormulaSource, 1, l_measure_names_list, l_num_measures);
        l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
        l_measure_column.fieldName := pFormulaSource;
        l_measure_column.source := nvl(l_source, 'BSC');
        l_measure_column.aggFunction := FuncAgreg;
        --l_measure_column.Origen is not set
        l_measure_column.AvgLFlag := pAvgL;
        If pAvgL = 'Y' Then
        --This is a formula calculated in another column, we can have AvgL on a that.
        --We need to internal columns: one for total and one for counter
        --Also we need to add the internal columns in gLov and in
        --BSC_DB_MEASURES_COLS_TL table
        If pAvgLTotal IS NULL Then
          pAvgLTotal := getNextInternalColumnName ;
          --Update the measure property pAvgLTotal in the database
          SetMeasurePropertyDB( l_measure_name, BSC_METADATA_OPTIMIZER_PKG.C_PAVGLTOTAL, pAvgLTotal);
        END IF;
        AddInternalColumnInDB(pAvgLTotal, 2, l_measure_names_list, l_num_measures);
        l_measure_column.AvgLTotalColumn := pAvgLTotal;
        If pAvgLCounter IS NULL Then
          pAvgLCounter := getNextInternalColumnName;
          --Update the measure property pAvgLTotal in the database
          SetMeasurePropertyDB( l_measure_name, BSC_METADATA_OPTIMIZER_PKG.C_PAVGLCOUNTER, pAvgLCounter);
        END IF;
        AddInternalColumnInDB( pAvgLCounter, 3, l_measure_names_list, l_num_measures);
        l_measure_column.AvgLCounterColumn := pAvgLCounter;
      END IF;
      l_measure_column.InternalColumnType := 1; --Internal column for formula
      l_measure_column.InternalColumnSource := l_measure_name; -- Formula Example A/B
      l_col_measure_columns(l_col_measure_columns.last +1 ) :=  l_measure_column;
      If pAvgL = 'Y' Then
        --Add the two internal column for AvgL in the collection
        --Bug 2993089: When the column is not a formula but has the option
        --Apply rollup to formula', the columns for Average at lowest level
        --are already in colCamporDatos.
        --We need to evaluate this situation adding te condition
        --If Not ExisteCampoDato(l_col_measure_columns, <internal column for AvgL>)
        --Column for Total
        If Not DataFieldExists(l_col_measure_columns, pAvgLTotal) Then
		  l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
          l_measure_column.fieldName := pAvgLTotal;
          l_measure_column.source := nvl(l_source, 'BSC');
          l_measure_column.aggFunction := 'SUM';
          --l_measure_column.Origen is not set
          l_measure_column.AvgLFlag := 'N';
          l_measure_column.InternalColumnType := 2; -- 'Internal column for Total of AvgL
          l_measure_column.InternalColumnSource := l_measure_name; -- 'Formula Example A/B
          l_col_measure_columns(l_col_measure_columns.last+1) :=  l_measure_column ;
        END IF;
        --Column for Counter
        If Not DataFieldExists(l_col_measure_columns, pAvgLCounter) Then
          l_measure_column := bsc_mo_helper_pkg.new_clsDataField;
          l_measure_column.fieldName := pAvgLCounter;
          l_measure_column.source := nvl(l_source, 'BSC');
          l_measure_column.aggFunction := 'SUM';
          --l_measure_column.Origen is not set
          l_measure_column.AvgLFlag := 'N';
          --l_measure_column.avgLTotalColumn does not apply
          --l_measure_column.avgLCounterColumn does not apply
          l_measure_column.InternalColumnType := 3; --Internal column for Counter of AvgL
          l_measure_column.InternalColumnSource := l_measure_name; --Formula Example A/B
          l_col_measure_columns(l_col_measure_columns.last+1) := l_measure_column ;
        END IF;
      END IF;
    END IF;
    END IF;
  END Loop;
  close cv;
  bsc_mo_helper_pkg.writeTmp( 'Compl. GetDataFields, System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, false);
  return l_col_measure_columns;
  EXCEPTION WHEN OTHERS THEN
    fnd_message.set_name('BSC', 'BSC_BASICTABLE_DEDUCT_FAILED');
	fnd_message.set_token('INDICATOR', Indic);
    fnd_message.set_token('DIMENSION_SET', Configuration);
    g_error := fnd_message.get;
    bsc_mo_helper_pkg.terminatewithMsg(g_error);
    raise;
  --app_exception.raise_exception;

End;

--****************************************************************************
--GetStrCombinationsMN
--
--  DESCRIPTION:
--   Retunrs all combinations found in a set of strings.
--   The prameter 'combo' is a collection of items of class clsCadema.
--   The function retunrs a collection of items of class
--   Example. combo = 'A', 'B', 'C'
--   GetStrCombinationsMN = 'A', 'B', 'C', 'A' 'B', 'A' 'C', 'B' 'C',
--                  'A' 'B' 'C'
--   Additionally, if exist at least one 1n relation between
--   the elements of the combination then it is rejected.
--  PARAMETERS:
--   combo: set of strings.
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function GetStrCombinationsMN(combo IN dbms_sql.varchar2_table)
 return dbms_sql.varchar2_table IS
  StringCombination dbms_sql.varchar2_table;
  StringCombination1 dbms_sql.varchar2_table;

  Combination dbms_sql.varchar2_table;
  Combination1 dbms_sql.varchar2_table;

  str varchar2(1000);
  str1 varchar2(1000);
  combo1 dbms_sql.varchar2_table;
  i  NUMBER;
  j NUMBER;
  Rel1NExists  Boolean;

  l_temp1 nUMBER;
l_temp2 NUMBER;
BEGIN
  i := combo.first;
  If combo.Count = 1 Then
    StringCombination(0) := combo(combo.first);
    return StringCombination;
  END IF;
  i := combo.first;
  str  := combo(i);
  Combination(0) :=  str;
  StringCombination(0) := str;
  LOOP
    EXIT WHEN i=combo.last;
    i := combo.next(i);
    str  := combo(i);
    combo1(combo1.count):= str;
  END LOOP;
  StringCombination1 := GetStrCombinationsMN(combo1);
  IF (StringCombination1.count > 0) THEN
    i := StringCombination1.first;
  END IF;
  LOOP
    EXIT WHEN StringCombination1.count =0;
    Combination1 := BSC_MO_HELPER_PKG.getDecomposedString(StringCombination1(i), ',');
    Combination.delete;
    IF (Combination1.count >0) THEN
      j:= Combination1.first;
      LOOP
        str := Combination1(j);
        IF (Combination.count>0) THEN
          Combination( Combination.last+1) := str;
        ELSE
          Combination(0) := str;
        END IF;
        EXIT WHEN j = Combination1.last;
        j := Combination1.next(j);
      END LOOP;
    END IF;
    StringCombination(StringCombination.count) :=  BSC_MO_HELPER_PKG.ConsolidateString(Combination, ',');
    EXIT WHEN i =  StringCombination1.last;
    i := StringCombination1.next(i);
  END LOOP;
  IF (StringCombination1.count > 0) THEN
    i := StringCombination1.first;
  END IF;
  LOOP
    EXIT WHEN StringCombination1.count =0;
    Combination1 := BSC_MO_HELPER_PKG.getDecomposedString(StringCombination1(i), ',');
    Rel1NExists := False;
    Combination.delete;
    str := combo(combo.first) ;
    Combination(Combination.count) := str;
    IF (Combination1.count >0) THEN
      j := Combination1.first;
    END IF;
    LOOP
      EXIT WHEN Combination1.count =0;
      str1 := Combination1(j);
      --It is not a combination if there is at least one 1n relation between two drills
      l_temp1 := BSC_MO_HELPER_PKG.FindKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMastertable, str1);
      l_temp2 := BSC_MO_HELPER_PKG.FindKeyIndex(BSC_METADATA_OPTIMIZER_PKG.gMastertable, combo(0));
      If (l_temp1>=0 AND l_temp2>=0 AND
        IndexRelation1N(BSC_METADATA_OPTIMIZER_PKG.gMastertable(l_temp1).Name,
                               BSC_METADATA_OPTIMIZER_PKG.gMastertable(l_temp2).Name) = -1 )Then
        Combination( Combination.count) := str1;
      Else
        Rel1NExists := True;
        Exit;
      END IF;
      EXIT WHEN j = Combination1.last;
      j := Combination1.next(j);
    END LOOP;
    If Not Rel1NExists Then
      StringCombination(StringCombination.count) := BSC_MO_HELPER_PKG.ConsolidateString(Combination, ',');
    END IF;
    EXIT WHEN i = StringCombination1.last;
    i := StringCombination1.next(i);
  END LOOP;
  bsc_mo_helper_pkg.write_this(StringCombination);
  RETURN StringCombination;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.terminateWithMsg( 'Exception in GetStrCombinationsMN '||g_error);
	RAISE;
End;

--****************************************************************************
--GetLevelCombinations
--  DESCRIPTION:
--     Get the collection of combinations of drills of each familiy
--
--  PARAMETERS:
--     p_dimension_families: collection of drill families
--     forTargetLevel: true  -Only take drill with TargetLevel = 1
--                              When calculation targets at different level
--                       false -Take all drill
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function GetLevelCombinations(
        p_dimension_families IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels,
        forTargetLevel IN BOOLEAN)
        RETURN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations IS

  colDimLevelCombinations BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations;
  DimLevelCombinations BSC_METADATA_OPTIMIZER_PKG.tab_clsLevelCombinations;
  LevelCombinations BSC_METADATA_OPTIMIZER_PKG.clsLevelCombinations;

  DrilC VARCHAR2(1000);
  ConfDriles VARCHAR2(1000);

  DimensionLevels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;

  idril NUMBER;
  jDril NUMBER;
  numDriles NUMBER;

  colRelsMN dbms_sql.varchar2_table; --collection of objects of class clsCadena
  RelMN varchar2(1000);

  conjCombinacsMN dbms_sql.varchar2_table;
  CombinacMN dbms_sql.varchar2_table;
  ElementoCombinacMN varchar2(1000);
  indexDrilComparar NUMBER;

  l_ct1 NUMBER ;
  l_ct2 NUMBER ;
  l_ct3 NUMBER;

  l_temp_rel VARCHAR2(100);

  l_groups DBMS_SQL.NUMBER_TABLE;
  DimLevels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
  l_level_group_id NUMBER;
  l_comb_group_id NUMBER := 0;

  l_dummy NUMBER := 0;

  l_varchar_table DBMS_SQL.varchar2_table;
  l_stack VARCHAR2(32000);

BEGIN


	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
  bsc_mo_helper_pkg.writeTmp( 'Inside GetLevelCombinations, p_dimension_families.count is '||p_dimension_families.count);
	END IF;

  bsc_mo_helper_pkg.write_this(p_dimension_families);

  l_groups := BSC_MO_HELPER_PKG.getGroupIds(p_dimension_families);
  IF (l_groups.count >0) THEN
	  l_ct1 := l_groups.first ;
  ELSE
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
     bsc_mo_helper_pkg.writeTmp( 'Compl GetLevelCombinations 0 values');
	END IF;

	   return colDimLevelCombinations;
  END IF;


  --For each drill family, it get the collection of drill combinations

  LOOP
     DimLevelCombinations.delete;
	 DimensionLevels := BSC_MO_HELPER_PKG.get_tab_clsLevels(p_dimension_families, l_groups(l_ct1));
	  --It creates a new element clsCombinacsFliasDriles for the current drill family
      --Go through the list of drills from the end to the beginning of the current drill family
      IF (length(l_stack) > 31000) THEN
        l_stack := null;
      END IF;

      l_stack := l_stack || ' GetLevelCombinations - 1';
      numDriles := DimensionLevels.last;
      idril := numDriles;
      l_stack := l_stack || ' GetLevelCombinations - 2, numDriles = '||numDriles;
	   LOOP
        EXIT WHEN DimensionLevels.count = 0;
        LevelCombinations.Levels := null; -- clear field
        LevelCombinations.LevelConfig := null; -- clear field
        If (Not forTargetLevel) Or (forTargetLevel And DimensionLevels(idril).TargetLevel = 1) Then
          --For each drill it creates a combination of drills
          --It is created with just one element which is the name of the key of the current drill

          DrilC := DimensionLevels(idril).keyName;

          LevelCombinations.Levels :=  DrilC;
          ConfDriles := null;
          --Characters of ConfDriles corresponding to the drills of the right of the current drill are assigned with '1'
		      FOR jDril IN iDril+1..numDriles LOOP
		          ConfDriles := ConfDriles ||'1';
		      END LOOP;
          --The character of ConfDriles that correspond to the current drill:
          If idril = 0 Then --It is the current drill and its the first one
              ConfDriles := '?' || ConfDriles;
          Else
              ConfDriles := '0' || ConfDriles;
          END IF;
          --Characters that correspond to the drills of the left of the current drill
          colRelsMN.delete;



		      FOR jDril IN REVERSE 0..idril-1 LOOP
              l_stack := l_stack || ' GetLevelCombinations - 3, jDril='||jDril;
              If  instr(DimensionLevels(idril).Parents1N, DimensionLevels(jDril).keyName) > 0 Then
                --the current drill is child of jDril
                ConfDriles := '?' || ConfDriles;
              Else
                ConfDriles := '1' || ConfDriles;
                --keep this mn relationship in the collection of mn relationships
                RelMN := DimensionLevels(jDril).keyName;
                colRelsMN(colRelsMN.count):= RelMN;
              END IF;
          END LOOP;
          LevelCombinations.levelConfig := ConfDriles;
          l_stack := l_stack || ' GetLevelCombinations - 4, LevelCombinations.drillConfig='||LevelCombinations.levelConfig;
          --Add the drill combination to the list of drill combinations of the family

          DimLevelCombinations(DimLevelCombinations.count) := LevelCombinations;

          l_stack := l_stack || ' GetLevelCombinations - 4.1';

          -- reorder colRelsMN
          for i in 0..(floor(colRelsMN.count/2)- 1) loop
              l_temp_rel := colRelsMN(i);
              colRelsMN(i) := colRelsMN(colRelsMN.last - i);
              colRelsMN(colRelsMN.last - i) := l_temp_rel;
          end loop;

          If colRelsMN.Count > 0 Then
              l_stack := l_stack || ' GetLevelCombinations - 4.2';
              --Add the drills combinations to the list of drills combinations of the family
              --whose drills are related to drills which has mn relation with the current drill
              --get a set of all posible combinations between the drills which there was mn relationship
          	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp('Calling GetStrCombinationsMN with :');
                bsc_mo_helper_pkg.write_THIS(colRelsMN);
                bsc_mo_helper_pkg.writeTmp('......');
          	END IF;

              conjCombinacsMN := GetStrCombinationsMN(colRelsMN);
          	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
                bsc_mo_helper_pkg.writeTmp('GetStrCombinationsMN returned :');
                bsc_mo_helper_pkg.write_THIS(conjCombinacsMN);
                bsc_mo_helper_pkg.writeTmp('......');
          	END IF;

              l_stack := l_stack || ' GetLevelCombinations - 4.22';

		        IF (conjCombinacsMN.count > 0) THEN
                l_ct3 := conjCombinacsMN.first;
              END IF;
              l_stack := l_stack || ' GetLevelCombinations - 4.23';
		        LOOP

                l_stack := l_stack || ' GetLevelCombinations - 4.25';
			        EXIT WHEN conjCombinacsMN.count=0;
                l_stack := l_stack || '  GetLevelCombinations - 4.3';
			        l_dummy := BSC_MO_HELPER_PKG.decomposeString(conjCombinacsMN(l_ct3), ',', CombinacMN);
                --For each combination MN it has to create an element in the list of drill combinations
                --for the family being analyzed
                --Drills
                --The list of drills is made up of elements of the combination mn andthe current drill
                LevelCombinations := bsc_mo_helper_pkg.new_clsLevelCombinations;
			        l_ct2 := CombinacMN.count;
			        IF (l_ct2 >0) THEN
                  l_ct2 := CombinacMN.first;
                END IF;

			        LOOP
                  EXIT WHEN CombinacMN.count = 0;
                  l_stack := l_stack || ' GetLevelCombinations - 4.4';
                  IF (LevelCombinations.levels IS NOT NULL) THEN
                      LevelCombinations.levels := LevelCombinations.levels||',';
                  END IF;
                  LevelCombinations.levels := LevelCombinations.levels||CombinacMN(l_ct2);
                  EXIT WHEN l_ct2 = CombinacMN.last;
                  l_ct2 := CombinacMN.next(l_ct2);
                END LOOP;
                l_stack := l_stack || ' GetLevelCombinations - 4.41';
                DrilC := DimensionLevels(idril).keyName;
                IF (LevelCombinations.levels IS NOT NULL) THEN
                      LevelCombinations.levels := LevelCombinations.levels||',';
                END IF;
                LevelCombinations.levels := LevelCombinations.levels||DrilC;

                --ConfDriles
                ConfDriles := null;
                --Characters of ConfDriles corresponding to the drills of the right
                --of the current drill are assigned with '1'
			         jDril := idril +1;

			         FOR jDril IN idril+1..numDriles LOOP
                  l_stack := l_stack || ' GetLevelCombinations - 4.5';
                  ConfDriles := ConfDriles || '1';
			         END LOOP;
                --The character of ConfDriles corresponding to the current drill:
                ConfDriles := '0' || ConfDriles;
                --Character corresponding to the left of the current drill
                indexDrilComparar := idril;
                --jDril := idril -1;
						FOR jDril IN REVERSE 0..idril-1 LOOP
                  If BSC_MO_HELPER_PKG.findindexVARCHAR2(CombinacMN, DimensionLevels(jDril).keyName) >= 0 Then
                      --the drill belong to the current mn combination
                      ConfDriles := '0' || ConfDriles;
                      indexDrilComparar := jDril;
                  Else
                      l_dummy := BSC_MO_HELPER_PKG.decomposeString(DimensionLevels(indexDrilComparar).Parents1N, ',', l_varchar_table);
                      If BSC_MO_HELPER_PKG.findindexVARCHAR2(l_varchar_table,
                        DimensionLevels(jDril).keyName) >= 0 Then
                        ConfDriles := '?'||ConfDriles;
                      Else
                        ConfDriles := '1' || ConfDriles;
                      END IF;
                  END IF;
                  l_stack := l_stack || ' GetLevelCombinations - 4.6';
			         END LOOP;
                LevelCombinations.levelConfig := ConfDriles;
                --Add the combination of drills to the list of drill combinations of the family
                IF (DimLevelCombinations.count>0) THEN
                      DimLevelCombinations(DimLevelCombinations.last+1):= LevelCombinations;
                ELSE
                      DimLevelCombinations(0):= LevelCombinations;
                END IF;
                EXIT WHEN l_Ct3 = conjCombinacsMN.last;
                l_ct3 := conjCombinacsMN.next(l_ct3);
              END LOOP;
          END IF;-- colRelsMN.Count > 0
        END IF;--Not forTargetLevel)
        l_stack := l_stack || ' GetLevelCombinations - 4.7, iDril='||iDril;
		  EXIT WHEN idril = DimensionLevels.first;
		  idril := DimensionLevels.prior(idril);
      END LOOP;
      l_stack := l_stack || ' GetLevelCombinations - 5';

      bsc_mo_helper_pkg.add_tabrec_clsLevelComb(colDimLevelCombinations, DimLevelCombinations, l_groups(l_ct1));

      EXIT WHEN l_ct1 = l_groups.last;
	  l_ct1 := l_groups.next(l_ct1);

  END LOOP;

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Compl GetLevelCombinations');
	END IF;


	return colDimLevelCombinations;
  EXCEPTION WHEN OTHERS THEN
      DrilC := sqlerrm;
      bsc_mo_helper_pkg.terminateWithMsg('Exception in GetLevelCOmbinations : '||drilC);
      FND_FILE.put_line(FND_FILE.LOG, l_stack);
      raise;
End;


--****************************************************************************
--IndexFliaDrilesHayRelacion
--
--  DESCRIPTION:
--   Returns the index of the drills family of the collection
--   ColDimLevelFamilies which the given dimension belongs to.
--
--  PARAMETERS:
--   ColDimLevelFamilies: drills families collection
--   Maestra: dimension table name
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function get_dimension_family(tabtabDrills IN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels, dimTable IN VARCHAR2)
return NUMBER IS
  l_levels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
  l_level  BSC_METADATA_OPTIMIZER_PKG.clsLevels;
  l_ct NUMBER := 0;
  l_ct2 NUMBER := 0;
  l_groups DBMS_SQL.NUMBER_TABLE;
  l_dummy NUMBER;
  l_varchar_table DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  IF (tabtabDrills.count =0 ) THEN
	   return -1;
  END IF;
  l_groups := BSC_MO_HELPER_PKG.getgroupids(tabtabDrills);
  --l_ct := l_groups.first;
  FOR l_ct IN l_groups.first..l_groups.last LOOP
    l_levels := BSC_MO_HELPER_PKG.get_tab_clsLevels(tabtabDrills, l_groups(l_ct));
    --l_ct2 := l_levels.first;
    FOR l_ct2 IN l_levels.first..l_levels.last LOOP
      l_level := l_levels(l_ct2);
      If IndexRelation1N(dimTable, l_level.dimTable) >= 0 Then
        -- check none of the other levels have this as a parent level
        /*l_dummy := BSC_MO_HELPER_PKG.decomposeString(l_level.Parents1N, ',', l_varchar_table);
        IF (l_varchar_table.count >0) THEN
          FOR k IN l_varchar_table.first..l_varchar_table.last LOOP
            If IndexRelation1N(l_varchar_Table(k), l_level.dimTable) >= 0 THEN
              return -1;
            END IF;
          END LOOP;
        END IF;
        */
        return l_ct;
      END IF;
      If IndexRelationMN(dimTable, l_level.dimTable) >= 0 Then
        return l_ct;
      END IF;
      --EXIT WHEN l_ct2 = l_levels.last;
      --l_ct2 := l_levels.next(l_ct2);
 	END LOOP;
    --EXIT WHEN l_ct = l_groups.last;
    --l_ct := l_groups.next(l_ct);
  END LOOP;
  return -1;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.terminateWithMsg('Exception in get_dimension_family '||g_error);
	RAISE;
End ;



--****************************************************************************
--GetColDimLevelFamilies
--
--  DESCRIPTION:
--   Get the collection of level families of the indicator
--
--  PARAMETERS:
--   Indic: indicator code
--   Configuration: configuration
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetLevelCollection(Indic IN NUMBER, Configuration IN NUMBER)
RETURN BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels IS
    l_dimension_families BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels;
    DimensionLevels BSC_METADATA_OPTIMIZER_PKG.tab_clsLevels;
    cLevel BSC_METADATA_OPTIMIZER_PKG.clsLevels;
    tDril BSC_METADATA_OPTIMIZER_PKG.clsLevels;

    l_parents1n varchar2(1000);
    l_parentsMN varchar2(1000);
    tPadre1n  varchar2(1000);
    tPadremn varchar2(1000);
    l_dim_index NUMBER;
    l_level_table VARCHAR2(1000);
    l_level_pk_col VARCHAR2(1000);
    Name VARCHAR2(1000);
    TargetLevel NUMBER;
    l_stmt varchar2(1000);
    DimensionLevelsNum NUMBER;
    msg VARCHAR2(1000);
    l_count number;

    l_ct Number;
    cv CurTyp;

    l_group_id NUMBER := 0;
    cdril_parents1N DBMS_SQL.VARCHAR2_TABLE;
    cdril_parentsMN DBMS_SQL.VARCHAR2_TABLE;
    tdril_parents1N DBMS_SQL.VARCHAR2_TABLE;
    tdril_parentsMN DBMS_SQL.VARCHAR2_TABLE;


BEGIN
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Inside GetLevelCollection, Indic = '||Indic||', Configuration = '||Configuration);
  END IF;
  l_stmt := 'SELECT DISTINCT DIM_LEVEL_INDEX, LEVEL_TABLE_NAME, LEVEL_PK_COL, NAME, NVL(TARGET_LEVEL,1) AS TAR_LEVEL' ||
   	' FROM BSC_KPI_DIM_LEVELS_VL WHERE INDICATOR = :1 AND DIM_SET_ID = :2  AND STATUS = 2';
  ----dbms_output.put_line('Chk1');
  IF IsIndicatorBalanceOrPnL(Indic, true) Then
    --The level 0 which is the Type of Account drill is excluded. This drill is
    --not considered to generate the tables
    l_stmt:= l_stmt||' AND DIM_LEVEL_INDEX <> 0';
  END IF;
  l_stmt := l_stmt||' ORDER BY DIM_LEVEL_INDEX';
  OPEN cv FOR l_stmt using Indic, Configuration;
  LOOP
    Fetch cv into l_dim_index, l_level_table, l_level_pk_col, Name, TargetLevel;
    EXIT WHEN cv%NOTFOUND;
    cLevel             := bsc_mo_helper_pkg.new_clsLevels;
    cLevel.keyName     := l_level_pk_col;
    cLevel.dimTable    := l_level_table;
    cLevel.Num         := l_dim_index;
    cLevel.Name        := Name;
    cLevel.TargetLevel := TargetLevel;
    IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
      bsc_mo_helper_pkg.writeTmp('Considering level '||l_level_table||' checking for relationship to existing levels', 1, false);
    END IF;
    DimensionLevelsNum := get_dimension_family(l_dimension_families, l_level_table);
    IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
      bsc_mo_helper_pkg.writeTmp('DimensionLevelsNum = '||DimensionLevelsNum);
    END IF;
    -- Get the index of the dimension family which this drill belongs to.
    If DimensionLevelsNum <> -1 Then
      IF (BSC_METADATA_OPTIMIZER_PKG.g_log) THEN
        bsc_mo_helper_pkg.writeTmp('Relationship exists');
      END IF;
      --Level belongs to family DimensionLevelsNum.
      --Check each level of this family and see which drill has 1n or mn
      --relationship with this one
      DimensionLevels := BSC_MO_HELPER_PKG.get_tab_clsLevels(l_dimension_families, DimensionLevelsNum);
      l_count := DimensionLevels.first;
      LOOP
        EXIT WHEN DimensionLevels.count = 0;
        tdril := bsc_mo_helper_pkg.new_clsLevels;
        tDril := DimensionLevels(l_count);
        If IndexRelation1N(l_level_table, tDril.dimTable) >= 0 Then
          --There is 1n relationship with this drill
          l_parents1n  := tDril.keyName;
          IF (cLevel.Parents1N IS NOT NULL ) THEN
            cLevel.Parents1N := cLevel.Parents1N||',';
          END IF;
          cLevel.Parents1N := cLevel.Parents1N||l_parents1n;
          --The 1n relations of the parent drill are also (by transitivity)
          --1n with the current drill
          tDril_parents1N := bsc_mo_helper_pkg.getDecomposedString(tDril.Parents1N, ',');
          IF (tDril_parents1N.count>0)THEN
            l_ct := tDril_parents1N.first;
            LOOP
              tPadre1n := tDril_parents1N(l_ct);
              IF (cLevel.Parents1N IS NOT NULL) THEN
                cLevel.Parents1N := cLevel.Parents1N ||',';
              END IF;
              cLevel.Parents1N := cLevel.Parents1N||tPadre1n;
              EXIT WHEN l_ct = tDril_Parents1N.last;
              l_ct := tDril_Parents1N.next(l_ct);
            END LOOP;
          END IF;
          --The mn relations of the parent drill are also (by transitivity)
          --mn with the current drill
          cDril_parentsMN := bsc_mo_helper_pkg.getDecomposedString(cLevel.ParentsMN, ',');
          tDril_parentsMN := bsc_mo_helper_pkg.getDecomposedString(tDril.ParentsMN, ',');
          IF tDril_parentsMN.count > 0 THEN
            l_ct := tDril_parentsMN.first;
            LOOP
              tPadremn := tDril_parentsMN(l_ct);
              IF (cLevel.ParentsMN IS NOT NULL) THEN
                cLevel.ParentsMN := cLevel.ParentsMN ||',';
              END IF;
              cLevel.ParentsMN := cLevel.ParentsMN ||tPadremn;
              EXIT WHEN l_Ct = tDril_ParentsMN.last;
              l_ct := tDril_ParentsMN.next(l_ct);
            END LOOP;
          END IF;
        END IF;--IndexRelation1N(l_level_table, tDril.dimTable) >= 0
        If IndexRelationMN(l_level_table, tDril.dimTable) >= 0 Then
          --There is mn relation with this drill
          l_parentsMN := tDril.keyName;
          IF (cLevel.ParentsMN IS NOT NULL) THEN
            cLevel.ParentsMN := cLevel.ParentsMN||',';
          END IF;
          cLevel.ParentsMN := cLevel.ParentsMN|| l_parentsMN;
          --The 1n relations of the parent drill are also (by transitivity)
          --mn with the current drill
          tDril_parents1n := bsc_mo_helper_pkg.getDecomposedString(tDril.Parents1N, ',');
          IF (tDril_parents1N.count >0) THEN
            l_ct := tDril_parents1N.first;
            LOOP
              tPadre1n := tDril_parents1N(l_ct)  ;
              IF (cLevel.ParentsMN IS NOT NULL )THEN
                cLevel.ParentsMN := cLevel.ParentsMN||',';
              END IF;
              cLevel.ParentsMN := cLevel.ParentsMN||tPadre1n;
              EXIT WHEN l_ct = tDril_Parents1N.last;
              l_ct := tDril_Parents1N.next(l_ct);
            END LOOP;
          END IF;
          --The mn relations of the parent drill are also (by transitivity)
          --mn with the current drill
          tDril_parentsMN := bsc_mo_helper_pkg.getDecomposedString(tDril.ParentsMN, ',');
          IF (tDril_parentsMN.count >0) THEN
            l_ct := tDril_parentsMN.first;
            LOOP
              tPadremn := tDril_parentsMN(l_ct) ;
              IF (cLevel.ParentsMN IS NOT NULL) THEN
                cLevel.parentsMN := cLevel.parentsMN||',';
              END IF;
              cLevel.ParentsMN := cLevel.ParentsMN || tPadremn;
              EXIT WHEN l_ct = tDril_ParentsMN.last;
              l_ct := tDril_ParentsMN.next(l_ct);
            END LOOP;
          END IF;
        END IF;--IndexRelationMN(l_level_table, tDril.Maestra) >= 0
        EXIT WHEN l_count =  DimensionLevels.last;
        l_count := DimensionLevels.next(l_count);
      END LOOP;
      --Review target levels
      IF cLevel.TargetLevel = 1 Then
        --If target apply to this level, then
        --it must apply for drils at the left (Parents)
        l_ct := DimensionLevels.count;
        IF l_ct > 0 THEN
          l_ct := DimensionLevels.first;
          LOOP
            tDril := DimensionLevels(l_ct);
            tDril.TargetLevel := 1;
            EXIT WHEN l_ct = DimensionLevels.last;
            l_ct := DimensionLevels.next(l_ct);
          END LOOP;
        END IF;
      END IF;
      DimensionLevels.delete;
      DimensionLevels(0) := cLevel;
      bsc_mo_helper_pkg.add_tabrec_clsLevels(l_dimension_families, DimensionLevels, DimensionLevelsNum);
    Else
      --The drill does not belong to any family previously created.
      --So, create a new family of drill with this drill
      --Review target level
      --This is the first drill in this family, then target must apply
      cLevel.TargetLevel := 1;
      DimensionLevels.delete;
      DimensionLevels(0) := cLevel;
      bsc_mo_helper_pkg.add_tabrec_clsLevels(l_dimension_families,  DimensionLevels, l_group_id);
      l_group_id := l_group_id +1;
    END IF;--If DimensionLevelsNum <> 0
  END Loop;
  close cv;
  IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Compl GetLevelCollection');
    bsc_mo_helper_pkg.write_this(l_dimension_families);
  END IF;
  return l_dimension_families;
  EXCEPTION WHEN OTHERS THEN
    l_stmt := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg( ' Exception in GetLevelCollection : '||l_stmt);
    fnd_message.set_name('BSC', 'BSC_RETR_DIM_KPI_FAILED');
  fnd_message.set_token('INDICATOR', Indic);
    fnd_message.set_token('DIMENSION_SET', Configuration);
    g_error := fnd_message.get;
    bsc_mo_helper_pkg.terminatewithMsg(g_error);
    raise;
  --app_exception.raise_exception;


End;
--****************************************************************************
--FlagTLOtherPeriodicities
--  DESCRIPTION:
--     Flag the TargetLevel of all periodicities in the collection
--     that can be generated from the ones selected by the user
--  PARAMETERS:
--     colPeriodicities: collection of clsIndicPeriodicity
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE FlagTLOtherPeriodicities(colPeriodicities IN OUT NOCOPY BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity)
IS
  atLeastOneChange Boolean;
   indicPer BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity;
  l_count NUMBER;

BEGIN

	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp( 'Inside FlagTLOtherPeriodicities, colPeriodicities = ');
      bsc_mo_helper_pkg.write_this(colPeriodicities);
	END IF;

  atLeastOneChange := True;

  While atLeastOneChange LOOP
	  atLeastOneChange := False;
	  l_count := colPeriodicities.first;
      --For Each indicPer In colPeriodicities
	  LOOP
       IF (colPeriodicities.count=0) THEN EXIT; END IF;
	     indicPer := colPeriodicities(l_count);
       If indicPer.TargetLevel = 0 Then
          --This periodicity has not been selected
          If GetPeriodicityOrigin(colPeriodicities, indicPer.Code, True) <> -1 Then
              indicPer.TargetLevel := 1;
              atLeastOneChange := True;
              bsc_mo_helper_pkg.writeTmp('atLeastOneChange is true');
              colPeriodicities(l_count) := indicPer;
          END IF;
       END IF;
	     EXIT WHEN l_count = colPeriodicities.last;
 	     l_count := colPeriodicities.next(l_count);
      END LOOP;

  END LOOP;
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
    bsc_mo_helper_pkg.writeTmp( 'Compl FlagTLOtherPeriodicities');
	END IF;


  EXCEPTION WHEN OTHERS THEN
  G_ERROR := sqlerrm;
  bsc_mo_helper_pkg.TerminateWithMsg( 'Exception in FlagTLOtherPeriodicities '||G_ERROR);
	RAISE;

End;


--****************************************************************************
--GetPeriodicities: GetColPeriodicidadesIndic
--  DESCRIPTION:
--   Get the collection of periodicity codes of the indicator
--  PARAMETERS:
--   Indic: indicator code
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************

Function GetPeriodicities(Indic IN NUMBER) RETURN BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity IS

  colPeriodicities BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity;
  CURSOR cPeriodicities IS
  SELECT PERIODICITY_ID, NVL(TARGET_LEVEL, 1) AS TAR_LEVEL
  FROM BSC_KPI_PERIODICITIES
  WHERE INDICATOR = Indic ORDER BY PERIODICITY_ID;
  l_per NUMBER;
  l_tar NUMBER;
  cv CurTyp;
  l_periodicity BSC_METADATA_OPTIMIZER_PKG.clsIndicPeriodicity := null;
BEGIN

  OPEN cPeriodicities;
  LOOP
	   FETCH cPeriodicities INTO l_per, l_tar;
	   EXIT WHEN cPeriodicities%NOTFOUND;
     l_periodicity.code := l_per;
	   l_periodicity.TargetLevel := l_tar;
     IF (colPeriodicities.count>0) THEN
        colPeriodicities(colPeriodicities.last+1) := l_periodicity;
     ELSE
        colPeriodicities(0) := l_periodicity;
     END IF;
  END LOOP;
  close cPeriodicities;
  return colPeriodicities;


  EXCEPTION WHEN OTHERS THEN
  BSC_MO_HELPER_PKG.TerminateWithError('BSC_RETR_KPI_PERIOD_FAILED');
  fnd_message.set_name('BSC', 'BSC_RETR_KPI_PERIOD_FAILED');
	fnd_message.set_token('INDICATOR', Indic);
  app_exception.raise_exception;

End;


--****************************************************************************
-- ConfigureIndics : TablasIndicatorConfiguration
--  DESCRIPTION:
--   Deduce each one of the tables needed by the kpi in the given
--   configuration.
--   For this tables are added to the collection gTablas.
--   Also configure metadata in order to the indicator reads from them.
--  PARAMETERS:
--   Indicator: indicator
--   Configuration: configuration
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
--****************************************************************************
-- ConfigureIndics : TablasIndicatorConfiguration
--  DESCRIPTION:
--   Deduce each one of the tables needed by the kpi in the given
--   configuration.
--   For this tables are added to the collection gTablas.
--   Also configure metadata in order to the indicator reads from them.
--  PARAMETERS:
--   Indicator: indicator
--   Configuration: configuration
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE ConfigureIndics(Indicator IN BSC_METADATA_OPTIMIZER_PKG.clsIndicator, Configuration IN NUMBER) IS
  colPeriodicities 	BSC_METADATA_OPTIMIZER_PKG.tab_clsIndicPeriodicity;
  colDrills		BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevels;
  colDrillCombination BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations;
  colDrillCombinationTL BSC_METADATA_OPTIMIZER_PKG.tab_tab_clsLevelCombinations;
  colBasicTables 	BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable;
  colBasicTablesTL 	BSC_METADATA_OPTIMIZER_PKG.tab_clsBasicTable;
  colDataColumns	BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
  i  NUMBER;
  iNext NUMBER;
  bLast boolean;
BEGIN
  bsc_mo_helper_pkg.writeTmp('  ', fnd_log.level_statement, false);
  bsc_mo_helper_pkg.writeTmp( 'Inside ConfigureIndics for '||Indicator.code||', dimension set = '||Configuration||', System time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
  g_current_dimset := Configuration;
  g_current_indicator := Indicator;
  If Indicator.Share_Flag = 0 Or Indicator.Share_Flag = 1 Or
     (
	   Indicator.Share_Flag = 2 AND
	   (IsFilteredIndicator(Indicator.Code, Configuration) OR
	    IsFilteredIndicator(Indicator.source_indicator, Configuration)
       )
     ) Then
    --If the indicator is normal or master or shared with filters then for this configuration
    --we make the system tables
    --Get the list of periodicities for the indicator
    colPeriodicities := GetPeriodicities(Indicator.Code);
    If Indicator.OptimizationMode = 2 Then
      --The indicator needs targets at different levels
      --We need to flag all periodicities that can be generated from
      --the ones selected by the user
      FlagTLOtherPeriodicities (colPeriodicities);
    END IF;
    --Get the list of drill families of the indicator in the given configuration
    colDrills := GetLevelCollection(Indicator.Code, Configuration);
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('  ');
      bsc_mo_helper_pkg.writeTmp('Level Collection is');
      bsc_mo_helper_pkg.write_this(colDrills);
	END IF;
    --Get the list of combinations of levels of each familiy
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.writeTmp('Get the list of level combinations ');
	END IF;
    colDrillCombination := GetLevelCombinations(colDrills, False);
	IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
      bsc_mo_helper_pkg.write_this(colDrillCombination);
      bsc_mo_helper_pkg.writetmp('  ');
    END IF;
    If Indicator.OptimizationMode = 2 Then
      --The indicator needs targets at different levels
      colDrillCombinationTL := GetLevelCombinations(colDrills, True);
      bsc_mo_helper_pkg.write_this(colDrillCombinationTL);
    END IF;
    --Get the list of data columns of the indicator in the given configuration
    colDataColumns := GetDataFields(Indicator.Code, Configuration, True);
    bsc_mo_helper_pkg.write_this(colDataColumns);
    --Generate the list of base tables for the indicator
    colBasicTables := GetBasicTables(Indicator, Configuration, colDrillCombination, colDrills, False, colDataColumns);
    If Indicator.OptimizationMode = 2 Then
      --The indicator needs targets at different levels
      colBasicTablesTL := GetBasicTables(Indicator, Configuration, colDrillCombinationTL, colDrills, True, colDataColumns);
    END IF;
    --Deduce the internal table tree for the indicator
    --BSC-MV Note: Added forTargetLevel parameter to DeducirGrafoInterno()
    If Indicator.OptimizationMode <> 0 Then
      --If the indicator is no-precalculated then we calculate the internal table tree
      deduceInternalGraph (colBasicTables, colDrills, False);
      If Indicator.OptimizationMode = 2 Then
        deduceInternalGraph(colBasicTablesTL, colDrills, True);
      END IF;
    END IF;
    --Deduce each one of the tables needed by the kpi in the given configuration.
    --For this tables are added to the collection gTablas.
    --Also configure metadata in order to the indicator reads from them.
    deduce_and_configure_s_tables(Indicator, Configuration, colBasicTables, colPeriodicities, colDrills, False);
    If Indicator.OptimizationMode = 2 Then
      deduce_and_configure_s_tables(Indicator, Configuration, colBasicTablesTL, colPeriodicities, colDrills, True);
      ConnectTargetTables(Indicator, Configuration);
    END IF;
    --BSC-MV Note: If the indicator is processed only for Summarization Level Change
    --(example for 2 to 3 or 3 to 2), I do not need the tables in gTablas.
    --I just wanted to re-configure BSC_KPI_DATA_TABLES and not re-configure loader.
    --Remove indicator tables from gTablas
    bLast := false;
    If (Indicator.Action_Flag = 0 Or Indicator.Action_Flag = 4) And bsc_metadata_optimizer_pkg.g_Sum_Level_Change = 2 Then
      i := bsc_metadata_optimizer_pkg.gTables.first;
      LOOP
        EXIT WHEN bsc_metadata_optimizer_pkg.gTables.count = 0;
        IF (i = bsc_metadata_optimizer_pkg.gTables.last) THEN
          bLast := true;
        END IF;
        If (bsc_metadata_optimizer_pkg.gTables(i).Indicator = Indicator.Code) And
                (bsc_metadata_optimizer_pkg.gTables(i).Configuration = Configuration) Then
          IF (NOT bLast) THEN
            iNext := bsc_metadata_optimizer_pkg.gTables.next(i);
          END IF;
          IF BSC_METADATA_OPTIMIZER_PKG.g_log THEN
            BSC_MO_HELPER_PKG.writeTmp('2 Going to delete '||BSC_METADATA_OPTIMIZER_PKG.gTables(i).name);
          END IF;
          bsc_metadata_optimizer_pkg.gTables.delete(i);
          i := iNext;
        ELSE
          i := bsc_metadata_optimizer_pkg.gTables.next(i);
        END IF;
        EXIT WHEN bLast = true;
      END Loop;
    End If;
  END IF;
  bsc_mo_helper_pkg.writeTmp( 'Compl ConfigureIndics, system time is '||bsc_mo_helper_pkg.get_time, fnd_log.level_statement, true);
  EXCEPTION WHEN OTHERS THEN
    bsc_mo_helper_pkg.writeTmp( 'Exception in ConfigureIndics : '||sqlerrm, fnd_log.level_exception, true);
    fnd_message.set_name('BSC', 'BSC_KPI_TBLS_SET_DEDUCT_FAILED');
	fnd_message.set_token('INDICATOR', Indicator.code);
    fnd_message.set_token('DIMENSION_SET', Configuration);
    g_error := fnd_message.get ;
    bsc_mo_helper_pkg.terminatewithMsg(g_error);
    raise;
End;


--****************************************************************************
--  GetColConfigurationsforIndic
--    DESCRIPTION:
--       Get the collection with the configurations of the indicator
--    PARAMETERS:
--       Indic: indicator code
--    AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function GetColConfigForIndic(Indic IN NUMBER) return DBMS_SQL.NUMBER_TABLE IS
  colConfigurations dbms_sql.number_table;
  colMeasures BSC_METADATA_OPTIMIZER_PKG.tab_clsDataField;
  Configuration NUMBER;
  DimSet NUMBER;
  CURSOR cConfigs IS
  SELECT DISTINCT DIM_SET_ID FROM BSC_DB_DATASET_DIM_SETS_V
  WHERE INDICATOR = Indic  ORDER BY DIM_SET_ID;
BEGIN
  OPEN cConfigs;
  LOOP
    FETCH cConfigs INTO DimSet;
    EXIT WHEN cConfigs%NOTFOUND;
    --BSC-PMF Integration: Only get BSC dimension sets
    --We need to validate that there is at least one BSC data column
    --associated to this dimension set.
    If GetNumDataColumns(Indic, DimSet) > 0 Then
      Configuration := DimSet;
      colConfigurations(colConfigurations.count) := configuration;
    END IF;
  END Loop;
  CLOSE cConfigs;
  return colConfigurations;
  EXCEPTION WHEN OTHERS THEN
    g_error := sqlerrm;
    bsc_mo_helper_pkg.TerminateWithMsg(' Exception in GetColConfigForIndic : '||g_error);
    fnd_message.set_name('BSC', 'BSC_RETR_DIMSET_KPI_FAILED');
	fnd_message.set_token('INDICATOR', Indic);
    app_exception.raise_exception;
End;
--***************************************************************************
--TablasIndicatores
--
--  DESCRIPTION:
--     Deduce set of tables used directly by each indicator.
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
PROCEDURE IndicatorTables IS
    Indicator BSC_METADATA_OPTIMIZER_PKG.clsIndicator;
    colConfigurations dbms_sql.number_table;
    l_Configuration Number;
    l_stmt VARCHAR2(1000);
    l_count number := 0;
    l_configs Number := 0;
    l_list dbms_sql.number_table;
BEGIN
  bsc_mo_helper_pkg.writeTmp( 'Inside IndicatorTables, # = '||BSC_METADATA_OPTIMIZER_PKG.gIndicators.count, fnd_log.level_statement, true);
  IF BSC_METADATA_OPTIMIZER_PKG.gIndicators.count >0 THEN
    l_count := BSC_METADATA_OPTIMIZER_PKG.gIndicators.first;
  END IF;

  --Perf. fix, instead of getting # of data columns for each indicator, get it in one shot
  FOR i IN BSC_METADATA_OPTIMIZER_PKG.gIndicators.first..BSC_METADATA_OPTIMIZER_PKG.gIndicators.last LOOP
    --Consider only new indicators or changed indicators
    IF BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).Action_Flag = 3
       Or
       (Indicator.Action_Flag <> 2 And BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0) THEN
      l_list(l_list.count+1) := BSC_METADATA_OPTIMIZER_PKG.gIndicators(i).code;
    END IF;
  END LOOP;
  init_measure_counts(l_list);
  LOOP
    EXIT WHEN BSC_METADATA_OPTIMIZER_PKG.gIndicators.count = 0;
    Indicator := BSC_METADATA_OPTIMIZER_PKG.gIndicators(l_count);
    bsc_mo_helper_pkg.writeTmp('Processing indic ');
    bsc_mo_helper_pkg.write_this(Indicator);
    --Consider only new indicators or changed indicators
    -- Note: ANy logic change shd be propagated to the init above
    IF Indicator.Action_Flag = 3
       Or
       (Indicator.Action_Flag <> 2 And BSC_METADATA_OPTIMIZER_PKG.g_Sum_Level_Change <> 0) THEN
      --Get the list of configurations of the kpi
      colConfigurations := GetColConfigForIndic(Indicator.Code);
      l_configs := colConfigurations.first;
      bsc_mo_helper_pkg.writeTmp('colConfigurations.count = '||colConfigurations.count);
      LOOP
        EXIT WHEN colConfigurations.count = 0;
        l_configuration := colConfigurations(l_configs);
        bsc_mo_helper_pkg.writeTmp('Processing Indicator='||Indicator.Code||', dim set='||l_configuration||':'||bsc_mo_helper_pkg.get_time, FND_LOG.LEVEL_STATEMENT, true);
        ConfigureIndics(Indicator, l_configuration);
        EXIT WHEN l_configs = colConfigurations.last;
        l_configs := colConfigurations.next(l_configs);
      END LOOP;
      --BSC-MV Note: Save the summarization level in BSC_KPI_PROPERTIES
      If BSC_METADATA_OPTIMIZER_PKG.g_BSC_MV Then
        bsc_mo_helper_pkg.WriteInfoMatrix(Indicator.Code, 'ADV_SUM_LEVEL',
                        to_number(BSC_METADATA_OPTIMIZER_PKG.g_Adv_Summarization_Level));
      End If;
    END IF;
	EXIT when l_count = BSC_METADATA_OPTIMIZER_PKG.gIndicators.last;
    l_count := BSC_METADATA_OPTIMIZER_PKG.gIndicators.next(l_count) ;
  END LOOP;
  --Configure shared indicators without filters same tables as master indicator
  ConfigureMasterSharedIndics;
  bsc_mo_helper_pkg.writeTmp( 'Compl IndicatorTables', fnd_log.level_statement, true);
  exception when others then
    g_error := sqlerrm;
    BSC_MO_HELPER_PKG.TerminateWithMsg('IndicatorTables failed with : '||g_error);
    raise;
    --app_exception.raise_exception;
End;
END BSC_MO_INDICATOR_PKG;

/
