--------------------------------------------------------
--  DDL for Package Body BSC_DBGEN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DBGEN_UTILS" AS
/* $Header: BSCDBUTB.pls 120.10 2007/04/25 12:52:55 ashankar ship $ */


FUNCTION Is_Simulation_Report
(
   p_short_name   IN    BSC_KPIS_VL.short_name%TYPE
) RETURN VARCHAR2 IS

 l_return   VARCHAR2(10);


 CURSOR c_sim IS
 SELECT config_type
 FROM   bsc_kpis_b
 WHERE  short_name =p_short_name;
BEGIN
  l_return := FND_API.G_FALSE;

  FOR cd IN c_sim LOOP
   IF(cd.config_type =7) THEN
    l_return :=FND_API.G_TRUE;
   END IF;
  END LOOP;

  RETURN l_return;

EXCEPTION
 WHEN OTHERS THEN
  l_return := FND_API.G_FALSE;

END Is_Simulation_Report;



FUNCTION get_bsc_schema return varchar2 is
dummy1      VARCHAR2(32)  := null;
dummy2      VARCHAR2(32)  := null;
l_bsc_schema  VARCHAR2(32)  := null;
begin
  IF (g_bsc_schema IS NOT NULL) THEN
    return g_bsc_schema;
  END IF;
  IF (FND_INSTALLATION.GET_APP_INFO('BSC', dummy1, dummy2, l_bsc_schema)) THEN
    NULL;
  END IF;
  g_bsc_schema := l_bsc_schema;
  return l_bsc_schema;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_bsc_schema:'||sqlerrm);
  raise;
end;

/*---------------------------------------------------------------------
 Get the actual schema name for the 'APPS' schema as it could be different
 in different implementations.

---------------------------------------------------------------------*/
Function get_apps_schema  RETURN VARCHAR2 IS
  l_schema varchar2(100);
  CURSOR cApps IS
    SELECT ORACLE_USERNAME
    FROM  fnd_oracle_userid
    WHERE oracle_id=900;
BEGIN
  OPEN cApps;
  FETCH cApps INTO l_schema;
  CLOSE cApps;
  return l_schema;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_apps_schema:'||sqlerrm);
  raise;
END;

PROCEDURE init IS
BEGIN
  IF (g_initialized ) THEN
    return;
  END IF;
  bsc_apps.init_bsc_apps;
  g_bsc_schema := get_bsc_schema;
  g_apps_schema := get_apps_schema;
  g_initialized := true;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.init:'||sqlerrm);
  raise;

END;

FUNCTION get_datatype(p_table_name in varchar2, p_column_name in varchar2) return VARCHAR2 IS
  CURSOR cType IS
  SELECT data_type, data_length
  FROM all_tab_columns
  where
  (owner = g_bsc_schema or owner = g_apps_schema) and
  table_name=p_table_name and
  column_name=p_column_name;
  l_type varchar2(100);
  l_length number;
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  OPEN cType;
  FETCH cType INTO l_type, l_length;
  CLOSE cType;
  IF (l_length IS NOT NULL) THEN
    l_type := l_type ||'('||l_length||')';
  END IF;
  return l_type;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_datatype:'||sqlerrm);
  raise;

END;

--===========================================================================+
--
--  Name:      Get_New_Big_In_Cond_Number
--   Description:   Clean values for the given variable_id and return a 'IN'
--            condition string.
--   Parameters:  x_variable_id  variable id.
--            x_column_name  column name (left part of the condition)
--============================================================================

Function Get_New_Big_In_Cond_Number( x_variable_id IN NUMBER, x_column_name IN VARCHAR2)
return VARCHAR2 IS
  l_cond varchar2(1000);
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  DELETE FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = USERENV('SESSIONID') AND VARIABLE_ID = x_variable_id;
  l_cond := x_column_name || ' IN (' ||
      ' SELECT VALUE_N FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = USERENV(''SESSIONID'')'||
      ' AND VARIABLE_ID = ' || x_variable_id || ')';
  return l_cond;
EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.Get_New_Big_In_Cond_Number:'||sqlerrm);
  raise;
End;

