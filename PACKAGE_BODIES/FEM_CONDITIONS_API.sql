--------------------------------------------------------
--  DDL for Package Body FEM_CONDITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_CONDITIONS_API" AS
--$Header: FEMCONDB.pls 120.14.12010000.5 2010/04/20 20:03:04 huli ship $

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------
G_FEM                    constant varchar2(3)  := 'FEM';
G_PKG_NAME               constant varchar2(30) := 'FEM_CONDITIONS_API';
G_BLOCK                  constant varchar2(80) := lower(G_FEM||'.PLSQL.'||G_PKG_NAME);

-- Log Level Constants
G_LOG_LEVEL_STATEMENT    constant number := FND_LOG.Level_Statement; --1--
G_LOG_LEVEL_PROCEDURE    constant number := FND_LOG.Level_Procedure; --2--
G_LOG_LEVEL_EVENT        constant number := FND_LOG.Level_Event;     --3--
G_LOG_LEVEL_EXCEPTION    constant number := FND_LOG.Level_Exception; --4--
G_LOG_LEVEL_ERROR        constant number := FND_LOG.Level_Error;     --5--
G_LOG_LEVEL_UNEXPECTED   constant number := FND_LOG.Level_Unexpected;--6--

--------------------------------------------------------------------------------
-- PACKAGE VARIABLES
--------------------------------------------------------------------------------
z_conditionObjectId           NUMBER;
z_ruleEffectiveDate           VARCHAR2(30);
z_factTableName               VARCHAR2(30);
z_tableAlias 	            VARCHAR2(30);
z_returnPredicateType         VARCHAR2(10);
z_displayPredicate            VARCHAR2(1);
z_loggingTurnedOn             VARCHAR2(1);

z_dataStepValues              DATA_STEP_VALUES_TAB;
z_dataStepValuesCtr           BINARY_INTEGER;

z_dataStepPredicates          DATA_DIM_STEP_PREDICATE_TAB;
z_dataStepPredicatesCtr       BINARY_INTEGER;

z_invalidDataComponents       INVALID_DATA_COMPONENTS_TAB;
z_invalidDataComponentsCtr    BINARY_INTEGER;

z_dimStepPredicates           DATA_DIM_STEP_PREDICATE_TAB;
z_dimStepPredicatesCtr        BINARY_INTEGER;


z_errCode                     NUMBER;
z_errMsg                      VARCHAR2(250);

z_invalidDimComponents        INVALID_DIM_COMPONENTS_TAB;
z_invalidDimComponentsCtr     BINARY_INTEGER;

z_conditionObjectDefId        NUMBER;
z_conditionObjectDefName      VARCHAR2(150);
z_conditionObjectFolderName   VARCHAR2(150);

z_componentObjectDefName      VARCHAR2(150);
z_componentObjectFolderName   VARCHAR2(150);

--------------------------------------------------------------------------------
-- PRIVATE FUNCTIONS AND PROCEDURES
--------------------------------------------------------------------------------

FUNCTION getHierValueSetId (
  p_dimension_id                  in number
  ,p_hierarchy_obj_id             in number
) RETURN number;

FUNCTION getDimensionValueSetId (
  p_dimension_id                  in number
  ,p_cond_component_obj_def_id    in number
) RETURN number;

FUNCTION getDimHierQuery (
  p_hierarchy_table_name         in varchar2
  ,p_relation_code               in varchar2
  ,p_hierarchy_obj_def_id        in number
  ,p_node_list                   in varchar2
  ,p_value_set_id                in number
  ,p_effective_date_varchar      in varchar2
) RETURN varchar2;

FUNCTION getDimFlatHierQuery (
  p_hierarchy_table_name         in varchar2
  ,p_relation_code               in varchar2
  ,p_hierarchy_obj_def_id        in number
  ,p_node_list                   in varchar2
  ,p_value_set_id                in number
) RETURN varchar2;



/*************************************************************************

                             tableNameIsValid

 Private function used to validate a table against registered tables
 in FEM_TABLES_V. (Only use enabled tables)

*************************************************************************/

FUNCTION tableNameIsValid(p_tableName IN VARCHAR2) RETURN BOOLEAN IS

CURSOR getTableName IS
SELECT TABLE_NAME
FROM FEM_TABLES_V
WHERE TABLE_NAME = p_tableName;

l_tableName VARCHAR2(30);

BEGIN

   IF (p_tableName = 'FEM_ACTIVITIES' OR p_tableName = 'FEM_COST_OBJECTS') THEN
     RETURN TRUE;
   ELSE

     OPEN getTableName;
     FETCH getTableName INTO l_tableName;
     IF (getTableName%NOTFOUND) THEN
       RETURN FALSE;
     ELSE
       RETURN TRUE;
     END IF;
     CLOSE getTableName;
   END IF;
END tableNameIsValid;





/*************************************************************************

                             columnNameIsValid

 Private function used to validate a column on a given table
 against registered tables in FEM_TAB_COLUMNS_V. (Only used enabled columns)

*************************************************************************/

FUNCTION columnNameIsValid(
   p_tableName IN VARCHAR2,
   p_columnName IN VARCHAR2,
   x_isDimension OUT NOCOPY BOOLEAN
   ) RETURN BOOLEAN IS

CURSOR getColumnName IS
   SELECT COLUMN_NAME,FEM_DATA_TYPE_CODE
   FROM FEM_TAB_COLUMNS_V
   WHERE TABLE_NAME = p_tableName
   AND COLUMN_NAME = p_columnName;

CURSOR getCompDimColumnName IS
   SELECT COLUMN_NAME
   FROM ALL_TAB_COLUMNS
   WHERE TABLE_NAME = p_tableName
   AND COLUMN_NAME = p_columnName
   AND OWNER = FEM_APP;

l_columnName VARCHAR2(30);
l_dataTypeCode  VARCHAR2(30);

BEGIN
   IF (p_tableName = 'FEM_ACTIVITIES' OR p_tableName = 'FEM_COST_OBJECTS') THEN
      OPEN getCompDimColumnName;
      FETCH getCompDimColumnName INTO l_columnName;
      IF (getCompDimColumnName%NOTFOUND) THEN
        RETURN FALSE;
      ELSE
        RETURN TRUE;
      END IF;
      CLOSE getCompDimColumnName;
   ELSE

      OPEN getColumnName;
      FETCH getColumnName INTO l_columnName,l_dataTypeCode;
      IF (getColumnName%NOTFOUND) THEN
         RETURN FALSE;
      ELSE
         IF (l_dataTypeCode = 'DIMENSION') THEN
           x_isDimension := TRUE;
         ELSE
           x_isDimension := FALSE;
         END IF;

         RETURN TRUE;
      END IF;

      CLOSE getColumnName;
   END IF;
END columnNameIsValid;



FUNCTION columnNameIsValid(
   p_tableName IN VARCHAR2,
   p_columnName IN VARCHAR2
   ) RETURN BOOLEAN IS

l_isDimension BOOLEAN;
l_isValidColumn BOOLEAN;

BEGIN
l_isValidColumn := columnNameIsValid(p_tableName, p_columnName,l_isDimension);
RETURN l_isValidColumn;
END;
/*************************************************************************

                             compDimColumnNameIsValid

 Private function used to validate a composite dimension column in
 FEM_COLUMN_REQUIREMNT_VL

*************************************************************************/

FUNCTION compDimColumnNameIsValid(
   p_tableName IN VARCHAR2,
   p_columnName IN VARCHAR2) RETURN BOOLEAN IS


CURSOR getCostObjColumnName IS
   SELECT COLUMN_NAME
   FROM FEM_COLUMN_REQUIREMNT_VL
   WHERE COST_OBJ_DIM_REQUIREMENT_CODE IS NOT NULL
   AND COST_OBJ_DIM_COMPONENT_FLAG = 'Y'
   AND COLUMN_NAME = p_columnName;

CURSOR getActivityColumnName IS
   SELECT COLUMN_NAME
   FROM FEM_COLUMN_REQUIREMNT_VL
   WHERE ACTIVITY_DIM_REQUIREMENT_CODE IS NOT NULL
   AND ACTIVITY_DIM_COMPONENT_FLAG = 'Y'
   AND COLUMN_NAME = p_columnName;

l_columnName VARCHAR2(30);

BEGIN
   IF (p_tableName = 'FEM_ACTIVITIES') THEN
     IF (p_columnName = 'ACTIVITY_ID') THEN
       RETURN TRUE;
     ELSE
       OPEN getActivityColumnName;
       FETCH getActivityColumnName INTO l_columnName;
       IF (getActivityColumnName%NOTFOUND) THEN
          RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;
       CLOSE getActivityColumnName;
     END IF;

   ELSIF (p_tableName = 'FEM_COST_OBJECTS') THEN
     IF (p_columnName = 'COST_OBJECT_ID') THEN
       RETURN TRUE;
     ELSE
       OPEN getCostObjColumnName ;
       FETCH getCostObjColumnName INTO l_columnName;
       IF (getCostObjColumnName%NOTFOUND) THEN
          RETURN FALSE;
       ELSE
          RETURN TRUE;
       END IF;
       CLOSE getCostObjColumnName;
     END IF;
   END IF;
END compDimColumnNameIsValid;

/*************************************************************************

                             getColumnDataType



*************************************************************************/

FUNCTION getColumnDataType(
   p_synonymName IN VARCHAR2,
   p_columnName  IN VARCHAR2,
   p_isDimension IN BOOLEAN,
   p_dimensionId IN NUMBER) RETURN VARCHAR2 IS




l_returnStatus   VARCHAR2(1);
l_msgCount       NUMBER;
l_msgData        VARCHAR2(240);


l_schemaName ALL_SYNONYMS.TABLE_OWNER%TYPE;
l_tableName  ALL_SYNONYMS.TABLE_NAME%TYPE;
l_dataType   ALL_TAB_COLUMNS.DATA_TYPE%TYPE;

BEGIN

IF (p_isDimension) THEN
SELECT DECODE (MEMBER_DATA_TYPE_CODE, 'NUMBER', 'NUMBER', 'DATE', 'DATE', 'STRING')
INTO l_dataType
FROM FEM_XDIM_DIMENSIONS
WHERE DIMENSION_ID = p_dimensionId;

/*TO DO: handle exceptions*/

ELSE

FEM_DATABASE_UTIL_PKG.Get_Table_Owner(
p_api_version => 1.0,
p_commit => FND_API.G_FALSE,
p_init_msg_list => FND_API.G_TRUE,
p_encoded => FND_API.G_TRUE,
x_return_status => l_returnStatus,
x_msg_count => l_msgCount,
x_msg_data => l_msgData,
p_syn_name => p_synonymName,
x_tab_name => l_tableName,
x_tab_owner => l_schemaName);


/*TO DO: handle exceptions*/


SELECT DECODE (DATA_TYPE, 'NUMBER', 'NUMBER', 'DATE', 'DATE', 'STRING')
INTO   l_dataType
FROM   ALL_TAB_COLUMNS
WHERE  TABLE_NAME = l_tableName
AND    COLUMN_NAME = p_columnName
AND    OWNER = l_schemaName;

/*TO DO: handle exceptions*/
END IF;

RETURN l_dataType;
END getColumnDataType;

/*************************************************************************

                             operatorValue

 Private function that returns the meaning of a operator code as stored
 in FND_LOOKUP_VALUES.

*************************************************************************/

FUNCTION operatorValue(p_operatorCode IN VARCHAR2) RETURN VARCHAR2 IS

l_operatorValue VARCHAR2(30);

BEGIN
   l_operatorValue :=
        CASE p_operatorCode
	  WHEN 'GREATER' THEN '>'
	  WHEN 'LESSER'  THEN '<'
	  WHEN 'EQUAL'   THEN '='
	  WHEN 'GREATER_EQUAL' THEN '>='

	  WHEN 'LESSER_EQUAL' THEN '<='
	  WHEN 'NOT_EQUAL' THEN '<>'
	  WHEN 'BETWEEN' THEN 'Between'
	  WHEN 'NOT_BETWEEN' THEN 'Not Between'
        ELSE '[Invalid Operator Code]'
        END;

  RETURN l_operatorValue;
END operatorValue;



/*************************************************************************

                             getValidComponentSql

 Private function which retrieves the sql statement for obtaining the
 dimension and/or data components of a condition.

*************************************************************************/

FUNCTION getValidComponentSql(
   p_returnPredicateType IN VARCHAR2,
   p_displayPredicate IN VARCHAR2,
   p_inputFactTable IN VARCHAR2,
   x_numOfBindVariables OUT NOCOPY NUMBER) RETURN LONG IS

l_dataCmpSql LONG;
l_sqlStmt LONG;
l_intermediateDimStmt LONG;

BEGIN

   IF (p_returnPredicateType = 'DATA') THEN
      IF (p_displayPredicate = 'Y') THEN
         l_sqlStmt := G_QUERY_FOR_DISPLAY_DATA_CMPS;
         x_numOfBindVariables := 1;
      ELSIF (p_displayPredicate = 'N') THEN
         l_sqlStmt := G_QUERY_FOR_DATA_CMPS;
         x_numOfBindVariables := 2;
      END IF;

   ELSIF (p_returnPredicateType = 'DIM') THEN
      l_sqlStmt := G_QUERY_FOR_DIM_CMPS;
      x_numOfBindVariables := 1;

   ELSIF (p_returnPredicateType = 'BOTH') THEN
      IF (p_displayPredicate = 'Y') THEN
         l_sqlStmt := G_QUERY_FOR_DISPLAY_DATA_CMPS
   		          ||G_UNION
		          ||G_QUERY_FOR_DIM_CMPS;
         x_numOfBindVariables := 2;

      ELSIF (p_displayPredicate = 'N') THEN
         l_sqlStmt := G_QUERY_FOR_DATA_CMPS
	           	    ||G_UNION
		          ||G_QUERY_FOR_DIM_CMPS;
         x_numOfBindVariables := 3;
      END IF;
   END IF;

   RETURN l_sqlStmt ;

END getValidComponentSql;


/*************************************************************************

                             openConditionCursor

 This procedure opens the cursor to fetch all valid components of Condition
 based on the type of component (Data or Dimension) being processed

*************************************************************************/

PROCEDURE openConditionCursor(
   x_compCv OUT NOCOPY COMP_CUR_TYPE,
   p_sqlStmt IN LONG,
   p_numOfBindVariables IN NUMBER,
   p_conditionObjDefId IN NUMBER,
   p_displayPredicate IN VARCHAR2,
   p_factTableName IN VARCHAR2) IS

BEGIN

   IF (p_numOfBindVariables = 1) THEN
      OPEN x_compCv FOR p_sqlStmt USING
         p_conditionObjDefId;

   ELSIF (p_numOfBindVariables = 2) THEN
      IF (p_displayPredicate = 'Y') THEN
         OPEN x_compCv FOR p_sqlStmt USING
	      p_conditionObjDefId,
            p_conditionObjDefId;
      ELSIF (p_displayPredicate = 'N') THEN
         OPEN x_compCv FOR p_sqlStmt USING
            p_conditionObjDefId,
            p_factTableName;
      END IF;

   ELSIF (p_numOfBindVariables = 3) THEN
      OPEN x_compCv FOR p_sqlStmt USING
         p_conditionObjDefId,
         p_factTableName,
         p_conditionObjDefId;
   END IF;

END openConditionCursor;


/*************************************************************************

                             validateHierarchyNode

 Private function used for validating the existance of a specific node on
 a given hierarchy definition.

*************************************************************************/