--===========================================================================+
--   Name:      Add_Value_Big_In_Cond_Number
--   Description:   Insert the given value into the temporary table of big
--            'in' conditions for the given variable_id.
--   Parameters:  x_variable_id  variable id.
--            x_value      value
--============================================================================
PROCEDURE Add_Value_Big_In_Cond_Number(x_variable_id IN NUMBER, x_value IN NUMBER) IS
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  bsc_apps.Add_Value_Big_In_Cond(x_variable_id , x_value);
EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.Add_Value_Big_In_Cond_Number:'||sqlerrm);
  raise;
End;

--===========================================================================+
--   Name:      Get_New_Big_In_Cond_Varchar2
--   Description:   Clean values for the given variable_id and return a 'IN'
--            condition string.
--   Parameters:  x_variable_id  variable id.
--            x_column_name  column name (left part of the condition)
--============================================================================
Function Get_New_Big_In_Cond_Varchar2( x_variable_id in number, x_column_name in varchar2)
return VARCHAR2 IS
  cond   varchar2(1000);
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  DELETE FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = USERENV('SESSIONID') AND VARIABLE_ID = x_variable_id;
  cond := 'UPPER('||  x_column_name  || ') IN ('||
      ' SELECT UPPER(VALUE_V) FROM BSC_TMP_BIG_IN_COND WHERE SESSION_ID = USERENV(''SESSIONID'') AND VARIABLE_ID = '||x_variable_id||')';
  return cond;
EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.Get_New_Big_In_Cond_Varchar2:'||sqlerrm);
  raise;
End;
--===========================================================================+
--   Name:      Add_Value_Big_In_Cond_Varchar2
--   Description:   Insert the given value into the temporary table of big
--            --in' conditions for the given variable_id.
--   Parameters:  x_variable_id  variable id.
--            x_value      value
--============================================================================*/
PROCEDURE Add_Value_Big_In_Cond_Varchar2(x_variable_id IN NUMBER, x_value IN VARCHAR2) IS
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  bsc_apps.Add_Value_Big_In_Cond(x_variable_id , x_value);

EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.Add_Value_Big_In_Cond_Varchar2:'||sqlerrm);
  raise;
End;

FUNCTION get_dbgen_fact_id(p_fact_name IN VARCHAR2, p_application_short_name IN VARCHAR2) RETURN NUMBER IS
  /*CURSOR cFactID IS
  SELECT indicator FROM BSC_DBGEN_FACTS
  WHERE source = p_application_source
  AND fact_name = p_fact_name;*/

  l_fact_id NUMBER;
BEGIN
  /*OPEN cFactID;
  FETCH cFactID INTO l_fact_id;
  CLOSE cFactID;
  return l_fact_id;*/
  return to_number(p_fact_name);
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_dbgen_fact_id:'||sqlerrm);
  raise;
END;

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
FUNCTION get_measure_list(p_expression IN VARCHAR2) RETURN dbms_sql.varchar2_table IS
  i NUMBER;
  l_measure_list_tmp dbms_sql.varchar2_table;
  l_expression VARCHAR2(1000);
  l_measure_list dbms_sql.varchar2_table ;
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  l_expression := p_expression;
  BSC_METADATA_OPTIMIZER_PKG.InitReservedFunctions;
  --Replace the operators by ' '
  i := BSC_METADATA_OPTIMIZER_PKG.gReservedOperators.first;

  LOOP
    l_expression := Replace(l_expression, BSC_METADATA_OPTIMIZER_PKG.gReservedOperators(i), ' ');
    EXIT WHEN i = BSC_METADATA_OPTIMIZER_PKG.gReservedOperators.last;
    i := BSC_METADATA_OPTIMIZER_PKG.gReservedOperators.next(i);
  END LOOP;
  --Break down the expression which is separated by ' '
  i := BSC_MO_HELPER_PKG.DecomposeString(l_expression, ' ', l_measure_list_tmp );
  i:= l_measure_list_tmp .first;
  LOOP
    EXIT WHEN l_measure_list_tmp .count = 0;
    If l_measure_list_tmp (i) IS NOT NULL Then
      If BSC_MO_HELPER_PKG.FindIndexVARCHAR2(BSC_METADATA_OPTIMIZER_PKG.gReservedFunctions, l_measure_list_tmp (i)) = -1 Then
        --The word campos(i) is not a reserved function
        If UPPER(l_measure_list_tmp (i)) <> 'NULL' Then
          --the word is not 'NULL'
          If Not  BSC_MO_HELPER_PKG.IsNumber(l_measure_list_tmp (i)) Then
            --the word is not a constant
            l_measure_list(l_measure_list.count+1) := l_measure_list_tmp (i);
          END IF;
        END IF;
      END IF;
    END IF;
    EXIT WHEN i = l_measure_list_tmp.last;
    i := l_measure_list_tmp.next(i);
  END LOOP;
  return l_measure_list;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_measure_list:'||sqlerrm||', expression='||p_expression);
  raise;
End;

--***************************************************************************
--  getKPIPropertyValue : LeerMatrixINfo
--  DESCRIPTION:
--     Return the value oif the given variable of the given indicator from
--     table BSC_KPI_PROPERTIES.
--
--  PARAMETERS:
--     Indic: indicator code
--     Variable: variable name
--     Default: default value
--     db_obj: database
--
--  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
--***************************************************************************
Function get_kpi_property_value(
    p_kpi IN NUMBER,
  p_property IN VARCHAR2,
  p_default IN NUMBER)
  return NUMBER IS
l_value number := null;
CURSOR cProperty IS
  SELECT PROPERTY_VALUE
  FROM BSC_KPI_PROPERTIES
  WHERE INDICATOR = p_kpi
  AND PROPERTY_CODE = p_property;

BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  OPEN cProperty;
  FETCH cProperty INTO l_value;
  CLOSE cProperty;
  IF l_value is not null THEN
     return l_value;
  END IF;
  return p_default;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_kpi_property_value:'||sqlerrm||', p_kpi='||p_kpi||', p_property='||p_property||', p_default='||p_default);
  raise;
End;

PROCEDURE add_property(
p_properties in out nocopy BSC_DBGEN_STD_METADATA.tab_ClsProperties,
p_name in varchar2,
p_value in number)
IS
BEGIN
  add_property(p_properties, p_name, to_char(p_value));
END;
PROCEDURE add_property(
p_properties in out nocopy BSC_DBGEN_STD_METADATA.tab_ClsProperties,
p_name in varchar2,
p_value in varchar2)
IS
l_property BSC_DBGEN_STD_METADATA.ClsProperties;
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  IF (p_properties.count=0) THEN
    p_properties(1).name := p_name;
    p_properties(1).value := p_value;
    return;
  END IF;

  FOR i IN p_properties.first..p_properties.last LOOP
    IF (p_properties(i).name = p_name) THEN
      p_properties(i).value := p_value;
      return;
    END IF;
  END LOOP;

  l_property.name := p_name;
  l_property.value := p_value;
  p_properties(p_properties.last+1) := l_property;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.add_property:'||sqlerrm||', p_name='||p_name||', p_Value='||p_value);
  raise;
END;

FUNCTION get_property_value(p_properties IN BSC_DBGEN_STD_METADATA.tab_ClsProperties, p_name in varchar2) return VARCHAR2
IS
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  IF (p_properties.count=0) THEN
    return BSC_DBGEN_STD_METADATA.BSC_PROPERTY_NOT_FOUND ;
  END IF;
  FOR i IN p_properties.first..p_properties.last LOOP
    IF (p_properties(i).name = p_name) THEN
      return p_properties(i).value;
    END IF;
  END LOOP;
  return BSC_DBGEN_STD_METADATA.BSC_PROPERTY_NOT_FOUND ;

  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_property_value:'||sqlerrm||', p_name='||p_name);
  raise;
END;

FUNCTION get_source_table_names(p_table_name IN VARCHAR2) RETURN DBMS_SQL.VARCHAR2_TABLE IS
CURSOR cList IS
select source_table_name from bsc_db_tables_rels
connect by table_name = prior source_table_name
start with table_name = p_table_name;
l_list DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  FOR i IN cList LOOP
    l_list(l_list.count) := i.source_table_name;
  END LOOP;
  return l_list;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_source_table_names:'||sqlerrm||', p_table_name='||p_table_name);
  raise;
END;