FUNCTION validateHierarchyNode(p_tableName IN VARCHAR2,
                               p_node IN NUMBER,
                               p_value_set_id IN NUMBER,
                               p_objId IN NUMBER,
                               p_objDefId IN NUMBER,
                               p_effectiveDate IN VARCHAR2) RETURN BOOLEAN IS

l_sql VARCHAR2(1000);

TYPE HIERARCHY_CUR_TYPE IS REF CURSOR;
hierarchyCursor HIERARCHY_CUR_TYPE;

l_childId NUMBER;
l_nodeExists BOOLEAN;

  l_value_set_string              varchar2(2000);

BEGIN

IF (p_tableName = 'FEM_COST_OBJECTS_HIER') THEN
  l_sql := 'SELECT CHILD_ID '
  ||'FROM ' || p_tableName
  ||' WHERE CHILD_ID = :1 AND hierarchy_obj_id = :2 AND TO_DATE('''||p_effectiveDate||''',''YYYY/MM/DD HH24:MI:SS'') BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE'
  ||' UNION SELECT PARENT_ID '
  ||'FROM ' || p_tableName
  ||' WHERE PARENT_ID = :3 AND hierarchy_obj_id = :4 AND TO_DATE('''||p_effectiveDate||''',''YYYY/MM/DD HH24:MI:SS'') BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE';

OPEN hierarchyCursor FOR l_sql USING p_node, p_objId, p_node, p_objId;

ELSE

  l_value_set_string := null;

  if (p_value_set_id is not null) then

    l_value_set_string := ' AND CHILD_VALUE_SET_ID = '||p_value_set_id;

  end if;

  l_sql :=
    ' SELECT CHILD_ID '
  ||' FROM ' || p_tableName
  ||' WHERE CHILD_ID = :1 AND hierarchy_obj_def_id = :2'
  ||  l_value_set_string;

OPEN hierarchyCursor FOR l_sql USING p_node, p_objDefId;

END IF;

--OPEN hierarchyCursor FOR l_sql USING p_node, p_objDefId;

FETCH hierarchyCursor INTO l_childId;

IF hierarchyCursor%NOTFOUND THEN
  l_nodeExists := FALSE;
ELSE
  l_nodeExists := TRUE;
END IF;

CLOSE hierarchyCursor;

RETURN l_nodeExists;

END validateHierarchyNode;


/*************************************************************************

                             specificValueStep

 Private procedure which generates the predicate for a Data Component Step
 of type 'Specific Value'

*************************************************************************/

PROCEDURE specificValueStep(
   p_tableName IN VARCHAR2,
   p_tableAlias IN VARCHAR2,
   p_columnName IN VARCHAR2,
   p_isDimension IN BOOLEAN,
   x_stepSpecificString OUT NOCOPY LONG) IS

l_columnPrefix VARCHAR2(30);
l_stepSpecificString LONG;
--l_dataStepValuesCount NUMBER := z_dataStepValues.COUNT;

--3/23/2006
l_isDimension BOOLEAN;
l_sqlStmt VARCHAR2(500);
l_displayCodeCol FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE;
l_memberTableName FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE;
l_displayCodeVal FEM_LEDGERS_B.LEDGER_DISPLAY_CODE%TYPE;
l_displayCodeSQL VARCHAR2(500);

l_dim_column_name FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE;

BEGIN

 IF (p_tableAlias IS NULL) THEN
    l_columnPrefix := NULL;
 ELSE
    l_columnPrefix := p_tableAlias||G_PERIOD;
 END IF;

 FOR i IN z_dataStepValues.FIRST..z_dataStepValues.LAST LOOP

  --3/23/06 NEW LOGIC HERE
  IF (z_dataStepValues(i).OPERATOR_CODE IN ('GREATER','GREATER_EQUAL','LESSER','LESSER_EQUAL')) THEN
    --if column is a dimension column then query fem_xdim_dimensions to get display code column name and member table name
     IF (p_isDimension) THEN

        --SELECT MEMBER_DISPLAY_CODE_COL, MEMBER_B_TABLE_NAME
        --INTO l_displayCodeCol, l_memberTableName
        --FROM FEM_XDIM_DIMENSIONS
        --WHERE MEMBER_COL = p_columnName;
        select dim.MEMBER_DISPLAY_CODE_COL, dim.MEMBER_B_TABLE_NAME, dim.MEMBER_COL
         INTO l_displayCodeCol, l_memberTableName, l_dim_column_name
         from fem_tab_columns_b tab_col, FEM_XDIM_DIMENSIONS dim
         where tab_col.table_name = p_tableName
         and tab_col.dimension_id = dim.dimension_id
         and tab_col.column_name = p_columnName;


        --only proceed with obtaining display codes if the display code column is different from member column;
        --ie. display code col exists on member table
        IF (l_displayCodeCol <> p_columnName) THEN
           --get display codes for selected value
           l_sqlStmt := 'SELECT '|| l_displayCodeCol||' FROM '||l_memberTableName||' WHERE '
              || l_dim_column_name--p_columnName
              ||' = :1';

           EXECUTE IMMEDIATE l_sqlStmt
           INTO  l_displayCodeVal
           USING z_dataStepValues(i).VALUE;

           --build data step predicate using display codes

           l_displayCodeSQL:= 'SELECT '
                              ||l_dim_column_name--p_columnName
                              || ' FROM '||l_memberTableName||
                              ' WHERE '||l_displayCodeCol||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
                              ||''''||l_displayCodeVal||'''';

           l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName||' IN '
		  ||G_OPEN||l_displayCodeSQL||G_CLOSE
		  ||G_CLOSE;

        ELSE --DISPLAY CODE AND COLUMN NAME EQUAL
           l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;

        END IF;

     ELSE --IF NOT A DIMENSION

        l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;
     END IF;


     IF (i < z_dataStepValues.LAST) THEN
      l_stepSpecificString := l_stepSpecificString||G_SPACE||G_OR||G_SPACE;
     END IF;


  ELSIF (z_dataStepValues(i).OPERATOR_CODE = 'EQUAL') THEN

     l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;

/*   IF (i = z_dataStepValues.FIRST) THEN
     l_stepSpecificString := l_stepSpecificString
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE;
    ELSE
     l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;
    END IF;*/
    IF (i < z_dataStepValues.LAST) THEN
      l_stepSpecificString := l_stepSpecificString||G_SPACE||G_OR||G_SPACE;
    END IF;

  ELSIF (z_dataStepValues(i).OPERATOR_CODE = 'NOT_EQUAL') THEN

     l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_GREATER||G_SPACE
		  ||z_dataStepValues(i).VALUE
                  ||G_SPACE||G_OR||G_SPACE
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_LESSER||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;

/*IF (i = z_dataStepValues.FIRST) THEN
     l_stepSpecificString := l_stepSpecificString
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_GREATER||G_SPACE
		  ||z_dataStepValues(i).VALUE
                  ||G_SPACE||G_OR||G_SPACE
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_LESSER||G_SPACE
		  ||z_dataStepValues(i).VALUE;
ELSE
     l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_GREATER||G_SPACE
		  ||z_dataStepValues(i).VALUE
                  ||G_SPACE||G_OR||G_SPACE
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_LESSER||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;
END IF;*/
    IF (i < z_dataStepValues.LAST) THEN
      l_stepSpecificString := l_stepSpecificString||G_SPACE||G_AND||G_SPACE;
    END IF;

  /*ELSE --ERROR UNHANDLED OPERATOR
    l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_CLOSE;

    IF (i < z_dataStepValues.LAST) THEN
      l_stepSpecificString := l_stepSpecificString||G_SPACE||G_OR||G_SPACE;
    END IF;*/
  END IF;

 END LOOP;
 --**l_stepSpecificString := G_OPEN||l_stepSpecificString||G_CLOSE;

  x_stepSpecificString := l_stepSpecificString;

 EXCEPTION
    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg  := 'Procedure: specificValueStep: '||SQLERRM;
	 RAISE;

END specificValueStep;


/*************************************************************************

                             anotherColumnStep

 Private procedure which generates the predicate for a Data Component Step
 of type 'Another Column'


*************************************************************************/

PROCEDURE anotherColumnStep(
   p_tableName IN VARCHAR2,
   p_tableAlias IN VARCHAR2,
   p_columnName IN VARCHAR2,
   x_stepSpecificString OUT NOCOPY LONG) IS

l_columnPrefix VARCHAR2(30);
l_stepSpecificString LONG;

BEGIN

 IF (p_tableAlias IS NULL) THEN
    l_columnPrefix := NULL;
 ELSE
    l_columnPrefix := p_tableAlias||G_PERIOD;
 END IF;

 FOR i IN z_dataStepValues.FIRST..z_dataStepValues.LAST LOOP
   IF (z_dataStepValues(i).OPERATOR_CODE <> 'NOT_EQUAL') THEN

      l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
		  ||G_CLOSE;

/*    IF (i = z_dataStepValues.FIRST) THEN
          l_stepSpecificString := l_stepSpecificString
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE;
    ELSE
      l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
		  ||G_CLOSE;
    END IF;*/

    IF (i < z_dataStepValues.LAST) THEN
      l_stepSpecificString := l_stepSpecificString||G_SPACE||G_OR||G_SPACE;
    END IF;

   ELSIF (z_dataStepValues(i).OPERATOR_CODE = 'NOT_EQUAL') THEN

    l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_GREATER||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
              ||G_SPACE||G_OR||G_SPACE
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_LESSER||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
		  ||G_CLOSE;

/*IF (i = z_dataStepValues.FIRST) THEN
    l_stepSpecificString := l_stepSpecificString
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_GREATER||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
              ||G_SPACE||G_OR||G_SPACE
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_LESSER||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE;
ELSE
    l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_GREATER||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
              ||G_SPACE||G_OR||G_SPACE
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||G_LESSER||G_SPACE
		  ||l_columnPrefix||z_dataStepValues(i).VALUE
		  ||G_CLOSE;
END IF;*/

    IF (i < z_dataStepValues.LAST) THEN
      l_stepSpecificString := l_stepSpecificString||G_SPACE||G_AND||G_SPACE;
    END IF;

   END IF;
 END LOOP;

  x_stepSpecificString := l_stepSpecificString;

 EXCEPTION
    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg  := 'Procedure: anotherColumnStep: '||SQLERRM;
	 RAISE;

END anotherColumnStep;


/*************************************************************************

                             rangeStep

 Private procedure which generates the predicate for a Data Component Step
 of type 'Range Value'


*************************************************************************/

PROCEDURE rangeStep(
   p_tableName  IN VARCHAR2,
   p_tableAlias IN VARCHAR2,
   p_columnName IN VARCHAR2,
   p_isDimension IN BOOLEAN,
   x_stepSpecificString OUT NOCOPY LONG) IS

l_columnPrefix VARCHAR2(30);
l_stepSpecificString LONG;
--l_dataStepValuesCount NUMBER := z_dataStepValues.COUNT;

--3/23/2006
l_isDimension BOOLEAN;
l_sqlStmt VARCHAR2(500);
l_displayCodeCol FEM_XDIM_DIMENSIONS.MEMBER_DISPLAY_CODE_COL%TYPE;
l_memberTableName FEM_XDIM_DIMENSIONS.MEMBER_B_TABLE_NAME%TYPE;
l_minRangeDisplayCode FEM_LEDGERS_B.LEDGER_DISPLAY_CODE%TYPE;
l_maxRangeDisplayCode FEM_LEDGERS_B.LEDGER_DISPLAY_CODE%TYPE;
l_displayCodeSQL VARCHAR2(500);

l_dim_column_name FEM_XDIM_DIMENSIONS.MEMBER_COL%TYPE;

BEGIN

  IF (p_tableAlias IS NULL) THEN
    l_columnPrefix := NULL;
  ELSE
    l_columnPrefix := p_tableAlias||G_PERIOD;
  END IF;

  FOR i IN z_dataStepValues.FIRST..z_dataStepValues.LAST LOOP

    --3/23/06 NEW LOGIC HERE
    --if column is a dimension column then query fem_xdim_dimensions to get display code column name and member table name
     IF (p_isDimension) THEN

        --SELECT MEMBER_DISPLAY_CODE_COL, MEMBER_B_TABLE_NAME
        --INTO l_displayCodeCol, l_memberTableName
        --FROM FEM_XDIM_DIMENSIONS
        --WHERE MEMBER_COL = p_columnName;
         select dim.MEMBER_DISPLAY_CODE_COL, dim.MEMBER_B_TABLE_NAME, dim.MEMBER_COL
         INTO l_displayCodeCol, l_memberTableName, l_dim_column_name
         from fem_tab_columns_b tab_col, FEM_XDIM_DIMENSIONS dim
         where tab_col.table_name = p_tableName
         and tab_col.dimension_id = dim.dimension_id
         and tab_col.column_name = p_columnName;

        --only proceed with obtaining display codes if the display code column is different from member column;
        --ie. display code col exists on member table
        IF (l_displayCodeCol <> p_columnName) THEN
           --get display codes for min and max range values
           l_sqlStmt := 'SELECT '|| l_displayCodeCol||' FROM '||l_memberTableName||' WHERE '
              || l_dim_column_name
              --p_columnName
              ||' = :1';

           EXECUTE IMMEDIATE l_sqlStmt
           INTO  l_minRangeDisplayCode
           USING z_dataStepValues(i).VALUE;


           EXECUTE IMMEDIATE l_sqlStmt
           INTO  l_maxRangeDisplayCode
           USING z_dataStepValues(i).MAX_RANGE_VALUE;


           --build data step predicate using display codes

           l_displayCodeSQL:= 'SELECT '||
                              --p_columnName
                              l_dim_column_name ||
                              ' FROM '||l_memberTableName||
                              ' WHERE '||l_displayCodeCol||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
                              ||''''||l_minRangeDisplayCode||''''||' AND '||''''||l_maxRangeDisplayCode||'''';

           l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName||' IN '
		  ||G_OPEN||l_displayCodeSQL||G_CLOSE
		  ||G_CLOSE;

        ELSE
           l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_SPACE||G_AND||G_SPACE
                  ||z_dataStepValues(i).MAX_RANGE_VALUE
		  ||G_CLOSE;

        END IF;

     ELSE --IF NOT A DIMENSION

        l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_SPACE||G_AND||G_SPACE
                  ||z_dataStepValues(i).MAX_RANGE_VALUE
		  ||G_CLOSE;
     END IF;


     IF (z_dataStepValues(i).OPERATOR_CODE = 'BETWEEN') THEN

       /*l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_SPACE||G_AND||G_SPACE
                  ||z_dataStepValues(i).MAX_RANGE_VALUE
		  ||G_CLOSE;*/

        IF (i < z_dataStepValues.LAST) THEN
            l_stepSpecificString := l_stepSpecificString||G_SPACE||G_OR||G_SPACE;
        END IF;

      ELSIF (z_dataStepValues(i).OPERATOR_CODE = 'NOT_BETWEEN') THEN

       /*l_stepSpecificString := l_stepSpecificString
		  ||G_OPEN
		  ||l_columnPrefix||p_columnName
		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
		  ||z_dataStepValues(i).VALUE
		  ||G_SPACE||G_AND||G_SPACE
                  ||z_dataStepValues(i).MAX_RANGE_VALUE
		  ||G_CLOSE;*/

         IF (i < z_dataStepValues.LAST) THEN
            l_stepSpecificString := l_stepSpecificString||G_SPACE||G_AND||G_SPACE;
         END IF;

      /*ELSE --ERROR -- UNHANDLED OPERATOR
       l_stepSpecificString := l_stepSpecificString
  		  ||G_OPEN
  		  ||l_columnPrefix||p_columnName
  		  ||G_SPACE||z_dataStepValues(i).OPERATOR_VALUE||G_SPACE
  		  ||z_dataStepValues(i).VALUE
  		  ||G_CLOSE;

          IF (i < z_dataStepValues.LAST) THEN
            l_stepSpecificString := l_stepSpecificString||G_SPACE||G_OR||G_SPACE;
          END IF;*/
     END IF;

 END LOOP;

--** l_stepSpecificString := G_OPEN||l_stepSpecificString||G_CLOSE;
 x_stepSpecificString := l_stepSpecificString;

 EXCEPTION
    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg  := 'Procedure: rangeStep: '||SQLERRM;
	 RAISE;

END rangeStep;


/*************************************************************************

                             logPredicateToOutputFile

 Private procedure used to log the Conditions predicate to an output file.

*************************************************************************/

PROCEDURE logPredicateToOutputFile(
   p_conditionObjId IN DEF_OBJECT_ID%TYPE,
   p_returnPredicateType IN VARCHAR2)  IS

BEGIN

  FND_FILE.put_line(FND_FILE.OUTPUT, 'Condition Name:  '||z_conditionObjectDefName);
  FND_FILE.put_line(FND_FILE.OUTPUT, '');

  IF (p_returnPredicateType = 'DATA') THEN

   IF (z_dataStepPredicates.COUNT > 0) THEN
    FOR i IN z_dataStepPredicates.FIRST..z_dataStepPredicates.LAST LOOP
     IF (z_dataStepPredicates(i).Step_Specific_Predicate IS NOT NULL) THEN
      FND_FILE.put_line(FND_FILE.OUTPUT
                     ,z_dataStepPredicates(i).Step_Specific_Predicate);
      IF (i < z_dataStepPredicates.LAST) THEN
       FND_FILE.put_line(FND_FILE.OUTPUT,G_SPACE||G_AND||G_SPACE);
      END IF;
     END IF;
    END LOOP;
   END IF;

  ELSIF (p_returnPredicateType = 'DIM') THEN

   IF (z_dimStepPredicates.COUNT > 0) THEN
    FOR i IN z_dimStepPredicates.FIRST..z_dimStepPredicates.LAST LOOP
     IF (z_dimStepPredicates(i).Step_Specific_Predicate IS NOT NULL) THEN
      FND_FILE.put_line(FND_FILE.OUTPUT
                     ,z_dimStepPredicates(i).Step_Specific_Predicate);
      IF (i < z_dimStepPredicates.LAST) THEN
       FND_FILE.put_line(FND_FILE.OUTPUT,G_SPACE||G_AND||G_SPACE);
      END IF;
     END IF;
    END LOOP;
   END IF;

  ELSIF (p_returnPredicateType = 'BOTH') THEN

    IF (z_dataStepPredicates.COUNT > 0) THEN
    FOR i IN z_dataStepPredicates.FIRST..z_dataStepPredicates.LAST LOOP
     IF (z_dataStepPredicates(i).Step_Specific_Predicate IS NOT NULL) THEN
      FND_FILE.put_line(FND_FILE.OUTPUT
                     ,z_dataStepPredicates(i).Step_Specific_Predicate);
      IF (i < z_dataStepPredicates.LAST) THEN
       FND_FILE.put_line(FND_FILE.OUTPUT,G_SPACE||G_AND||G_SPACE);
      END IF;
     END IF;
    END LOOP;
   END IF;

   IF (z_dimStepPredicates.COUNT > 0) THEN
      IF (z_dataStepPredicates.COUNT > 0) THEN
       FND_FILE.put_line(FND_FILE.OUTPUT,G_SPACE||G_AND||G_SPACE);
      END IF;
    FOR i IN z_dimStepPredicates.FIRST..z_dimStepPredicates.LAST LOOP
     IF (z_dimStepPredicates(i).Step_Specific_Predicate IS NOT NULL) THEN

 --FND_FILE.put_line(FND_FILE.OUTPUT,'LENGTH '||LENGTH(z_dimStepPredicates(i).Step_Specific_Predicate));

      FND_FILE.put_line(FND_FILE.OUTPUT
                     ,z_dimStepPredicates(i).Step_Specific_Predicate);
      IF (i < z_dimStepPredicates.LAST) THEN
       FND_FILE.put_line(FND_FILE.OUTPUT,G_SPACE||G_AND||G_SPACE);
      END IF;
     END IF;
    END LOOP;
   END IF;
  END IF;


 EXCEPTION
    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg  := 'Procedure: logPredicateToOutputFile: '||SQLERRM;
	 RAISE;

END logPredicateToOutputFile;


/*************************************************************************

                             generateDataStepPredicate

 This procedure generates the predicate for a particular Data Component
 Step.

*************************************************************************/

PROCEDURE generateDataStepPredicate(
   p_dataComponentDefId IN NUMBER,
   p_factTable IN VARCHAR2,
   p_tableAlias IN VARCHAR2,
   p_firstColumnName IN VARCHAR2,
   p_stepType IN VARCHAR2,
   p_stepSequence IN NUMBER,
   p_operator IN VARCHAR2,
   p_operatorValue IN VARCHAR2,
   p_isDimension IN BOOLEAN,
   p_byDimensionColumn IN VARCHAR2,
   p_byDimensionValue  IN VARCHAR2,
   x_stepSpecificString OUT NOCOPY LONG) IS

cursor getDataCmpStepDtl is
select
 a.criteria_sequence
,a.value
,a.max_range_value
from
Fem_Cond_Data_Cmp_St_Dtl a
where a.COND_DATA_CMP_OBJ_DEF_ID = p_dataComponentDefId
and a.TABLE_NAME = p_factTable
and a.STEP_SEQUENCE = p_stepSequence
order by a.criteria_Sequence;

l_criteriaSequence NUMBER(9,0);
l_value    VARCHAR2(255);
l_maxRangeValue VARCHAR2(255);
l_dataType  ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
l_canonicalDTMask varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';
l_byDimensionValue VARCHAR2(40) := p_byDimensionValue;
l_columnPrefix VARCHAR2(30);


BEGIN

--Deleting all records in z_dataStepValues---

  z_dataStepValues.DELETE;
  z_dataStepValuesCtr := 0;
------------------------------------------------------------

  OPEN getDataCmpStepDtl;
  LOOP
    <<NEXT_DATA_CMP_STEP_DTL>>
  FETCH getDataCmpStepDtl into
   l_criteriaSequence
  ,l_value
  ,l_maxRangeValue;
      EXIT WHEN getDataCmpStepDtl%NOTFOUND;

   /*--If Step_Type is 'Another Column' validate the SECOND column--*/
    IF (p_stepType = G_DATA_ANOTHER_COL) THEN
      IF NOT columnNameIsValid(p_tableName => p_factTable
                            ,p_columnName =>l_value) THEN
     -- IF (z_loggingTurnedOn = 'Y') THEN
fnd_message.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_COLUMN);
fnd_message.set_token(TOKEN => G_COLUMN_TOKEN, VALUE => l_value, TRANSLATE => FALSE);
fnd_message.set_token(TOKEN => G_TABLE_TOKEN, VALUE =>p_factTable,TRANSLATE => FALSE);
fnd_msg_pub.add_detail(p_message_type => 'W');

        /*FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => FEM_APP,
         p_msg_name => G_INVALID_COLUMN,
         p_token1 => G_COLUMN_TOKEN,
         p_value1 => l_value,
         p_token2 => G_TABLE_TOKEN,
         p_value2 => p_factTable);*/
       --  p_token3 => 'FND_MESSAGE_TYPE',
       --  p_value3 => 'W');


     -- END IF;
      RETURN;
      END IF;
    END IF;

   l_dataType := getColumnDataType(p_synonymName => p_factTable,
                                p_columnName => p_firstColumnName,
                                p_isDimension => FALSE,
                                p_dimensionId => NULL);


   IF (p_stepType <> G_DATA_ANOTHER_COL) THEN
       IF (l_dataType = 'STRING') THEN
         l_value := ''''||l_value||'''';
         IF (p_stepType = G_RANGE_OF_VALUES) THEN
           l_maxRangeValue := ''''||l_maxRangeValue ||'''';
         END IF;
       ELSIF (l_dataType = 'DATE') THEN
         l_value:= 'TO_DATE'||G_OPEN ||''''||l_value||''''||','||''''||l_canonicalDTMask||''''||G_CLOSE;
         IF (p_stepType = G_RANGE_OF_VALUES) THEN
            l_maxRangeValue := 'TO_DATE'||G_OPEN ||''''||l_maxRangeValue ||''''||','||''''||l_canonicalDTMask||''''||G_CLOSE;
         END IF;
       END IF;
   END IF;

   /*---------------------------------------------------------------*/

   z_dataStepValues(z_dataStepValuesCtr).OPERATOR_CODE
                       := p_operator;
   z_dataStepValues(z_dataStepValuesCtr).OPERATOR_VALUE
                       := p_operatorValue;
   z_dataStepValues(z_dataStepValuesCtr).VALUE
                       := l_value;
   z_dataStepValues(z_dataStepValuesCtr).MAX_RANGE_VALUE
                       := l_maxRangeValue;
   z_dataStepValuesCtr := z_dataStepValuesCtr + 1;

  END LOOP;
  CLOSE getDataCmpStepDtl;

 IF (z_dataStepValues.COUNT > 0) THEN
  IF (p_stepType = G_DATA_ANOTHER_COL) THEN
         anotherColumnStep(p_tableName => p_factTable
                       ,p_tableAlias => p_tableAlias
                       ,p_columnName => p_firstColumnName
		       ,x_stepSpecificString => x_stepSpecificString
    		       );
  ELSIF (p_stepType = G_SPECIFIC_VALUE) THEN
	 specificValueStep(p_tableName => p_factTable
                        ,p_tableAlias => p_tableAlias
                        ,p_columnName => p_firstColumnName
                        ,p_isDimension => p_isDimension
                        ,x_stepSpecificString => x_stepSpecificString
                        );
  ELSIF (p_stepType = G_RANGE_OF_VALUES) THEN
         rangeStep(p_tableName => p_factTable
                   ,p_tableAlias => p_tableAlias
                   ,p_columnName => p_firstColumnName
                   ,p_isDimension => p_isDimension
                   ,x_stepSpecificString => x_stepSpecificString
                    );
  END IF;
 END IF;

--TEST*********************
IF (z_dataStepValues.COUNT > 1) THEN
 x_stepSpecificString := G_OPEN || x_stepSpecificString || G_CLOSE;
END IF;


--MAPPING BY DIMENSION TYPE SUPPORT... MUST USE APPEND OR CONDITION TO PREDICATE
 IF (p_byDimensionColumn = p_firstColumnName) THEN

       IF (p_tableAlias IS NULL) THEN
          l_columnPrefix := NULL;
       ELSE
          l_columnPrefix := p_tableAlias||G_PERIOD;
       END IF;

       IF (l_dataType = 'STRING') THEN
         l_byDimensionValue := ''''||l_byDimensionValue ||'''';
       ELSIF (l_dataType = 'DATE') THEN
         l_byDimensionValue  := 'TO_DATE'||G_OPEN ||''''||l_byDimensionValue
                                 ||''''||','||''''||l_canonicalDTMask||''''||G_CLOSE;
       END IF;

   x_stepSpecificString := G_OPEN||x_stepSpecificString||G_SPACE||G_OR||G_SPACE
                           ||G_OPEN||l_columnPrefix||p_byDimensionColumn||G_SPACE||G_EQUAL||G_SPACE||l_byDimensionValue
                           ||G_CLOSE||G_CLOSE;
 END IF;

 EXCEPTION
    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg := 'Procedure: generateDataStepPredicate: '||SQLERRM;
	 RAISE;

END generateDataStepPredicate;


/*************************************************************************

                             generateDataPredicate

 This procedure generates predicates for all the Data Component Steps
 and populates the z_dataStepPredicates PLSQL table with the individual
 Data Component Step predicates

*************************************************************************/

PROCEDURE generateDataPredicate(p_dataComponentDefId IN NUMBER
				 ,p_factTableName IN VARCHAR2
				 ,p_tableAlias IN VARCHAR2
                         ,p_byDimensionColumn IN VARCHAR2
                         ,p_byDimensionValue IN VARCHAR2
				 ) IS

cursor getDataCmpSteps is
select
 a.column_name
,a.step_type
,a.step_sequence
,a.operator
from
 Fem_Cond_Data_Cmp_Steps a
where a.COND_DATA_CMP_OBJ_DEF_ID = p_dataComponentDefId
and a.TABLE_NAME = p_factTableName
order by a.step_sequence;

l_columnName VARCHAR2(30);

l_stepType  VARCHAR2(30);
l_stepSequence NUMBER;
l_operator VARCHAR2(30);
l_operatorValue VARCHAR2(30);

l_stepSpecificString LONG;
l_isDimension BOOLEAN;

BEGIN

 OPEN getDataCmpSteps;
 LOOP
  <<NEXT_DATA_CMP_STEP>>
 FETCH getDataCmpSteps INTO
  l_columnName
 ,l_stepType
 ,l_stepSequence
 ,l_operator;
      EXIT WHEN getDataCmpSteps%NOTFOUND;

    IF NOT columnNameIsValid(p_tableName => p_factTableName
                           ,p_columnName => l_columnName
                           ,x_isDimension => l_isDimension) THEN

      --IF (z_loggingTurnedOn = 'Y') THEN
fnd_message.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_COLUMN);
fnd_message.set_token(TOKEN => G_COLUMN_TOKEN, VALUE => l_columnName, TRANSLATE => FALSE);
fnd_message.set_token(TOKEN => G_TABLE_TOKEN, VALUE =>p_factTableName,TRANSLATE => FALSE);
fnd_msg_pub.add_detail(p_message_type => 'W');
       /* FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => FEM_APP,
         p_msg_name => G_INVALID_COLUMN,
         p_token1 => G_COLUMN_TOKEN,
         p_value1 => l_columnName,
         p_token2 => G_TABLE_TOKEN,
         p_value2 => p_factTableName);*/


     -- END IF;

      GOTO NEXT_DATA_CMP_STEP;
    END IF;


    l_operatorValue := operatorValue(l_operator);

    IF (l_operatorValue = '[Invalid Operator Code]') THEN

     -- IF (z_loggingTurnedOn = 'Y') THEN

fnd_message.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_OPERATOR);
fnd_message.set_token(TOKEN => G_OPERATOR_TOKEN, VALUE => l_operator, TRANSLATE => FALSE);
fnd_msg_pub.add_detail(p_message_type => 'W');

    /*    FEM_ENGINES_PKG.PUT_MESSAGE(
         p_app_name => FEM_APP,
         p_msg_name => G_INVALID_OPERATOR,
         p_token1 => G_OPERATOR_TOKEN,
         p_value1 => l_operator);*/
     -- END IF;

      GOTO NEXT_DATA_CMP_STEP;
    END IF;


    generateDataStepPredicate(
	 	p_dataComponentDefId => p_dataComponentDefId
	       ,p_factTable => p_factTableName
	       ,p_tableAlias => p_tableAlias
	       ,p_firstColumnName => l_columnName
	       ,p_stepType => l_stepType
	       ,p_stepSequence => l_stepSequence
	       ,p_operator => l_operator
             ,p_operatorValue => l_operatorValue
             ,p_isDimension => l_isDimension
             ,p_byDimensionColumn => p_byDimensionColumn
             ,p_byDimensionValue => p_byDimensionValue
             ,x_stepSpecificString => l_stepSpecificString);


   --Add Step Predicate to Steps Predicate Table--
  IF (l_stepSpecificString IS NOT NULL) THEN
   z_dataStepPredicates(z_dataStepPredicatesCtr).DATA_DIM_COMPONENT_DEF_ID
                    := p_dataComponentDefId;
   z_dataStepPredicates(z_dataStepPredicatesCtr).STEP_SPECIFIC_PREDICATE
                    := l_stepSpecificString;
   z_dataStepPredicatesCtr := z_dataStepPredicatesCtr + 1;
  END IF;
  ------------------------------------------------

 END LOOP;

 CLOSE getDataCmpSteps;


 EXCEPTION

    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg := 'Procedure: generateDataPredicate: '||SQLERRM;
	 RAISE;

END generateDataPredicate;


/*************************************************************************

                             generateDimValuePredicate

 Private procedure which generates the predicate for a Dimension Component
 of type 'Value'.

*************************************************************************/

PROCEDURE generateDimValuePredicate(
   p_columnPrefix IN VARCHAR2,
   p_columnName IN VARCHAR2,
   p_value IN VARCHAR2,
   x_stepSpecificString OUT NOCOPY LONG) IS


l_stepSpecificString LONG;

BEGIN


  l_stepSpecificString := l_stepSpecificString
              ||G_OPEN
		  ||p_columnPrefix||p_columnName
		  ||G_SPACE||G_EQUAL||G_SPACE
		  ||p_value
              ||G_CLOSE;

  x_stepSpecificString := l_stepSpecificString;

 EXCEPTION

    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg := 'Procedure: generateDimValuePredicate: '||SQLERRM;
	 RAISE;

END generateDimValuePredicate;


/*************************************************************************

                             generateDimAttributePredicate

 Private procedure which generates the predicate for a Dimension Component
 of type 'Attribute'.

*************************************************************************/

PROCEDURE generateDimAttributePredicate(
   p_dimComponentDefId IN NUMBER,
   p_dimensionId IN NUMBER,
   p_columnPrefix IN VARCHAR2,
   p_columnName IN VARCHAR2,
   x_stepSpecificString OUT NOCOPY LONG) IS


CURSOR getDimAttrs IS
SELECT DISTINCT dim_attr_varchar_label
  FROM fem_cond_dim_cmp_dtl
WHERE  cond_dim_cmp_obj_def_id = p_dimComponentDefId;

l_stepSpecificString LONG;
l_attrString LONG;
l_attrColumnName VARCHAR2(30);
l_attrValueColumnName VARCHAR2(30);
l_attrTableName  VARCHAR2(30);
l_attrValue VARCHAR2(1000);
l_attrId NUMBER;
l_operator VARCHAR2(30);
l_attrVarcharLabel VARCHAR2(30);
l_attrDataType VARCHAR2(30);
l_dataType VARCHAR2(30);
l_canonicalDTMask varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';
l_attrDimId NUMBER;
l_count NUMBER := 0;
l_defaultVersionId NUMBER;

  l_value_set_id                  number;
  l_value_set_string              varchar2(2000);

CURSOR getDimAttrSteps IS
SELECT dim_attr_varchar_label,
       dim_attr_value
  FROM fem_cond_dim_cmp_dtl
WHERE  cond_dim_cmp_obj_def_id = p_dimComponentDefId
AND    dim_attr_varchar_label = l_attrVarcharLabel;

BEGIN

  -- Get dimension value set id for the Condition Components GVSC
  -- (returns null for non VSR dimensions)
  l_value_set_id :=
    getDimensionValueSetId (
      p_dimension_id               => p_dimensionId
      ,p_cond_component_obj_def_id => p_dimComponentDefId
    );

  -- Initialize Value Set String to NULL
  l_value_set_string := null;

  if (l_value_set_id is not null) then

    l_value_set_string := ' AND VALUE_SET_ID = '||l_value_set_id;

  end if;


OPEN getDimAttrs;

LOOP

FETCH getDimAttrs
INTO
l_attrVarcharLabel;

EXIT WHEN getDimAttrs%NOTFOUND;

l_operator := 'AND';

BEGIN

OPEN getDimAttrSteps;

LOOP

<<NEXT_DIM_ATTR_STEP>>

FETCH getDimAttrSteps
INTO l_attrVarcharLabel,
     l_attrValue;

EXIT WHEN getDimAttrSteps%NOTFOUND;

BEGIN

SELECT A.MEMBER_COL,
       B.ATTRIBUTE_VALUE_COLUMN_NAME,
       A.ATTRIBUTE_TABLE_NAME,
       B.ATTRIBUTE_ID,
       DECODE (SUBSTR(B.ATTRIBUTE_DATA_TYPE_CODE,1,4), 'DIME', 'DIMENSION', 'NUMB', 'NUMBER', 'DATE', 'DATE', 'STRING'),
       B.ATTRIBUTE_DIMENSION_ID,
       C.VERSION_ID
  INTO l_attrColumnName,
       l_attrValueColumnName,
       l_attrTableName,
       l_attrId,
       l_attrDataType,
       l_attrDimId,
       l_defaultVersionId
  FROM FEM_XDIM_DIMENSIONS A,
       FEM_DIM_ATTRIBUTES_VL B,
       FEM_DIM_ATTR_VERSIONS_VL C
 WHERE A.DIMENSION_ID =  p_dimensionId
   AND A.DIMENSION_ID = B.DIMENSION_ID
  -- AND B.ATTRIBUTE_ID = l_attrId;
   AND B.ATTRIBUTE_VARCHAR_LABEL = l_attrVarcharLabel
   AND B.ATTRIBUTE_ID = C.ATTRIBUTE_ID
   AND C.DEFAULT_VERSION_FLAG = 'Y';

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      --LOG INVALID VALUES
      GOTO NEXT_DIM_ATTR_STEP;

END;

  l_dataType := l_attrDataType;

  IF (l_attrDataType = 'DIMENSION') THEN
   l_dataType := getColumnDataType(p_synonymName => NULL,
                                p_columnName => NULL,
                                p_isDimension => TRUE,
                                p_dimensionId => l_attrDimId);
  END IF;

  IF (l_dataType = 'STRING') THEN
     l_attrValue := ''''||l_attrValue||'''';
  ELSIF (l_dataType = 'DATE') THEN
     l_attrValue := 'TO_DATE'||G_OPEN ||''''||l_attrValue||''''||','||''''||l_canonicalDTMask||''''||G_CLOSE;
  END IF;

IF (l_attrString IS NULL) THEN
    l_attrString := G_OPEN||p_columnPrefix||p_columnName
          ||G_SPACE||'IN'||G_SPACE
          ||G_OPEN
              ||' SELECT ' || l_attrColumnName
              ||' FROM ' || l_attrTableName
              ||' WHERE ATTRIBUTE_ID = ' || l_attrId
              ||' AND VERSION_ID = '|| l_defaultVersionId
              ||' AND '|| l_attrValueColumnName || ' = '||l_attrValue
              ||  l_value_set_string
          ||G_CLOSE||G_CLOSE;

ELSE
    l_attrString := l_attrString
              ||' '||l_operator||' '
              ||G_OPEN
          ||p_columnPrefix||p_columnName
          ||G_SPACE||'IN'||G_SPACE
          ||G_OPEN
              ||' SELECT ' || l_attrColumnName
              ||' FROM ' || l_attrTableName
              ||' WHERE ATTRIBUTE_ID = ' || l_attrId
              ||' AND VERSION_ID = '|| l_defaultVersionId
              ||' AND '|| l_attrValueColumnName || ' = '||l_attrValue
              ||  l_value_set_string
          ||G_CLOSE||G_CLOSE;
END IF;

l_operator := 'OR';
l_count := l_count + 1;
END LOOP;

IF (l_count > 1) THEN
  l_attrString := G_OPEN||l_attrString||G_CLOSE;
END IF;

l_count := 0;

IF (l_stepSpecificString IS NOT NULL) THEN
  l_stepSpecificString := l_stepSpecificString || ' AND '|| l_attrString;
ELSE
  l_stepSpecificString := l_attrString;
END IF;

l_attrString := NULL;

CLOSE getDimAttrSteps;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN;
      --LOG INVALID VALUES
      --PRINT('EXCEPTION');

END;

END LOOP;
  x_stepSpecificString := l_stepSpecificString;

 EXCEPTION

    WHEN OTHERS THEN
       z_errCode := -1;
       z_errMsg := 'Procedure: generateDimAttributePredicate: '||SQLERRM;
     RAISE;

END generateDimAttributePredicate;


/*************************************************************************

                             getHierValueSetId

*************************************************************************/
FUNCTION getHierValueSetId (
  p_dimension_id                  in number
  ,p_hierarchy_obj_id             in number
) RETURN number IS

  l_value_set_id                  number;
  l_value_set_required_flag       varchar2(1);

BEGIN

  l_value_set_id := null;

  select value_set_required_flag
  into l_value_set_required_flag
  from fem_xdim_dimensions
  where dimension_id = p_dimension_id;

  if (l_value_set_required_flag = 'Y') then

    select value_set_id
    into l_value_set_id
    from fem_hier_value_sets
    where hierarchy_obj_id = p_hierarchy_obj_id;

  end if;

  return l_value_set_id;

EXCEPTION

  when others then
    return l_value_set_id;

END getHierValueSetId;


/*************************************************************************

                             getDimensionValueSetId

*************************************************************************/
FUNCTION getDimensionValueSetId (
  p_dimension_id                  in number
  ,p_cond_component_obj_def_id    in number
) RETURN number IS

  l_value_set_id                  number;
  l_value_set_required_flag       varchar2(1);

BEGIN

  l_value_set_id := null;

  select value_set_required_flag
  into l_value_set_required_flag
  from fem_xdim_dimensions
  where dimension_id = p_dimension_id;

  if (l_value_set_required_flag = 'Y') then

    select value_set_id
    into l_value_set_id
    from fem_global_vs_combo_defs
    where dimension_id = p_dimension_id
    and global_vs_combo_id = (
      select obj.local_vs_combo_id
      from fem_object_catalog_b obj
      ,fem_object_definition_b def
      where obj.object_id = def.object_id
      and def.object_definition_id = p_cond_component_obj_def_id
    );

  end if;

  return l_value_set_id;

EXCEPTION

  when others then
    return l_value_set_id;

END getDimensionValueSetId;


/*============================================================================+
 | PROCEDURE
 |   getDimHierQuery
 |
 | DESCRIPTION
 |   Function for returning the query string for finding a list of nodes in an
 |   unflattened hierarchy definition based on the passed parameters.
 |
 |  SCOPE - PRIVATE
 +============================================================================*/

FUNCTION getDimHierQuery (
  p_hierarchy_table_name          in varchar2
  ,p_relation_code                in varchar2
  ,p_hierarchy_obj_def_id         in number
  ,p_node_list                    in varchar2
  ,p_value_set_id                 in number
  ,p_effective_date_varchar       in varchar2
) RETURN varchar2
IS

  l_query_string                  long;
  l_value_set_string              varchar2(2000);

BEGIN

  l_value_set_string := null;

  if (p_value_set_id is not null) then

    l_value_set_string :=
        ' AND PARENT_VALUE_SET_ID = '||p_value_set_id
      ||' AND CHILD_VALUE_SET_ID = '||p_value_set_id;

  end if;

  l_query_string :=
    case p_relation_code
      when 'DESC_OF' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' START WITH PARENT_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      ||' CONNECT BY PRIOR CHILD_ID = PARENT_ID'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      when 'LAST_DESC_OF' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE CHILD_ID NOT IN ('
      ||'   SELECT PARENT_ID'
      ||'   FROM '||p_hierarchy_table_name
      ||'   WHERE HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||'   AND PARENT_ID <> CHILD_ID'
      ||    l_value_set_string
      ||' )'
      ||' START WITH PARENT_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      ||' CONNECT BY PRIOR CHILD_ID = PARENT_ID'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      when 'NODE' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE CHILD_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||  l_value_set_string
      when 'NODE_AND_DESC' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE CHILD_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||  l_value_set_string
      ||' UNION ALL'
      ||' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' START WITH PARENT_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      ||' CONNECT BY PRIOR CHILD_ID = PARENT_ID'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      else '[Invalid Relation Code]'
    end;

  if (l_query_string = '[Invalid Relation Code]') then

    FND_MESSAGE.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_RELATION);
    FND_MESSAGE.set_token(TOKEN => G_RELATION_TOKEN, VALUE => p_relation_code, TRANSLATE => FALSE);
    FND_MSG_PUB.add_detail(p_message_type => 'W');

    return null;

  end if;

  return l_query_string;

END getDimHierQuery;


/*============================================================================+
 | PROCEDURE
 |   getDimFlatHierQuery
 |
 | DESCRIPTION
 |   Function for returning the query string for finding a list of nodes in a
 |   flattened hierarchy definition based on the passed parameters.
 |
 |  SCOPE - PRIVATE
 +============================================================================*/

FUNCTION getDimFlatHierQuery (
  p_hierarchy_table_name          in varchar2
  ,p_relation_code                in varchar2
  ,p_hierarchy_obj_def_id         in number
  ,p_node_list                    in varchar2
  ,p_value_set_id                 in number
) RETURN varchar2
IS

  l_query_string                  long;
  l_value_set_string              varchar2(2000);

BEGIN

  l_value_set_string := null;

  if (p_value_set_id is not null) then

    l_value_set_string :=
        ' AND PARENT_VALUE_SET_ID = '||p_value_set_id
      ||' AND CHILD_VALUE_SET_ID = '||p_value_set_id;

  end if;

  l_query_string :=
    case p_relation_code
      when 'DESC_OF' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE PARENT_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      when 'LAST_DESC_OF' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE PARENT_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      ||' AND CHILD_ID IN ('
      ||'   SELECT CHILD_ID'
      ||'   FROM '||p_hierarchy_table_name
      ||'   WHERE PARENT_ID = CHILD_ID'
      ||'   AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||'   AND PARENT_DEPTH_NUM > 1'
      ||    l_value_set_string
      ||' )'
      when 'NODE' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE CHILD_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_DEPTH_NUM = 1'
      ||  l_value_set_string
      when 'NODE_AND_DESC' then
        ' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE CHILD_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_DEPTH_NUM = 1'
      ||  l_value_set_string
      ||' UNION ALL'
      ||' SELECT CHILD_ID'
      ||' FROM '||p_hierarchy_table_name
      ||' WHERE PARENT_ID IN ('||p_node_list||')'
      ||' AND HIERARCHY_OBJ_DEF_ID = '||p_hierarchy_obj_def_id
      ||' AND PARENT_ID <> CHILD_ID'
      ||  l_value_set_string
      else '[Invalid Relation Code]'
    end;

  if (l_query_string = '[Invalid Relation Code]') then

    FND_MESSAGE.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_RELATION);
    FND_MESSAGE.set_token(TOKEN => G_RELATION_TOKEN, VALUE => p_relation_code, TRANSLATE => FALSE);
    FND_MSG_PUB.add_detail(p_message_type => 'W');

    return null;

  end if;

  return l_query_string;

END getDimFlatHierQuery;


/*************************************************************************

                             generateDimHierPredicate

 Private procedure which generates the predicate for a Dimension Component
 of type 'Hierarchy'.

*************************************************************************/

PROCEDURE generateDimHierPredicate(
  p_dimComponentDefId IN NUMBER,
  p_dimensionId IN NUMBER,
  p_columnPrefix IN VARCHAR2,
  p_columnName IN VARCHAR2,
  p_effectiveDate IN VARCHAR2,
  x_stepSpecificString OUT NOCOPY LONG
) IS

  cursor dim_hiers_csr is
    select distinct hierarchy_obj_id
    from fem_cond_dim_cmp_dtl
    where cond_dim_cmp_obj_def_id = p_dimComponentDefId;

  cursor dim_hier_steps_csr (p_hierarchy_obj_id in number) is
    select node
    ,relation_code
    from fem_cond_dim_cmp_dtl
    where cond_dim_cmp_obj_def_id = p_dimComponentDefId
    and hierarchy_obj_id = p_hierarchy_obj_id;

  -------------------
  -- Declare Types --
  -------------------
  type node_table is table of fem_cond_dim_cmp_dtl.node%type;
  type relation_code_table is table of fem_cond_dim_cmp_dtl.relation_code%type;

  -----------------------
  -- Declare variables --
  -----------------------
  l_node_tbl                      node_table;
  l_relation_code_tbl             relation_code_table;

  l_hierarchy_obj_id              number;
  l_hierarchy_obj_def_id          number;
  l_hierarchy_obj_name            varchar2(150);
  l_hierarchy_folder_name         varchar2(150);
  l_hierarchy_table_name          varchar2(30);

  --l_node_list                     varchar2(2000);
  --l_desc_list                     varchar2(2000);
  --l_last_desc_list                varchar2(2000);

  l_node_list                     varchar2(32767);
  l_desc_list                     varchar2(32767);
  l_last_desc_list                varchar2(32767);


  l_hier_query                    long;
  l_node_query                    long;
  l_desc_query                    long;
  l_last_desc_query               long;
  l_all_desc_query                long;

  l_flattened_flag                varchar2(1);
  l_flattened_code                varchar2(30);
  l_node_exists                   boolean;
  l_value_set_id                  number;

  l_stepSpecificString            long;

BEGIN

  -- Get hierarchy table name for the specified dimension
  begin
    select hierarchy_table_name
    INTO l_hierarchy_table_name
    from fem_xdim_dimensions
    where dimension_id = p_dimensionId;
  exception
    when no_data_found then
      -- LOG INVALID VALUES
      return;
  end;

  -- Get dimension value set id for the Condition Components GVSC
  -- (returns null for non VSR dimensions)
  l_value_set_id :=
    getDimensionValueSetId (
      p_dimension_id               => p_dimensionId
      ,p_cond_component_obj_def_id => p_dimComponentDefId
    );

  open dim_hiers_csr;

  loop <<NEXT_DIM_HIER>>

    -- Fetch dimension hierarchies one by one
    fetch dim_hiers_csr
    into l_hierarchy_obj_id;

    exit when dim_hiers_csr%NOTFOUND;

    -- Get hierarchy definition for the specified hierarchy object
    Fem_Rule_Set_Manager.Get_ValidDefinition_Pub(
      p_object_id             => l_hierarchy_obj_id
      ,p_rule_effective_date  => p_effectiveDate
      ,x_object_definition_id => l_hierarchy_obj_def_id
      ,x_err_Code             => z_errCode
      ,x_err_Msg              => z_errMsg
    );

    -- ERROR CHECK:  Halt processing on this hierarchy if valid hierarchy
    -- definition not found!!!!!
    if (z_errcode <> 0) then
      --Message has been logged in Fem_Rule_Set_Manager.Get_ValidDefinition_Pub
      goto NEXT_DIM_HIER;
    end if;

    -- Check if hierarchy will be flattened
    select flattened_rows_flag
    into l_flattened_flag
    from fem_hierarchies
    where hierarchy_obj_id = l_hierarchy_obj_id;

    if (l_flattened_flag = 'Y') then

      -- If hierarchy allows flattening, make sure flattening is complete on
      -- the hierarchy definition
      select flattened_rows_completion_code
      INTO l_flattened_code
      from fem_hier_definitions
      where hierarchy_obj_def_id = l_hierarchy_obj_def_id;

      if (l_flattened_code <> 'COMPLETED') then
        raise hier_flattened_exception;
      end if;

    end if;

    open dim_hier_steps_csr(l_hierarchy_obj_id);

    -- Fetch all dimension hierarchy steps (nodes and their relationships)
    -- at once.
    fetch dim_hier_steps_csr
    bulk collect into l_node_tbl
    ,l_relation_code_tbl;

    close dim_hier_steps_csr;

    -- Initialize all lists to null
    l_node_list := null;
    l_desc_list := null;
    l_last_desc_list := null;

    for i in 1..l_node_tbl.LAST loop

      -- Validate that node exists in the current hierarchy definition
      l_node_exists := validateHierarchyNode(
        p_tableName      => l_hierarchy_table_name
        ,p_node          => l_node_tbl(i)
        ,p_value_set_id  => l_value_set_id
        ,p_objId         => l_hierarchy_obj_id
        ,p_objDefId      => l_hierarchy_obj_def_id
        ,p_effectiveDate => p_effectiveDate
      );

      if (l_node_exists) then

        -- Make a list of all the condition nodes in a Cost Object hierarchy
        -- or condition nodes in a Normal hierarchy that have "Node" relationships
        -- (Node Only and Node and Descendants Of).
        if ( l_hierarchy_table_name = 'FEM_COST_OBJECTS_HIER'
          or l_relation_code_tbl(i) in ('NODE','NODE_AND_DESC') ) then

          if (l_node_list is null) then
            l_node_list := l_node_tbl(i);
          else
            l_node_list := l_node_list||','||l_node_tbl(i);
          end if;

        end if;

        -- Make a list of all the condition nodes in a Normal Hierarchy
        -- that have "Descendant" relationships (Descendants Of,
        -- Node and Descendants Of), and another list of condition nodes
        -- in a Normal Hierarchy that have "Last Descendant" relationships
        -- (Last Descendants Of).
        if (l_hierarchy_table_name <> 'FEM_COST_OBJECTS_HIER') then

          -- Node list with "Descendant" relationships
          if (l_relation_code_tbl(i) in ('DESC_OF','NODE_AND_DESC')) then

            if (l_desc_list is null) then
              l_desc_list := l_node_tbl(i);
            else
              l_desc_list := l_desc_list||','||l_node_tbl(i);
            end if;

          -- Node list with "Last Descendant" relationships
          elsif (l_relation_code_tbl(i) = 'LAST_DESC_OF') then

            if (l_last_desc_list is null) then
              l_last_desc_list := l_node_tbl(i);
            else
              l_last_desc_list := l_last_desc_list||','||l_node_tbl(i);
            end if;

          end if;

        end if;

      else -- Node does not exist

        --IF (z_loggingTurnedOn = 'Y') THEN

        FEM_UTILS.GetObjNameandFolderUsingDef(
          p_obj_def_id   => l_hierarchy_obj_def_id
          ,x_object_name => l_hierarchy_obj_name
          ,x_folder_name => l_hierarchy_folder_name
        );

        fnd_message.set_name(APPLICATION => FEM_APP, NAME => G_INVALID_NODE);
        fnd_message.set_token(TOKEN => G_NODE_TOKEN, VALUE => l_node_tbl(i), TRANSLATE => FALSE);
        fnd_message.set_token(TOKEN => G_HIERARCHY_TOKEN, VALUE => l_hierarchy_obj_name, TRANSLATE => FALSE);
        fnd_msg_pub.add_detail(p_message_type => 'W');

        /*
        FEM_ENGINES_PKG.PUT_MESSAGE(
          p_app_name => FEM_APP,
          p_msg_name => G_INVALID_NODE,
          p_token1 => G_NODE_TOKEN,
          p_value1 => l_node_tbl(i),
          p_token2 => G_HIERARCHY_TOKEN,
          p_value2 => l_hierarchy_obj_name);
        */
        --   END IF;

      end if;

    end loop;

    -- Get the query for "Descendant" relationships
    if (l_desc_list is not null) then

      if (l_flattened_flag = 'Y') then

        l_desc_query := getDimFlatHierQuery (
          p_hierarchy_table_name    => l_hierarchy_table_name
          ,p_relation_code          => 'DESC_OF'
          ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
          ,p_node_list              => l_desc_list
          ,p_value_set_id           => l_value_set_id
        );

      else

        l_desc_query := getDimHierQuery (
          p_hierarchy_table_name    => l_hierarchy_table_name
          ,p_relation_code          => 'DESC_OF'
          ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
          ,p_node_list              => l_desc_list
          ,p_value_set_id           => l_value_set_id
          ,p_effective_date_varchar => p_effectiveDate
        );

      end if;

    end if;

    -- Get the query for "Last Descendant" relationships
    if (l_last_desc_list is not null) then

      if (l_flattened_flag = 'Y') then

        l_last_desc_query := getDimFlatHierQuery (
          p_hierarchy_table_name    => l_hierarchy_table_name
          ,p_relation_code          => 'LAST_DESC_OF'
          ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
          ,p_node_list              => l_last_desc_list
          ,p_value_set_id           => l_value_set_id
        );

      else

        l_last_desc_query := getDimHierQuery (
          p_hierarchy_table_name    => l_hierarchy_table_name
          ,p_relation_code          => 'LAST_DESC_OF'
          ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
          ,p_node_list              => l_last_desc_list
          ,p_value_set_id           => l_value_set_id
          ,p_effective_date_varchar => p_effectiveDate
        );

      end if;

    end if;

    -- Combine both "Descendant" and "Last Descendant" queries into one
    -- "All Descendant" query.
    if (l_desc_query is not null) then

      l_all_desc_query := l_desc_query;

      if (l_last_desc_query is not null) then
        l_all_desc_query := l_all_desc_query||' UNION ALL '||l_last_desc_query;
      end if;

    elsif (l_last_desc_query is not null) then

      l_all_desc_query := l_last_desc_query;

    end if;

    -- Create the hierarchy query by now combining the "Node" component
    -- and the "All Descendents" component.
    if (l_all_desc_query is not null) then

      -- Get the query for "Node" relationships if there is a valid
      -- "Node" list.
      if (l_node_list is not null) then

        if (l_flattened_flag = 'Y') then

          l_node_query := getDimFlatHierQuery (
            p_hierarchy_table_name    => l_hierarchy_table_name
            ,p_relation_code          => 'NODE'
            ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
            ,p_node_list              => l_node_list
            ,p_value_set_id           => l_value_set_id
          );

        else

          l_node_query := getDimHierQuery (
            p_hierarchy_table_name    => l_hierarchy_table_name
            ,p_relation_code          => 'NODE'
            ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
            ,p_node_list              => l_node_list
            ,p_value_set_id           => l_value_set_id
            ,p_effective_date_varchar => p_effectiveDate
          );

        end if;

        -- Concatenate the "Node" query with the "All Descendants" query
        -- to from a single query.
        l_hier_query := l_node_query||' UNION ALL '||l_all_desc_query;

      else

        -- Otherwise just use the "All Descendents" query.
        l_hier_query := l_all_desc_query;

      end if;

    elsif (l_node_list is not null) then

      -- Use the Node List directly as there is no "All Descendants" query
      l_hier_query := l_node_list;

    else

      -- If neither "Node" and "All Descendant" components are specified,
      -- then skip to the next hierarchy.
      goto NEXT_DIM_HIER;

    end if;

    l_hier_query := p_columnPrefix||p_columnName||' IN ('||l_hier_query||')';

    -- Add the hierarchy query to the Step Where Clause string.
    if (l_stepSpecificString is not null) then
      l_stepSpecificString := l_stepSpecificString||' AND '|| l_hier_query;
    else
      l_stepSpecificString := l_hier_query ;
    end if;

  end loop;

  close dim_hiers_csr;

  -- Set the Step where clause string value to be returned.
  x_stepSpecificString := l_stepSpecificString;

END generateDimHierPredicate;



/*************************************************************************

                             generateDimPredicate

 This procedure generates predicates for all the Dimension Components of a
 Condition and populates the z_dimStepPredicates PLSQL table with the
 individual Dimension Component predicates

*************************************************************************/

PROCEDURE generateDimPredicate(p_dimComponentDefId IN NUMBER
,p_factTableName IN VARCHAR2
,p_tableAlias IN VARCHAR2
,p_componentFlag IN VARCHAR2
,p_effectiveDate IN VARCHAR2
,p_byDimensionId IN NUMBER
,p_byDimensionValue IN VARCHAR2) IS


l_columnName VARCHAR2(30);
l_columnPrefix VARCHAR2(30);
l_stepType  VARCHAR2(30);
l_stepSequence NUMBER;
l_operator VARCHAR2(30);
l_dimCompType VARCHAR2(1);
l_dimensionColumn VARCHAR2(30);
l_dimensionId NUMBER;
l_dimensionValue VARCHAR2(40);
l_byDimensionValue VARCHAR2(40) := p_byDimensionValue;

l_stepSpecificString LONG;

l_dataType  ALL_TAB_COLUMNS.DATA_TYPE%TYPE;
l_canonicalDTMask varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';
l_tokenValue VARCHAR2(30);



BEGIN
    BEGIN
        SELECT dim_comp_type, dim_column, dim_id, value
        INTO l_dimCompType, l_dimensionColumn, l_dimensionId, l_dimensionValue
        FROM fem_cond_dim_components
        WHERE cond_dim_cmp_obj_def_id = p_dimComponentDefId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
 	        RAISE INVALID_DIM_COMP_EXCEPTION;
    END;

    IF p_factTableName IS NOT NULL THEN
      IF NOT columnNameIsValid(p_tableName => p_factTableName
                              ,p_columnName => l_dimensionColumn) THEN

        -- IF (z_loggingTurnedOn = 'Y') THEN

         fnd_message.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_DIMENSION);
         fnd_message.set_token(TOKEN => G_COLUMN_TOKEN, VALUE => l_dimensionColumn, TRANSLATE => FALSE);
         fnd_message.set_token(TOKEN => G_TABLE_TOKEN, VALUE =>p_factTableName,TRANSLATE => FALSE);
         fnd_msg_pub.add_detail(p_message_type => 'W');

          /* FEM_ENGINES_PKG.PUT_MESSAGE(
            p_app_name => FEM_APP,
            p_msg_name => G_INVALID_DIMENSION,
            p_token1 => G_COLUMN_TOKEN,
            p_value1 => l_dimensionColumn,
            p_token2 => G_TABLE_TOKEN,
            p_value2 => p_factTableName);*/
          --  p_token3 => 'FND_MESSAGE_TYPE',
          --  p_value3 => 'W');

       -- END IF;

         RETURN;

      END IF;
      IF (p_factTableName = 'FEM_ACTIVITIES' OR p_factTableName = 'FEM_COST_OBJECTS') THEN
         IF NOT compDimColumnNameIsValid(p_tableName => p_factTableName
                                        ,p_columnName => l_dimensionColumn) THEN

            l_tokenValue :=
               CASE p_factTableName
	            WHEN 'FEM_ACTIVITIES'  THEN 'ACTIVITY_ID'
	            WHEN 'FEM_COST_OBJECTS'  THEN 'COST_OBJECT_ID'
               END;

            fnd_message.set_name(APPLICATION => FEM_APP,NAME => G_INVALID_COMP_DIMENSION);
            fnd_message.set_token(TOKEN => G_COLUMN_TOKEN, VALUE => l_dimensionColumn, TRANSLATE => FALSE);
            fnd_message.set_token(TOKEN => G_COMP_DIM_TOKEN, VALUE =>l_tokenValue,TRANSLATE => FALSE);
            fnd_msg_pub.add_detail(p_message_type => 'W');

            RETURN;
         END IF;
      END IF;

    END IF;

 IF (p_factTableName IS NULL) THEN
    l_columnPrefix := NULL;
 ELSE
   IF (p_tableAlias IS NULL) THEN
      l_columnPrefix := NULL;
   ELSE
      l_columnPrefix := p_tableAlias||G_PERIOD;
   END IF;
 END IF;

 l_dataType := getColumnDataType(p_synonymName => NULL,
                                p_columnName => NULL,
                                p_isDimension => TRUE,
                                p_dimensionId => l_dimensionId);
--Test Value (V) case--
   IF (l_dimCompType = 'V') THEN

       /*** LOCAL MAPPING CONDITION Bug 4118584****/

       IF (l_dimensionValue = '%') THEN
          --RESULT WILL RETURN ALL VALUES SO JUST NO NEED TO PROCESS COMPONENT.
          RETURN;
       END IF;


       IF (l_dataType = 'STRING') THEN
         l_dimensionValue := ''''||l_dimensionValue||'''';
       ELSIF (l_dataType = 'DATE') THEN
         l_dimensionValue := 'TO_DATE'||G_OPEN ||''''||l_dimensionValue||''''||','||''''||l_canonicalDTMask||''''||G_CLOSE;
       END IF;


      generateDimValuePredicate(
      p_columnPrefix => l_columnPrefix,
      p_columnName => l_dimensionColumn,
      p_value => l_dimensionValue,
      x_stepSpecificString => l_stepSpecificString);

ELSIF (l_dimCompType = 'A') THEN
           generateDimAttributePredicate(
           p_dimComponentDefId => p_dimComponentDefId,
           p_dimensionId => l_dimensionId,
           p_columnPrefix => l_columnPrefix,
           p_columnName => l_dimensionColumn,
           x_stepSpecificString => l_stepSpecificString);
ELSIF  (l_dimCompType = 'H') THEN
           generateDimHierPredicate(
           p_dimComponentDefId => p_dimComponentDefId,
           p_dimensionId => l_dimensionId,
           p_columnPrefix => l_columnPrefix,
           p_columnName => l_dimensionColumn,
           p_effectiveDate => p_effectiveDate,
           x_stepSpecificString => l_stepSpecificString);
  END IF;

--MAPPING BY DIMENSION TYPE SUPPORT... MUST USE APPEND OR CONDITION TO PREDICATE
 IF (p_byDimensionId = l_dimensionId) THEN

       IF (l_dataType = 'STRING') THEN
         l_byDimensionValue := ''''||l_byDimensionValue ||'''';
       ELSIF (l_dataType = 'DATE') THEN
         l_byDimensionValue  := 'TO_DATE'||G_OPEN ||''''||l_byDimensionValue
                                 ||''''||','||''''||l_canonicalDTMask||''''||G_CLOSE;
       END IF;

   l_stepSpecificString := G_OPEN||l_stepSpecificString||G_SPACE||G_OR||G_SPACE
                           ||G_OPEN||l_columnPrefix||l_dimensionColumn||G_SPACE||G_EQUAL||G_SPACE||l_byDimensionValue
                           ||G_CLOSE||G_CLOSE;
 END IF;
--END MAPPING BY DIMENSION TYPE SUPPORT

   --Add Step Predicate to Steps Predicate Table--
  IF (l_stepSpecificString IS NOT NULL) THEN
   z_dimStepPredicates(z_dimStepPredicatesCtr).DATA_DIM_COMPONENT_DEF_ID
                       := p_dimComponentDefId;
   z_dimStepPredicates(z_dimStepPredicatesCtr).STEP_SPECIFIC_PREDICATE
                    := l_stepSpecificString;
   z_dimStepPredicatesCtr:= z_dimStepPredicatesCtr + 1;
  END IF;

  ------------------------------------------------

END generateDimPredicate;


/*************************************************************************

                             GENERATE_CONDITION_PREDICATE

Procecure used to generate a predicate (where clause) for a given condition
object based on the effective date.  The predicate can be generated for
either a dimension component or a data componenet, or both.
*************************************************************************/
PROCEDURE GENERATE_CONDITION_PREDICATE(
   p_api_version     IN NUMBER     DEFAULT g_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT g_false,
   p_commit          IN VARCHAR2   DEFAULT g_false,
   p_encoded         IN VARCHAR2   DEFAULT g_true,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_input_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_display_predicate IN VARCHAR2,
   p_return_predicate_type IN VARCHAR2,
   p_logging_turned_on IN VARCHAR2,
   p_by_dimension_column IN VARCHAR2,
   p_by_dimension_id  IN NUMBER,
   p_by_dimension_value IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_predicate_string OUT NOCOPY LONG) IS


x EXCEPTION;
l_conditionObjDefId NUMBER;
l_conditionObjType  VARCHAR2(30);
l_ruleEffectiveDate DATE;
l_tableAlias VARCHAR2(30);

l_sqlStmt LONG;
l_numOfBindVariables NUMBER;

comp_cv   COMP_CUR_TYPE;

l_componentObjId       NUMBER;
l_componentFlag        VARCHAR2(1);
l_componentObjDefId    NUMBER;
l_componentDimColumn   VARCHAR2(30);
l_componentTypeCode    VARCHAR2(30);
l_factTableOnDataComp  VARCHAR2(30);
l_hierarchyObjId       NUMBER;
l_componentDimId       NUMBER;
l_componentDimValue    VARCHAR2(30);
l_componentCounter     NUMBER;

l_dataPredicate LONG;
l_dimensionPredicate  LONG;

BEGIN

x_return_status  := g_success;

FND_MSG_PUB.Delete_Msg();

 /*----Reinitializing PLSQL Tables----------*/
   /*--Data Step Predicate table--*/
  z_dataStepPredicates.DELETE;
  z_dataStepPredicatesCtr := 0;

   /*--Invalid Data Component Table--*/
  z_invalidDataComponents.DELETE;
  z_invalidDataComponentsCtr := 0;

  /*--Dimension Step Predicate table--*/
  z_dimStepPredicates.DELETE;
  z_dimStepPredicatesCtr:= 0;

  /*--Invalid Dimension Component Table--*/
  z_invalidDimComponents.DELETE;
  z_invalidDimComponentsCtr := 0;

 /*-----------------------------------------*/

  x_predicate_string := '';

/*--Setting Global Variables--*/
  z_conditionObjectId := p_condition_obj_id;
  z_ruleEffectiveDate := p_rule_effective_date;
  z_factTableName := p_input_fact_table_name;
  z_tableAlias := p_table_alias;
  z_returnPredicateType := p_return_predicate_type;
  z_displayPredicate := p_display_predicate;
  z_loggingTurnedOn := p_logging_turned_on;
/*----------------------------*/

/*----- Get Condition Obj Def ID-----*/

  Fem_Rule_Set_Manager.Get_ValidDefinition_Pub(p_condition_obj_id
                                              ,p_rule_effective_date
                                              ,l_conditionObjDefId
                                              ,x_err_Code => z_errCode
					                ,x_err_Msg => z_errMsg);


   IF (z_errCode <> 0) THEN
     RAISE NO_CONDITION_EXCEPTION;
   END IF;

   z_conditionObjectDefId := l_conditionObjDefId;

    FEM_UTILS.GetObjNameandFolderUsingDef
                       (p_Obj_Def_ID => l_conditionObjDefId
                       ,x_Object_Name => z_conditionObjectDefName
                       ,x_Folder_Name => z_conditionObjectFolderName);

/*----------------------------------*/

/*----If Calling Module is not Conditions UI
      validate Table Name-------------------*/
 IF (p_input_fact_table_name IS NULL) THEN
  IF (p_display_predicate = 'N') THEN
    RAISE NO_FACT_TABLE_EXCEPTION;
  END IF;
 ELSIF (p_input_fact_table_name IS NOT NULL) THEN
   IF NOT tableNameIsValid(p_input_fact_table_name) THEN
     RAISE INVALID_FACT_TABLE_EXCEPTION;
   END IF;
 END IF;
/*-------------------------------------------*/

/* Get Condition Object Type */
  --l_conditionObjType := getObjectType(p_condition_obj_id);

/* Get Rule Effective Date in DATE format */
  --l_ruleEffectiveDate:= FND_DATE.CANONICAL_TO_DATE(p_rule_effective_date);


/* Get Valid Component SQL */
  l_sqlStmt:=  getValidComponentSql(
     p_returnPredicateType => p_return_predicate_type,
     p_displayPredicate => p_display_predicate,
     p_inputFactTable => p_input_fact_table_name,
     x_numOfBindVariables  => l_numOfBindVariables);


/* Open Cursor */
   openConditionCursor(
      comp_cv,
      l_sqlStmt,
      l_numOfBindVariables,
      l_conditionObjDefId,
	p_display_predicate,
	p_input_fact_table_name);

   l_componentCounter := 0;

   LOOP

       <<PROCESS_NEXT_DATA_DIM_CMP>>

     FETCH comp_cv into
      l_componentObjId
     ,l_componentFlag
     ,l_componentObjDefId
     ,l_componentTypeCode
     ,l_factTableOnDataComp;


     EXIT WHEN comp_cv%NOTFOUND;

    l_componentCounter := l_componentCounter + 1;

    FEM_UTILS.GetObjNameandFolderUsingDef
                       (p_Obj_Def_ID => l_componentObjDefId
                       ,x_Object_Name => z_componentObjectDefName
                       ,x_Folder_Name => z_componentObjectFolderName);

     /*--Validate every Table on every Data Component
         if Calling Module is Conditions UI----*/
      /*-- IF (p_display_predicate = 'Y') THEN
         IF NOT tableNameIsValid(l_factTableOnDataComp) THEN
          --Skipping this Table,Comp Def as Table is Invalid--
        -- IF (z_loggingTurnedOn = 'Y') THEN
          trackInvalidDataComponents
                  (p_invalidDataCmpDefId => l_componentObjDefId
                  ,p_invalidTableName => l_factTableOnDataComp
                  ,p_invalidColumnName => NULL
                  ,p_invalidSecondColumnName => NULL) ;
        -- END IF;

         GOTO PROCESS_NEXT_DATA_DIM_CMP;
        END IF;
      END IF;--*/
     /*----------------------------------------------------------*/

         IF (l_componentFlag = 'T') THEN
            IF (p_display_predicate = 'Y') THEN
               l_tableAlias := l_factTableOnDataComp;
            ELSE
               l_tableAlias := p_table_alias;
            END IF;
            generateDataPredicate(
	        p_dataComponentDefId => l_componentObjDefId
		  ,p_factTableName => l_factTableOnDataComp
              ,p_tableAlias => l_tableAlias
              ,p_byDimensionColumn => p_by_dimension_column
              ,p_byDimensionValue => p_by_dimension_value);
         ELSE
           generateDimPredicate(
		 p_dimComponentDefId => l_componentObjDefId
             ,p_factTableName => p_input_fact_table_name
             ,p_tableAlias => p_table_alias
             ,p_componentFlag => l_componentFlag
             ,p_effectiveDate => p_rule_effective_date
             ,p_byDimensionId => p_by_dimension_id
             ,p_byDimensionValue => p_by_dimension_value);
         END IF;

   END LOOP;

   CLOSE comp_cv;


   IF (l_componentCounter = 0) THEN
     RAISE NO_COMPONENTS_EXCEPTION;
   END IF;

   ----Generate final Data predicate string---------

  IF (z_dataStepPredicates.COUNT > 0) THEN
   FOR i IN z_dataStepPredicates.FIRST..z_dataStepPredicates.LAST LOOP
    IF (z_dataStepPredicates(i).STEP_SPECIFIC_PREDICATE IS NOT NULL) THEN
      l_dataPredicate := l_dataPredicate
  			||z_dataStepPredicates(i).Step_Specific_Predicate;
      IF (i < z_dataStepPredicates.LAST ) THEN
       l_dataPredicate := l_dataPredicate ||G_SPACE||G_AND||G_SPACE;
      END IF;
    END IF;

   END LOOP;
    --l_dataPredicate := G_OPEN||l_dataPredicate ||G_CLOSE;
  END IF;
  --------------------------------------------------
   ----Generate final Dim predicate string---------

  IF (z_dimStepPredicates.COUNT > 0) THEN

   FOR i IN z_dimStepPredicates.FIRST..z_dimStepPredicates.LAST LOOP
    IF (z_dimStepPredicates(i).Step_Specific_Predicate IS NOT NULL) THEN
      l_dimensionPredicate := l_dimensionPredicate
			||z_dimStepPredicates(i).Step_Specific_Predicate;
      IF (i < z_dimStepPredicates.LAST ) THEN
       l_dimensionPredicate := l_dimensionPredicate ||G_SPACE||G_AND||G_SPACE;
      END IF;
    END IF;

   END LOOP;
   -- l_dimensionPredicate := G_OPEN||l_dimensionPredicate ||G_CLOSE;
  END IF;
  --------------------------------------------------
   /*---Generating Final Predicate---*/

  IF (p_return_predicate_type = 'DATA') THEN
   x_predicate_string := l_dataPredicate ;
  ELSIF (p_return_predicate_type = 'DIM') THEN
   x_predicate_string := l_dimensionPredicate;

  ELSIF (p_return_predicate_type = 'BOTH') THEN
   IF ((z_dataStepPredicates.COUNT > 0) AND
       (z_dimStepPredicates.COUNT > 0)) THEN
      x_predicate_string := G_OPEN||l_dataPredicate||G_CLOSE
                            ||G_SPACE||G_AND||G_SPACE||
			    G_OPEN||l_dimensionPredicate||G_CLOSE;

   ELSIF ((z_dataStepPredicates.COUNT > 0) AND
          (z_dimStepPredicates.COUNT = 0)) THEN
      x_predicate_string := l_dataPredicate;
   ELSIF ((z_dataStepPredicates.COUNT = 0) AND
          (z_dimStepPredicates.COUNT > 0)) THEN
      x_predicate_string := l_dimensionPredicate;
   ELSIF ((z_dataStepPredicates.COUNT = 0) AND
          (z_dimStepPredicates.COUNT = 0)) THEN
      RAISE NO_VALID_COMPONENTS_EXCEPTION;
   END IF;
  END IF;
  --------------------------------------------------
  /*--Logging Predicate string to Concurrent Manager output ---*/
  /*--file for Condition UI --*/

  IF (p_display_predicate = 'Y') THEN
     logPredicateToOutputFile(
        p_conditionObjId => p_condition_obj_id,
	  p_returnPredicateType => p_return_predicate_type);
  END IF;
  --------------------------------------------------

   -- x_err_code := z_errCode;
    --x_err_msg  := z_errMsg ;

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);


	EXCEPTION
        WHEN NO_CONDITION_EXCEPTION THEN
           FEM_ENGINES_PKG.PUT_MESSAGE(
             p_app_name => FEM_APP,
             p_msg_name => G_NO_VERSION,
             p_token1 => G_CONDITION_TOKEN,
             p_value1 => p_condition_obj_id,
             p_token2 => G_EFFECTIVE_DATE_TOKEN,
             p_value2 => p_rule_effective_date);
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;
           RETURN;

        WHEN INVALID_FACT_TABLE_EXCEPTION THEN


           FEM_ENGINES_PKG.PUT_MESSAGE(
              p_app_name => FEM_APP,
              p_msg_name => G_INVALID_TABLE,
              p_token1 => G_TABLE_TOKEN,
              p_value1 => p_input_fact_table_name);

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;
             RETURN;

         WHEN NO_FACT_TABLE_EXCEPTION THEN

            FEM_ENGINES_PKG.PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => G_NO_TABLE);

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;

            RETURN;

         WHEN HIER_FLATTENED_EXCEPTION THEN
            FEM_ENGINES_PKG. PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => G_HIER_FLATTENED);

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;
            RETURN;

         WHEN NO_VALID_COMPONENTS_EXCEPTION THEN

            FEM_ENGINES_PKG. PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => G_NO_VALID_COMPS);

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;

            RETURN;

         WHEN INVALID_DIM_COMP_EXCEPTION THEN

            FEM_ENGINES_PKG. PUT_MESSAGE(
                p_app_name => FEM_APP,
                p_msg_name => G_INVALID_DIM_COMPONENT,
                p_token1 => G_CONDITION_TOKEN,
                p_value1 => z_conditionObjectDefName,
                p_token2 => G_COMPONENT_TOKEN,
                p_value2 => z_componentObjectDefName);

            FND_MSG_PUB.Count_and_Get(
                p_encoded => p_encoded,
                p_count => x_msg_count,
                p_data => x_msg_data);

            x_return_status := g_unexp;

            RETURN;

         WHEN NO_COMPONENTS_EXCEPTION THEN
            FEM_ENGINES_PKG. PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => G_NO_COMPONENTS);

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;

            RETURN;

	   WHEN OTHERS THEN
	     -- x_err_code := SQLCODE;
        --    x_err_msg := G_UNHANDLED_EXCEPTION;
            --FEM_ENGINES_PKG.USER_MESSAGE(G_UNHANDLED_EXCEPTION);
            FEM_ENGINES_PKG. PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => G_UNHANDLED_EXCEPTION,
               p_token1 => G_SQL_ERR_TOKEN,
               p_value1 => SQLERRM);

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := g_error;

	      RETURN;



END GENERATE_CONDITION_PREDICATE;




/*************************************************************************

                             DISPLAY_CONDITION_PREDICATE

 Wrapper routine for calling the Condition API as a Concurrent Request.
 Used by the Conditions User Interface to log the predicate to an output
 file.

*************************************************************************/

PROCEDURE DISPLAY_CONDITION_PREDICATE(
   x_err_code OUT NOCOPY NUMBER,
   x_err_msg OUT NOCOPY VARCHAR2,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2) IS

l_predicate_string LONG;
l_return_status VARCHAR2(100);

l_msg_count        NUMBER;
l_msg_data         VARCHAR2(4000);
l_msg_out          NUMBER;
l_message          VARCHAR2(4000);
l_concurrent_status BOOLEAN;

BEGIN
  /*GENERATE_CONDITION_PREDICATE(
     x_err_code => x_err_code,
     x_err_msg => x_err_msg,
     p_condition_obj_id => p_condition_obj_id,
     p_rule_effective_date => p_rule_effective_date,
     p_input_fact_table_name => NULL,
     p_table_alias => NULL,
     p_display_predicate => 'Y',
     p_return_predicate_type => 'BOTH',
     p_logging_turned_on => 'Y',
     x_predicate_string => l_predicateString);*/


GENERATE_CONDITION_PREDICATE(
     p_api_version => g_api_version,
     p_init_msg_list => g_false,
     p_commit => g_false,
     p_encoded => g_true,
     p_condition_obj_id => p_condition_obj_id,
     p_rule_effective_date => p_rule_effective_date,
     p_input_fact_table_name => NULL,
     p_table_alias => NULL,
     p_display_predicate => 'Y',
     p_return_predicate_type => 'BOTH',
     p_logging_turned_on => 'Y',
     p_by_dimension_column => NULL,
     p_by_dimension_id => NULL,
     p_by_dimension_value => NULL,
     x_return_status => l_return_status,
     x_msg_count => l_msg_count,
     x_msg_data => x_err_msg,
     x_predicate_string => l_predicate_string);


l_msg_data := x_err_msg;

IF (l_msg_count = 1)
THEN
   FND_MESSAGE.Set_Encoded(l_msg_data);
   l_message := FND_MESSAGE.Get;

   FEM_ENGINES_PKG.User_Message(
     p_msg_text => l_message);


ELSIF (l_msg_count > 1)
THEN
   FOR i IN 1..l_msg_count
   LOOP
      FND_MSG_PUB.Get(
      p_msg_index => i,
      p_encoded =>  FND_API.G_FALSE,
      p_data => l_message,
      p_msg_index_out => l_msg_out);

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => l_message);

   END LOOP;
END IF;

   FND_MSG_PUB.Initialize;

IF (l_return_status = g_error) THEN
   l_concurrent_status := fnd_concurrent.set_completion_status('ERROR',null);
ELSE
   l_concurrent_status := fnd_concurrent.set_completion_status('NORMAL',null);
END IF;

END DISPLAY_CONDITION_PREDICATE;


/*************************************************************************

                             GENERATE_CONDITION_PREDICATE

Procecure used to generate a predicate (where clause) for a given condition
object based on the effective date.  The predicate can be generated for
either a dimension component or a data componenet, or both.
*************************************************************************/

PROCEDURE GENERATE_CONDITION_PREDICATE(
   x_err_code OUT NOCOPY NUMBER,
   x_err_msg OUT NOCOPY VARCHAR2,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_input_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_display_predicate IN VARCHAR2,
   p_return_predicate_type IN VARCHAR2,
   p_logging_turned_on IN VARCHAR2,
   x_predicate_string OUT NOCOPY LONG) IS

x EXCEPTION;
l_conditionObjDefId NUMBER;
l_conditionObjType  VARCHAR2(30);
l_ruleEffectiveDate DATE;
l_tableAlias VARCHAR2(30);

l_sqlStmt LONG;
l_numOfBindVariables NUMBER;

comp_cv   COMP_CUR_TYPE;

l_componentObjId       NUMBER;
l_componentFlag        VARCHAR2(1);
l_componentObjDefId    NUMBER;
l_componentDimColumn   VARCHAR2(30);
l_componentTypeCode    VARCHAR2(30);
l_factTableOnDataComp  VARCHAR2(30);
l_hierarchyObjId       NUMBER;
l_componentDimId       NUMBER;
l_componentDimValue    VARCHAR2(30);
l_componentCounter     NUMBER;

l_dataPredicate LONG;
l_dimensionPredicate  LONG;

BEGIN

 /*----Reinitializing PLSQL Tables----------*/
   /*--Data Step Predicate table--*/
  z_dataStepPredicates.DELETE;
  z_dataStepPredicatesCtr := 0;

   /*--Invalid Data Component Table--*/
  z_invalidDataComponents.DELETE;
  z_invalidDataComponentsCtr := 0;

  /*--Dimension Step Predicate table--*/
  z_dimStepPredicates.DELETE;
  z_dimStepPredicatesCtr:= 0;

  /*--Invalid Dimension Component Table--*/
  z_invalidDimComponents.DELETE;
  z_invalidDimComponentsCtr := 0;

 /*-----------------------------------------*/

  x_predicate_string := '';

/*--Setting Global Variables--*/
  z_conditionObjectId := p_condition_obj_id;
  z_ruleEffectiveDate := p_rule_effective_date;
  z_factTableName := p_input_fact_table_name;
  z_tableAlias := p_table_alias;
  z_returnPredicateType := p_return_predicate_type;
  z_displayPredicate := p_display_predicate;
  z_loggingTurnedOn := p_logging_turned_on;
/*----------------------------*/

/*----- Get Condition Obj Def ID-----*/

  Fem_Rule_Set_Manager.Get_ValidDefinition_Pub(p_condition_obj_id
                                              ,p_rule_effective_date
                                              ,l_conditionObjDefId
                                              ,x_err_Code => z_errCode
					                ,x_err_Msg => z_errMsg);


   IF (z_errCode <> 0) THEN
     RAISE NO_CONDITION_EXCEPTION;
   END IF;


   z_conditionObjectDefId := l_conditionObjDefId;

    FEM_UTILS.GetObjNameandFolderUsingDef
                       (p_Obj_Def_ID => l_conditionObjDefId
                       ,x_Object_Name => z_conditionObjectDefName
                       ,x_Folder_Name => z_conditionObjectFolderName);

/*----------------------------------*/

/*----If Calling Module is not Conditions UI
      validate Table Name-------------------*/
 IF (p_input_fact_table_name IS NULL) THEN
  IF (p_display_predicate = 'N') THEN
    RAISE NO_FACT_TABLE_EXCEPTION;
  END IF;
 ELSIF (p_input_fact_table_name IS NOT NULL) THEN
   IF NOT tableNameIsValid(p_input_fact_table_name) THEN
     RAISE INVALID_FACT_TABLE_EXCEPTION;
   END IF;
 END IF;
/*-------------------------------------------*/

/* Get Condition Object Type */
  --l_conditionObjType := getObjectType(p_condition_obj_id);

/* Get Rule Effective Date in DATE format */
  --l_ruleEffectiveDate:= FND_DATE.CANONICAL_TO_DATE(p_rule_effective_date);


/* Get Valid Component SQL */
  l_sqlStmt:=  getValidComponentSql(
     p_returnPredicateType => p_return_predicate_type,
     p_displayPredicate => p_display_predicate,
     p_inputFactTable => p_input_fact_table_name,
     x_numOfBindVariables  => l_numOfBindVariables);


/* Open Cursor */
   openConditionCursor(
      comp_cv,
      l_sqlStmt,
      l_numOfBindVariables,
      l_conditionObjDefId,
	p_display_predicate,
	p_input_fact_table_name);

   l_componentCounter := 0;

   LOOP

       <<PROCESS_NEXT_DATA_DIM_CMP>>

     FETCH comp_cv into
      l_componentObjId
     ,l_componentFlag
     ,l_componentObjDefId
     ,l_componentTypeCode
     ,l_factTableOnDataComp;


     EXIT WHEN comp_cv%NOTFOUND;

    l_componentCounter := l_componentCounter + 1;

    FEM_UTILS.GetObjNameandFolderUsingDef
                       (p_Obj_Def_ID => l_componentObjDefId
                       ,x_Object_Name => z_componentObjectDefName
                       ,x_Folder_Name => z_componentObjectFolderName);

     /*--Validate every Table on every Data Component
         if Calling Module is Conditions UI----*/
      /*-- IF (p_display_predicate = 'Y') THEN
         IF NOT tableNameIsValid(l_factTableOnDataComp) THEN
          --Skipping this Table,Comp Def as Table is Invalid--
        -- IF (z_loggingTurnedOn = 'Y') THEN
          trackInvalidDataComponents
                  (p_invalidDataCmpDefId => l_componentObjDefId
                  ,p_invalidTableName => l_factTableOnDataComp
                  ,p_invalidColumnName => NULL
                  ,p_invalidSecondColumnName => NULL) ;
         --END IF;

         GOTO PROCESS_NEXT_DATA_DIM_CMP;
        END IF;
      END IF;--*/
     /*----------------------------------------------------------*/

         IF (l_componentFlag = 'T') THEN
            IF (p_display_predicate = 'Y') THEN
               l_tableAlias := l_factTableOnDataComp;
            ELSE
               l_tableAlias := p_table_alias;
            END IF;
            generateDataPredicate(
	        p_dataComponentDefId => l_componentObjDefId
		  ,p_factTableName => l_factTableOnDataComp
              ,p_tableAlias => l_tableAlias
              ,p_byDimensionColumn => NULL
              ,p_byDimensionValue => NULL);
         ELSE
           generateDimPredicate(
		 p_dimComponentDefId => l_componentObjDefId
             ,p_factTableName => p_input_fact_table_name
             ,p_tableAlias => p_table_alias
             ,p_componentFlag => l_componentFlag
             ,p_effectiveDate => p_rule_effective_date
             ,p_byDimensionId => NULL
             ,p_byDimensionValue => NULL);
         END IF;

   END LOOP;

   CLOSE comp_cv;


   IF (l_componentCounter = 0) THEN
     RAISE NO_COMPONENTS_EXCEPTION;
   END IF;

   ----Generate final Data predicate string---------

  IF (z_dataStepPredicates.COUNT > 0) THEN
   FOR i IN z_dataStepPredicates.FIRST..z_dataStepPredicates.LAST LOOP
    IF (z_dataStepPredicates(i).STEP_SPECIFIC_PREDICATE IS NOT NULL) THEN
      l_dataPredicate := l_dataPredicate
  			||z_dataStepPredicates(i).Step_Specific_Predicate;
      IF (i < z_dataStepPredicates.LAST ) THEN
       l_dataPredicate := l_dataPredicate ||G_SPACE||G_AND||G_SPACE;
      END IF;
    END IF;

   END LOOP;
    --l_dataPredicate := G_OPEN||l_dataPredicate ||G_CLOSE;
  END IF;
  --------------------------------------------------
   ----Generate final Dim predicate string---------

  IF (z_dimStepPredicates.COUNT > 0) THEN

   FOR i IN z_dimStepPredicates.FIRST..z_dimStepPredicates.LAST LOOP
    IF (z_dimStepPredicates(i).Step_Specific_Predicate IS NOT NULL) THEN
      l_dimensionPredicate := l_dimensionPredicate
			||z_dimStepPredicates(i).Step_Specific_Predicate;
      IF (i < z_dimStepPredicates.LAST ) THEN
       l_dimensionPredicate := l_dimensionPredicate ||G_SPACE||G_AND||G_SPACE;
      END IF;
    END IF;

   END LOOP;
   -- l_dimensionPredicate := G_OPEN||l_dimensionPredicate ||G_CLOSE;
  END IF;
  --------------------------------------------------
   /*---Generating Final Predicate---*/

  IF (p_return_predicate_type = 'DATA') THEN
   x_predicate_string := l_dataPredicate ;
  ELSIF (p_return_predicate_type = 'DIM') THEN
   x_predicate_string := l_dimensionPredicate;

  ELSIF (p_return_predicate_type = 'BOTH') THEN
   IF ((z_dataStepPredicates.COUNT > 0) AND
       (z_dimStepPredicates.COUNT > 0)) THEN
      x_predicate_string := G_OPEN||l_dataPredicate||G_CLOSE
                            ||G_SPACE||G_AND||G_SPACE||
			    G_OPEN||l_dimensionPredicate||G_CLOSE;

   ELSIF ((z_dataStepPredicates.COUNT > 0) AND
          (z_dimStepPredicates.COUNT = 0)) THEN
      x_predicate_string := l_dataPredicate;
   ELSIF ((z_dataStepPredicates.COUNT = 0) AND
          (z_dimStepPredicates.COUNT > 0)) THEN
      x_predicate_string := l_dimensionPredicate;
   ELSIF ((z_dataStepPredicates.COUNT = 0) AND
          (z_dimStepPredicates.COUNT = 0)) THEN
      RAISE NO_VALID_COMPONENTS_EXCEPTION;
   END IF;
  END IF;
  --------------------------------------------------
  /*--Logging Predicate string to Concurrent Manager output ---*/
  /*--file for Condition UI --*/

  IF (p_display_predicate = 'Y') THEN
     logPredicateToOutputFile(
        p_conditionObjId => p_condition_obj_id,
	  p_returnPredicateType => p_return_predicate_type);
  END IF;
  --------------------------------------------------

    x_err_code := z_errCode;
    x_err_msg  := z_errMsg ;

	EXCEPTION
        WHEN NO_CONDITION_EXCEPTION THEN
           x_err_code := -1;
           x_err_msg := G_NO_VERSION;
           FEM_ENGINES_PKG.PUT_MESSAGE(
             p_app_name => FEM_APP,
             p_msg_name => x_err_msg,
             p_token1 => G_CONDITION_TOKEN,
             p_value1 => p_condition_obj_id,
             p_token2 => G_EFFECTIVE_DATE_TOKEN,
             p_value2 => p_rule_effective_date);
           RETURN;

        WHEN INVALID_FACT_TABLE_EXCEPTION THEN
           x_err_code := -1;
           x_err_msg := G_INVALID_TABLE;
           FEM_ENGINES_PKG.PUT_MESSAGE(
              p_app_name => FEM_APP,
              p_msg_name => x_err_msg,
              p_token1 => G_TABLE_TOKEN,
              p_value1 => p_input_fact_table_name);
           RETURN;

         WHEN NO_FACT_TABLE_EXCEPTION THEN
            x_err_code := -1;
            x_err_msg  := G_NO_TABLE;
            FEM_ENGINES_PKG.PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => x_err_msg);
            RETURN;

         WHEN HIER_FLATTENED_EXCEPTION THEN
            x_err_code := -1;
            x_err_msg  := G_HIER_FLATTENED;
            FEM_ENGINES_PKG.PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => x_err_msg);
            RETURN;

         WHEN NO_VALID_COMPONENTS_EXCEPTION THEN
            x_err_code := -1;
            x_err_msg  := G_NO_VALID_COMPS;
            FEM_ENGINES_PKG.PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => x_err_msg);
            RETURN;

         WHEN NO_COMPONENTS_EXCEPTION THEN
            x_err_code := -1;
            x_err_msg  := G_NO_COMPONENTS;
            FEM_ENGINES_PKG.PUT_MESSAGE(
               p_app_name => FEM_APP,
               p_msg_name => x_err_msg);
            RETURN;

        WHEN INVALID_DIM_COMP_EXCEPTION THEN
            x_err_code := -1;
            x_err_msg := G_INVALID_DIM_COMPONENT;
            FEM_ENGINES_PKG. PUT_MESSAGE(
                p_app_name => FEM_APP,
                p_msg_name => x_err_msg,
                p_token1 => G_CONDITION_TOKEN,
                p_value1 => z_conditionObjectDefName,
                p_token2 => G_COMPONENT_TOKEN,
                p_value2 => z_componentObjectDefName);


            RETURN;

	   WHEN OTHERS THEN
	      x_err_code := SQLCODE;
            x_err_msg := G_UNHANDLED_EXCEPTION;
 --FEM_ENGINES_PKG.USER_MESSAGE(x_err_msg);
            FEM_ENGINES_PKG. PUT_MESSAGE(
               p_app_name => FEM_APP,
    p_msg_name => G_UNHANDLED_EXCEPTION);
	      RETURN;



END GENERATE_CONDITION_PREDICATE;


/*************************************************************************

                             GENERATE_CONDITION_PREDICATE

Procecure used to generate a predicate (where clause) for a given condition
object based on the effective date.  The predicate can be generated for
either a dimension component or a data componenet, or both.
*************************************************************************/

PROCEDURE GENERATE_CONDITION_PREDICATE(
   p_api_version     IN NUMBER     DEFAULT g_api_version,
   p_init_msg_list   IN VARCHAR2   DEFAULT g_false,
   p_commit          IN VARCHAR2   DEFAULT g_false,
   p_encoded         IN VARCHAR2   DEFAULT g_true,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_input_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_display_predicate IN VARCHAR2,
   p_return_predicate_type IN VARCHAR2,
   p_logging_turned_on IN VARCHAR2,
   x_return_status  OUT NOCOPY VARCHAR2,
   x_msg_count      OUT NOCOPY NUMBER,
   x_msg_data       OUT NOCOPY VARCHAR2,
   x_predicate_string OUT NOCOPY LONG) IS



BEGIN

  GENERATE_CONDITION_PREDICATE(
     p_api_version => p_api_version,
     p_init_msg_list => p_init_msg_list,
     p_commit => p_commit,
     p_encoded => p_encoded,
     p_condition_obj_id => p_condition_obj_id,
     p_rule_effective_date => p_rule_effective_date,
     p_input_fact_table_name => p_input_fact_table_name,
     p_table_alias => p_table_alias,
     p_display_predicate => p_display_predicate,
     p_return_predicate_type => p_return_predicate_type,
     p_logging_turned_on => p_logging_turned_on,
     p_by_dimension_column => NULL,
     p_by_dimension_id => NULL,
     p_by_dimension_value => NULL,
     x_return_status => x_return_status,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data,
     x_predicate_string => x_predicate_string);

END GENERATE_CONDITION_PREDICATE;


/*============================================================================+
 | PROCEDURE
 |   Generate_Dim_Hier_Query
 |
 | DESCRIPTION
 |   This procedure returns a query string for finding a list of nodes in a
 |   hierarchy definition based on the passed hierarchy object id,
 |   effective date, node id (and value set id for VSR dimensions), and
 |   relation code.
 |
 |   All passed parameters are checked to ensure they are valid.
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

PROCEDURE Generate_Dim_Hier_Query (
  p_api_version                   in number   default g_api_version
  ,p_init_msg_list                in varchar2 default g_false
  ,p_commit                       in varchar2 default g_false
  ,p_encoded                      in varchar2 default g_true
  ,x_return_status                out nocopy varchar2
  ,x_msg_count                    out nocopy number
  ,x_msg_data                     out nocopy varchar2
  ---------------------------------------------------
  ,p_dimension_id                 in number
  ,p_hierarchy_object_id          in number
  ,p_effective_date               in varchar2
  ,p_relation_code                in varchar2
  ,p_node_id                      in varchar2
  ,p_value_set_id                 in number default null
  ,x_query_string                 out nocopy long
)
IS

  l_api_name             constant varchar2(30) := 'Generate_Dim_Hier_Query';
  l_api_version          constant number := 1.0;

  l_return_status                 varchar2(1);
  l_msg_count                     number;
  l_msg_data                      varchar2(2000);

  l_err_code                      number;
  l_err_msg                       varchar2(2000);

  l_dimension_varchar_label       varchar2(30);

  l_hierarchy_table_name          varchar2(30);
  l_hierarchy_folder_name         varchar2(150);
  l_hierarchy_obj_def_id          number;
  l_hierarchy_obj_def_name        varchar2(150);

  l_value_set_required_flag       varchar2(1);
  l_value_set_id                  number;
  l_flattened_flag                varchar2(1);
  l_flattened_code                varchar2(30);

  l_node_exists                   boolean;

  l_query_string                  long;

BEGIN

  -- Standard Start of API Savepoint
  savepoint Generate_Dim_Hier_Query_PVT;

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
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN'
  );

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  if (p_dimension_id is null) then
    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_NULL_PARAM_VALUE_ERR
      ,p_token1   => G_PARAM_TOKEN
      ,p_value1   => 'p_dimension_id'
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_hierarchy_object_id is null) then
    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_NULL_PARAM_VALUE_ERR
      ,p_token1   => G_PARAM_TOKEN
      ,p_value1   => 'p_hierarchy_object_id'
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_effective_date is null) then
    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_NULL_PARAM_VALUE_ERR
      ,p_token1   => G_PARAM_TOKEN
      ,p_value1   => 'p_effective_date'
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_relation_code is null) then
    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_NULL_PARAM_VALUE_ERR
      ,p_token1   => G_PARAM_TOKEN
      ,p_value1   => 'p_relation_code'
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_node_id is null) then
    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_NULL_PARAM_VALUE_ERR
      ,p_token1   => G_PARAM_TOKEN
      ,p_value1   => 'p_node_id'
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  -- get hierarchy obj def id for object
  Fem_Rule_Set_Manager.Get_ValidDefinition_Pub (
    p_object_id             => p_hierarchy_object_id
    ,p_rule_effective_date  => p_effective_date
    ,x_object_definition_id => l_hierarchy_obj_def_id
    ,x_err_code             => l_err_code
    ,x_err_msg              => l_err_msg
  );

  -- error check:  halt processing on this step if valid hier def not found.
  if (l_err_code <> 0) then
    --Message has been logged in Fem_Rule_Set_Manager.Get_ValidDefinition_Pub
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Check to see if this is a valid hierarchy dimension
  begin
    select a.hierarchy_table_name
    ,value_set_required_flag
    ,dimension_varchar_label
    into l_hierarchy_table_name
    ,l_value_set_required_flag
    ,l_dimension_varchar_label
    from fem_xdim_dimensions_vl a
    where a.dimension_id = p_dimension_id;
  exception
    when others then
      -- Invalid Dimension Id
      FEM_ENGINES_PKG.PUT_MESSAGE (
        p_app_name  => G_FEM
        ,p_msg_name => G_BAD_DIM_ID_ERR
        ,p_token1   => G_DIM_ID_TOKEN
        ,p_value1   => p_dimension_id
      );
      raise FND_API.G_EXC_ERROR;
  end;

  if (l_hierarchy_table_name is null) then
    -- Invalid Dimension
    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_DIM_BAD_DIM_LABEL
      ,p_token1   => G_DIM_LABEL_TOKEN
      ,p_value1   => l_dimension_varchar_label
    );
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Validate the Value Set Id for VSR dimensions
  if (l_value_set_required_flag = 'Y') then

    l_value_set_id := p_value_set_id;
    if (l_value_set_id is null) then

      l_value_set_id := getHierValueSetId (
        p_dimension_id      => p_dimension_id
        ,p_hierarchy_obj_id => p_hierarchy_object_id
      );

      if (l_value_set_id is null) then

        -- Value Set Id cannot be null for VSR dimensions
        FEM_ENGINES_PKG.PUT_MESSAGE (
          p_app_name  => G_FEM
          ,p_msg_name => G_NULL_PARAM_VALUE_ERR
          ,p_token1   => G_PARAM_TOKEN
          ,p_value1   => 'p_value_set_id'
        );
        raise FND_API.G_EXC_ERROR;

      end if;

	end if;

  end if;

  -- Check if hierarchy will be flattened
  select flattened_rows_flag
  into l_flattened_flag
  from fem_hierarchies
  where hierarchy_obj_id = p_hierarchy_object_id;

  if (l_flattened_flag = 'Y') then

    -- If hierarchy is flattened, make sure flattening is complete
    select flattened_rows_completion_code
    into l_flattened_code
    from fem_hier_definitions
    where hierarchy_obj_def_id = l_hierarchy_obj_def_id;

    if (l_flattened_code <> 'COMPLETED') then
      FEM_ENGINES_PKG.PUT_MESSAGE (
        p_app_name  => G_FEM
        ,p_msg_name => G_HIER_FLATTENED
      );
      raise FND_API.G_EXC_ERROR;
    end if;

  end if;

  l_node_exists := validateHierarchyNode (
    p_tableName      => l_hierarchy_table_name
    ,p_node          => p_node_id
    ,p_value_set_id  => l_value_set_id
    ,p_objId         => p_hierarchy_object_id
    ,p_objDefId      => l_hierarchy_obj_def_id
    ,p_effectiveDate => p_effective_date
  );

  if not l_node_exists then

    FEM_UTILS.GetObjNameandFolderUsingDef (
      p_obj_def_id   => l_hierarchy_obj_def_id
      ,x_object_name => l_hierarchy_obj_def_name
      ,x_folder_name => l_hierarchy_folder_name
    );

    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_INVALID_NODE
      ,p_token1   => G_NODE_TOKEN
      ,p_value1   => p_node_id
      ,p_token2   => G_HIERARCHY_TOKEN
      ,p_value2   => l_hierarchy_obj_def_name
    );

    raise FND_API.G_EXC_ERROR;

  end if;

  if (l_flattened_flag = 'Y') then

    l_query_string := getDimFlatHierQuery (
      p_hierarchy_table_name  => l_hierarchy_table_name
      ,p_relation_code        => p_relation_code
      ,p_hierarchy_obj_def_id => l_hierarchy_obj_def_id
      ,p_node_list            => p_node_id
      ,p_value_set_id         => l_value_set_id
    );

  else

    l_query_string := getDimHierQuery (
      p_hierarchy_table_name    => l_hierarchy_table_name
      ,p_relation_code          => p_relation_code
      ,p_hierarchy_obj_def_id   => l_hierarchy_obj_def_id
      ,p_node_list              => p_node_id
      ,p_value_set_id           => l_value_set_id
      ,p_effective_date_varchar => p_effective_date
    );

  end if;

  if (l_query_string is null) then

    FEM_ENGINES_PKG.PUT_MESSAGE (
      p_app_name  => G_FEM
      ,p_msg_name => G_INVALID_RELATION
      ,p_token1   => G_RELATION_TOKEN
      ,p_value1   => p_relation_code
    );

    raise FND_API.G_EXC_ERROR;

  end if;

  x_query_string := l_query_string;

  -----------------------
  -- Finalize API Call --
  -----------------------
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
    p_severity  => G_LOG_LEVEL_PROCEDURE
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when FND_API.G_EXC_ERROR then
    rollback to Generate_Dim_Hier_Query_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when FND_API.G_EXC_UNEXPECTED_ERROR then
    rollback to Generate_Dim_Hier_Query_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

  when others then
    rollback to Generate_Dim_Hier_Query_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) then
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    end if;
    FND_MSG_PUB.Count_And_Get(
      p_count   => x_msg_count
      ,p_data   => x_msg_data
    );

END Generate_Dim_Hier_Query;


/*============================================================================+
 | FUNCTION
 |   Get_Dim_Member_Display_Code
 |
 | DESCRIPTION
 |   This Function returns the Member Display Code for a given Dimension ID
 |   and Member ID.  This Method will be used in queries so that's why method
 |   is not using Out Parameters like x_return_status, x_message_count,
 |   and x_msg_data to get the status.
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Member_Display_Code (
  p_dimension_id                  in number
  ,p_member_id                    in varchar2
) RETURN varchar2
IS

  l_member_display_code           varchar2(150):= null;

BEGIN

  select FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_Display_Code(
    xdim.dimension_id
    ,p_member_id
    ,decode(xdim.value_set_required_flag
      ,'Y',FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id(xdim.dimension_id)
      ,null))
  into l_member_display_code
  from fem_xdim_dimensions_vl xdim
  where xdim.dimension_id = p_dimension_id;

return l_member_display_code;

EXCEPTION

  when others then
    return null;

END Get_Dim_Member_Display_Code;


/*============================================================================+
 | FUNCTION
 |   Get_Dim_Member_Name
 |
 | DESCRIPTION
 |   This Function returns the Member Name for a given Dimension ID and
 |   Member ID.  This Method will be used in queries so that's why method
 |   is not using Out Parameters like x_return_status, x_message_count,
 |   x_msg_data to get the status.
 |
 |  SCOPE - PUBLIC
 +============================================================================*/

FUNCTION Get_Dim_Member_Name (
  p_dimension_id                  in number
  ,p_member_id                    in varchar2
) RETURN varchar2
IS

  l_member_name                   varchar2(150):= null;

BEGIN

  select FEM_DIMENSION_UTIL_PKG.Get_Dim_Member_Name(
    xdim.dimension_id
    ,p_member_id
    ,decode(xdim.value_set_required_flag
      ,'Y',FEM_DIMENSION_UTIL_PKG.Dimension_Value_Set_Id(xdim.dimension_id)
      ,null))
  into l_member_name
  from fem_xdim_dimensions_vl xdim
  where xdim.dimension_id = p_dimension_id;

return l_member_name;

EXCEPTION

  when others then
    return null;

END Get_Dim_Member_Name;


END FEM_CONDITIONS_API;

/