FUNCTION get_table_type(p_table_name IN VARCHAR2) RETURN VARCHAR2
IS
l_table_type VARCHAR2(10);
CURSOR cTableType IS
select count(1)
from bsc_db_tables tbl,
bsc_db_tables_rels rels
where
rels.table_name = p_table_name
and rels.source_table_name = tbl.table_name
and tbl.table_type = 0;

BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  BEGIN
  SELECT table_type INTO l_table_type FROM BSC_DB_TABLES where table_name = p_table_name;
    EXCEPTION WHEN OTHERS THEN
      SELECT count(1) INTO l_table_type FROM BSC_SYS_DIM_LEVELS_B where level_table_name = p_table_name;
      IF l_table_type <>0  THEN
        return 'D';
      ELSE
        return null;
      END IF;
  END;
  --B = 1, S = 1, T = 1, I = 0, DI = 2
  IF l_table_type = 0 THEN
    return 'I';
  ELSIF l_table_type = 2 THEN
    return 'DI';
  ELSIF l_table_type <> 1 THEN
    return null;
  END IF;

  -- Table type is 1 : Can be B, S or T table
  l_table_type := 0;
  OPEN cTableType;
  FETCH cTableType INTO l_table_type ;
  CLOSE cTableType;
  IF (l_table_type<>0) THEN
    return 'B';
  ELSIF p_table_name like 'BSC_T%' THEN
    return 'T';
  ELSIF p_table_name like 'BSC_S%' THEN
    return 'S';
  END IF;
  return null;
EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_table_type:'||sqlerrm||', p_table_name='||p_table_name);
  raise;
END;

FUNCTION get_mvlog_for_table(p_table_name IN VARCHAR2) RETURN VARCHAR2
IS
CURSOR cMVLog(p_owner VARCHAR2) IS
select log_table from all_snapshot_logs where log_owner=p_owner and master = p_table_name;
l_mvlog_name VARCHAR2(100);
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  l_mvlog_name := null;
  OPEN cMVLog(g_bsc_schema);
  FETCH cMVLog INTO l_mvlog_name;
  CLOSE cMVLog;
  RETURN l_mvlog_name;
  EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_mvlog_for_table:'||sqlerrm||', p_table_name='||p_table_name);
  raise;
END;


-- given the objective short_name, tells us if the
-- the Objective is a BSC Objective or a BSC Sourced Report or a non-BSC Sourced report
FUNCTION get_Objective_Type (
    p_Short_Name IN VARCHAR2
) RETURN VARCHAR2
IS
    l_Count  NUMBER;
BEGIN
  IF (g_initialized=false) THEN
    init;
  END IF;
  IF (p_short_name is NULL) THEN
    return 'OBJECTIVE';
  END IF;

  IF BSC_BIS_CUSTOM_KPI_UTIL_PUB.IS_OBJECTIVE_REPORT_TYPE(p_SHORT_NAME) = FND_API.G_TRUE THEN
  -- Removed call to API BSC_BIS_CUSTOM_KPI_UTIL_PUB.Is_Objective_AutoGen_Type to fix Bug#4602405
      RETURN 'BSCREPORT';
  ELSIF(Is_Simulation_Report(p_SHORT_NAME)= FND_API.G_TRUE)THEN
      RETURN 'SIMULATION';
  ELSE
      RETURN 'OBJECTIVE';
  END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'OBJECTIVE';
END get_Objective_Type;

-- Given a varchar2 string, chop it into chunks and return
FUNCTION get_char_chunks(p_msg IN VARCHAR2, p_chunk_size IN NUMBER default 256) return DBMS_SQL.VARCHAR2_TABLE IS
l_varchar2_Table DBMS_SQL.VARCHAR2_TABLE;
l_chunk VARCHAR2(2000);
l_msg VARCHAR2(32767);
l_chunk_size NUMBER;
BEGIN
 IF (p_msg IS NULL or p_chunk_size <= 0) THEN
   return l_varchar2_table;
 END IF;
 l_msg := p_msg;
 l_chunk_size := p_chunk_size;
 IF (l_chunk_size > 2000) THEN
   l_chunk_size := 2000;
 END IF;
 LOOP
   l_chunk := substr(l_msg, 1, l_chunk_size);
   l_varchar2_table(l_varchar2_table.count) := l_chunk;
   EXIT WHEN length(l_msg) <= l_chunk_size;
   l_msg := substr(l_msg, l_chunk_size+1, length(l_msg));
 END LOOP;
 return l_varchar2_table;
EXCEPTION when others then
  fnd_file.put_line(FND_FILE.LOG, 'Exception in BSC_DBGEN_UTILS.get_char_chunks:'||sqlerrm||', p_msg='||p_msg||', p_chunk_size='||p_chunk_size);
  raise;
END;

/****************************************************************************
  get_objective_type_for_base_table

  DESCRIPTION:
     Returns the type of objective using this B table: AW or MV
  PARAMETERS:
     p_b_table_Name: Base table name
  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
    Arun.Santhanam
****************************************************************************/
Function get_objective_type_for_b_table(
    p_b_table_name IN VARCHAR2
) return  VARCHAR2 IS
    l_indicator NUMBER;
    CURSOR cTables IS
    select distinct indicator from bsc_kpi_data_tables where
table_name in (
select distinct rels.table_name
from bsc_db_Tables_rels rels
connect by prior table_name=source_table_name
start with rels.source_table_name = p_b_table_name);

BEGIN
    open cTables;
    FETCH cTables into l_indicator;
    IF (cTables%NOTFOUND) THEN
      CLOSE cTables;
      return null;
    ELSE
      CLOSE cTables;
      IF get_kpi_property_value(l_indicator, 'IMPLEMENTATION_TYPE', 1)=2 THEN
        return 'AW';
      ELSE
      return 'MV';
    END IF;
    END IF;
End;


FUNCTION table_exists(p_table_name IN VARCHAR2) return BOOLEAN IS
   l_count NUMBER;

    CURSOR cTables(pTableName IN VARCHAR2, pOwner IN VARCHAR2) IS
    SELECT 1 FROM ALL_TABLES
    WHERE TABLE_NAME = pTableName
    AND OWNER = pOwner;
BEGIN
    IF (g_initialized=false) THEN
       init;
    END IF;
    l_count := 0;
    open cTables(p_table_name, g_bsc_schema);
    FETCH cTables into l_count;
    IF (cTables%NOTFOUND) THEN
        CLOSE cTables;
        return false;
    ELSE
        CLOSE cTables;
        return true;
    END IF;
End;

/****************************************************************************
  IS_TMP_TABLE_EXISTS

  DESCRIPTION:
     Returns TRUE if the given tmp table exists in the database.
  PARAMETERS:
     Table_Name: tmp table name
  AUTHOR/DATE  -  MODIFICATIONS (AUTHOR/DATE/DESCRIPTION):
    CALAW
****************************************************************************/
Function IS_TMP_TABLE_EXISTED(
    Table_Name IN VARCHAR2
) return Boolean IS

    l_count NUMBER;

    CURSOR cTables(pTableName IN VARCHAR2, pOwner IN VARCHAR2) IS
    SELECT 1 FROM ALL_TABLES
    WHERE TABLE_NAME = pTableName
    AND OWNER = pOwner
    AND TEMPORARY = 'Y';

BEGIN
    IF (g_initialized=false) THEN
       init;
    END IF;
    l_count := 0;

    open cTables(table_name, g_bsc_schema);
    FETCH cTables into l_count;
    IF (cTables%NOTFOUND) THEN
        CLOSE cTables;
        return false;
    ELSE
        CLOSE cTables;
        return true;
    END IF;
End;


FUNCTION parse_value(p_string IN VARCHAR2, p_property_name IN VARCHAR2, p_assignment_operator IN VARCHAR2, p_pre_separator IN VARCHAR2, p_post_separator IN VARCHAR2) return varchar2 IS
l_pos number;
l_part_string varchar2(32000);
l_pattern VARCHAR2(1000);
l_value VARCHAR2(1000);
BEGIN

  if (p_pre_separator is null and p_post_separator is null) then -- single value, just return RHS of assignment operator
    l_pos := instr(p_string, p_assignment_operator);
    return substr(p_string, l_pos+1);
  end if;


  l_pattern :=  p_pre_separator||p_property_name||p_assignment_operator;
  l_pos := instr(p_string, l_pattern);
  if l_pos = 0 then -- check if its the first entry
    l_pos := instr(p_string, p_property_name||p_assignment_operator);
    if (l_pos=0) then
      return null;
    end if;
    if (l_pos<>1) then
      return null;
    end if;
    -- this is the first entry and is without pre separator though specified
    l_part_string := substr(p_string, length(p_property_name||p_assignment_operator)+1);
  else
    l_part_string := substr(p_string, l_pos+length(l_pattern));
  end if;


  -- so we've reached the point in the string where the value starts
  if (p_post_separator is not null) then -- post separator specified
    l_pos := instr(l_part_string, p_post_separator);

    if l_pos =0 then -- possibly last value without post separator though its specified
      if (instr(l_part_string, p_assignment_operator)=0) then -- really last value
        l_pos := length(l_part_string)+1;
      end if;
    end if;
  else
    l_pos := instr(l_part_string, p_pre_separator);
    if l_pos=0 then -- end of string
      return l_part_string;
    end if;
  end if;

  l_value := substr(l_part_string, 1, l_pos-1);
  return l_value;
END;

-- assumes object is valid and exists
-- returns apps if this does not exist
FUNCTION get_table_owner(p_table_name VARCHAR2) RETURN VARCHAR2 IS
cursor cOwner is
select table_owner from user_synonyms
where synonym_name=p_table_name;
l_owner varchar2(100);
BEGIN
  IF NOT g_initialized THEN
    init;
  END IF;
  open cOwner;
  fetch cOwner into l_owner;
  close cOwner;
  IF l_owner is NOT NULL THEN
    return l_owner;
  ELSE
    return g_apps_schema;
  END IF;

END;


PROCEDURE drop_table(p_table_name IN VARCHAR2) IS
BEGIN
  bsc_apps.init_bsc_apps;
  bsc_apps.do_ddl(x_statement=>'drop table '||p_table_name,
                  x_statement_type=>ad_ddl.drop_table,
                  x_object_name=>p_table_name);
END;


--New API for Bug 4902308
PROCEDURE add_string(p_varchar2_table IN OUT NOCOPY DBMS_SQL.VARCHAR2A, p_string IN VARCHAR2) IS
l_index number;
l_current_length number;
l_val varchar2(32767);
BEGIN
  if p_varchar2_table.count=0 then
    p_varchar2_table(1) := p_string;
    return;
  end if;
  l_index := p_varchar2_table.last;
  if length(p_varchar2_table(l_index)) + length(p_string) > 32767 then --
    l_index := l_index +1;
    p_varchar2_table(l_index) := p_string;
    return;
  end if;
  p_varchar2_table(l_index) := p_varchar2_table(l_index)||p_string;
  exception when others then
    fnd_file.put_line(FND_FILE.log, 'Error in add_string:string='||p_string||', error='||sqlerrm);
    raise;
END;


PROCEDURE execute_immediate(p_varchar2_table IN DBMS_SQL.VARCHAR2A) IS
l_dummy dbms_sql.varchar2_table;
BEGIN
  execute_immediate(p_varchar2_table, l_dummy, 0);
END;

---------------------------------------------------------------
--One way to make this proc. generic is to ensure loader populates
--the bind variables sequentially
--ie assume is that all parameters are bound as :1, :2, :3 etc
--currently this is not the case. this requires change in bsc_update_base_v2
---------------------------------------------------------------
PROCEDURE execute_immediate(p_varchar2_table IN DBMS_SQL.VARCHAR2A,
                            p_bind_vars_values dbms_sql.varchar2_table,
                            p_num_bind_vars number) IS
e_max_bind_vars_exceeded exception;

l_sql dbms_sql.varchar2a;

 l_cur         number;
 dummy         NUMBER;
BEGIN
  fnd_file.put_line(FND_FILE.LOG, 'Chk 0, bind#='||p_num_bind_vars);
  for i in 1..p_varchar2_table.count loop
    l_sql(i) := p_varchar2_table(i);
  end loop;
  fnd_file.put_line(FND_FILE.LOG, 'Chk 1');

  for i in p_varchar2_table.count+1..50 loop
    l_sql(i) := null;
  end loop;
  if nvl(p_num_bind_vars,0) = 0 then
    l_cur := dbms_sql.open_cursor;
    dbms_sql.parse(
                c             =>  l_cur,
                statement     => l_sql,
                lb            => l_sql.first,
                ub            => l_sql.last,
                lfflg         => TRUE,
                language_flag => dbms_sql.native );

    dummy := dbms_sql.execute(l_cur);
    dbms_sql.close_cursor(l_cur);
    fnd_file.put_line(FND_FILE.LOG, 'Chk 4');
  elsif p_num_bind_vars = 1 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1);
  elsif p_num_bind_vars = 2 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2);
  elsif p_num_bind_vars = 3 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3);
  elsif p_num_bind_vars = 4 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4);
  elsif p_num_bind_vars = 5 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5);
  elsif p_num_bind_vars = 6 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6);
  elsif p_num_bind_vars = 7 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7);
  elsif p_num_bind_vars = 8 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8);
  elsif p_num_bind_vars = 9 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9);
  elsif p_num_bind_vars = 10 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10);
  elsif p_num_bind_vars = 11 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11);
  elsif p_num_bind_vars = 12 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12);
  elsif p_num_bind_vars = 13 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13);
  elsif p_num_bind_vars = 14 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14);
  elsif p_num_bind_vars = 15 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14), p_bind_vars_values(15);
  elsif p_num_bind_vars = 16 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14), p_bind_vars_values(15),
            p_bind_vars_values(16);
  elsif p_num_bind_vars = 17 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14), p_bind_vars_values(15),
            p_bind_vars_values(16), p_bind_vars_values(17);
  elsif p_num_bind_vars = 18 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14), p_bind_vars_values(15),
            p_bind_vars_values(16), p_bind_vars_values(17), p_bind_vars_values(18);
  elsif p_num_bind_vars = 19 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14), p_bind_vars_values(15),
            p_bind_vars_values(16), p_bind_vars_values(17), p_bind_vars_values(18), p_bind_vars_values(19);
  elsif p_num_bind_vars = 20 then
      execute immediate l_sql(1) ||l_sql(2) ||l_sql(3) ||l_sql(4) ||l_sql(5) ||l_sql(6) ||l_sql(7) ||l_sql(8) ||l_sql(9) ||l_sql(10)||
                        l_sql(11)||l_sql(12)||l_sql(13)||l_sql(14)||l_sql(15)||l_sql(16)||l_sql(17)||l_sql(18)||l_sql(19)||l_sql(20)||
                        l_sql(21)||l_sql(22)||l_sql(23)||l_sql(24)||l_sql(25)||l_sql(26)||l_sql(27)||l_sql(28)||l_sql(29)||l_sql(30)||
                        l_sql(31)||l_sql(32)||l_sql(33)||l_sql(34)||l_sql(35)||l_sql(36)||l_sql(37)||l_sql(38)||l_sql(39)||l_sql(40)||
                        l_sql(41)||l_sql(42)||l_sql(43)||l_sql(44)||l_sql(45)||l_sql(46)||l_sql(47)||l_sql(48)||l_sql(49)||l_sql(50)
      using p_bind_vars_values(1), p_bind_vars_values(2), p_bind_vars_values(3), p_bind_vars_values(4), p_bind_vars_values(5),
            p_bind_vars_values(6), p_bind_vars_values(7), p_bind_vars_values(8), p_bind_vars_values(9), p_bind_vars_values(10),
            p_bind_vars_values(11), p_bind_vars_values(12), p_bind_vars_values(13), p_bind_vars_values(14), p_bind_vars_values(15),
            p_bind_vars_values(16), p_bind_vars_values(17), p_bind_vars_values(18), p_bind_vars_values(20);
  else
      raise e_max_bind_vars_exceeded;
  end if;
  exception
    when e_max_bind_vars_exceeded then
      fnd_file.put_line(FND_FILE.LOG,'Maximun bind variables supported by this api was exceeded');
      raise;
    when others then
      fnd_file.put_line(FND_FILE.LOG,'Error in execute_immediate: error='||sqlerrm||', count = '||p_varchar2_table.count||', bind#='||p_num_bind_vars);
      for i in 1..p_varchar2_table.count loop
        for j in 1..128 loop
          fnd_file.put_line(FND_FILE.LOG, substr(p_varchar2_table(i), (j-1)*256+1, 256));
        end loop;
      end loop;
      raise;
END;




END BSC_DBGEN_UTILS;

/
