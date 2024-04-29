--------------------------------------------------------
--  DDL for Package Body FUN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_PUB" AS
/*$Header: FUNXTMRULENGINB.pls 120.19.12010000.9 2010/03/09 07:06:45 rviriyal ship $ */

--------------------------------------
-- declaration of private global varibles
--------------------------------------

  TYPE t_parameter_rec IS RECORD
  (
    name VARCHAR2(30),
    value VARCHAR2(240)
  );

  TYPE t_parameter_list IS TABLE OF t_parameter_rec INDEX BY BINARY_INTEGER;

  TYPE multi_param_value IS TABLE OF VARCHAR2(1024) INDEX BY BINARY_INTEGER;

  m_RuleResultTable  fun_rule_results_table;

  g_parameter_list t_parameter_list;
  g_parameter_count NUMBER := 0;

  m_instance_label   VARCHAR2(150)    := NULL;
  m_org_id           NUMBER           := NULL;
  m_instance_context VARCHAR2(1)      := 'N';


  sDFFTableName   VARCHAR2(30);

  g_sRuleDetailSql VARCHAR2(2000) :=  'SELECT FRO.RESULT_TYPE, FRD.RULE_DETAIL_ID, FRD.OPERATOR ,
                                              FRD.RULE_OBJECT_ID,FRO.FLEXFIELD_NAME , FRO.FLEXFIELD_APP_SHORT_NAME,
                                              UPPER(NVL(FRO.MULTI_RULE_RESULT_FLAG, ''N'')), UPPER(USE_DEFAULT_VALUE_FLAG)
                                       FROM  FUN_RULE_DETAILS FRD , FUN_RULE_OBJECTS_VL FRO
                                       WHERE FRO.RULE_OBJECT_ID = FRD.RULE_OBJECT_ID
                                       AND   FRO.RULE_OBJECT_NAME=:1
                                       AND   FRO.APPLICATION_ID = :2
                                       AND   NVL(FRD.ENABLED_FLAG,''N'') = ''Y''
                                       ORDER BY FRD.SEQ';

g_sRuleDetailMOACSql VARCHAR2(2000) :=  'SELECT FRO.RESULT_TYPE, FRD.RULE_DETAIL_ID, FRD.OPERATOR ,
                                              FRD.RULE_OBJECT_ID,FRO.FLEXFIELD_NAME , FRO.FLEXFIELD_APP_SHORT_NAME,
                                              UPPER(NVL(FRO.MULTI_RULE_RESULT_FLAG, ''N'')), UPPER(USE_DEFAULT_VALUE_FLAG)
                                       FROM  FUN_RULE_DETAILS FRD , FUN_RULE_OBJECTS_VL FRO
                                       WHERE FRO.RULE_OBJECT_ID = FRD.RULE_OBJECT_ID
                                       AND   FRO.RULE_OBJECT_NAME=:1
                                       AND   FRO.APPLICATION_ID = :2
                                       AND   NVL(FRD.ENABLED_FLAG,''N'') = ''Y''
				    AND ( (INSTANCE_LABEL IS NULL AND :3 IS NULL) OR
				       (INSTANCE_LABEL IS NOT NULL AND :4 IS NOT NULL AND INSTANCE_LABEL = :5))
				    AND
				     ( (ORG_ID IS NULL AND :6 IS NULL) OR
				       (ORG_ID IS NOT NULL AND :7 IS NOT NULL AND ORG_ID = :8))
                                       ORDER BY FRD.SEQ';

  g_sCriteriaParamSql VARCHAR2(2000) := 'SELECT  FRCP.PARAM_NAME,
                                                 FRC.CONDITION, FRC.PARAM_VALUE, FRCP.DATA_TYPE,
                                                 FRC.CASE_SENSITIVE_FLAG , FRC.CRITERIA_ID
                                        FROM FUN_RULE_CRIT_PARAMS_B FRCP,
                                             FUN_RULE_CRITERIA           FRC
                                        WHERE FRC.RULE_DETAIL_ID = :1
                                        AND   FRC.CRITERIA_PARAM_ID = FRCP.CRITERIA_PARAM_ID
                                      UNION
                                       SELECT LOOKUP_CODE,
                                              FRC.CONDITION, FRC.PARAM_VALUE, ''STRINGS'',
                                              FRC.CASE_SENSITIVE_FLAG , FRC.CRITERIA_ID
                                       FROM FUN_LOOKUPS FLV,
  				            FUN_RULE_CRIT_PARAMS_B FRCP,
                                            FUN_RULE_CRITERIA  FRC
                                       WHERE LOOKUP_TYPE = ''FUN_RULE_SEED_PARAMS''
                                       AND   FRC.RULE_DETAIL_ID = :2
                                       AND   FRC.CRITERIA_PARAM_ID = FRCP.CRITERIA_PARAM_ID
                                       AND   FRCP.PARAM_NAME = FLV.LOOKUP_CODE';

g_sMultiCriteriaParamValueSql VARCHAR2(1000) := 'SELECT  FRMP.PARAM_VALUE
                                                FROM FUN_RULE_PARAM_VALUES        FRMP,
                                                       FUN_RULE_CRITERIA           FRC
                                                WHERE FRC.RULE_DETAIL_ID = :1
                                                AND   FRC.CRITERIA_ID = FRMP.CRITERIA_ID
                                                AND   FRC.CRITERIA_ID = :2 ';

g_sValueSetSql     VARCHAR2(1000) := 'SELECT FFVS.FORMAT_TYPE
                                     FROM FUN_RULE_OBJECTS_B FRO,
                                     FND_FLEX_VALUE_SETS FFVS
                                     WHERE FRO.FLEX_VALUE_SET_ID = FFVS.FLEX_VALUE_SET_ID
                                     AND FRO.RULE_OBJECT_ID = :1 ';


g_sRuleObjectSql   VARCHAR2(1000) := 'SELECT RESULT_TYPE, RULE_OBJECT_ID,
                                      FLEXFIELD_NAME , FLEXFIELD_APP_SHORT_NAME
                                      FROM FUN_RULE_OBJECTS_B
                                      WHERE RULE_OBJECT_NAME = :1';

g_sRuleObjectMOACSql   VARCHAR2(1000) := 'SELECT RESULT_TYPE, RULE_OBJECT_ID,
                                      FLEXFIELD_NAME , FLEXFIELD_APP_SHORT_NAME
                                      FROM FUN_RULE_OBJECTS_B
                                      WHERE RULE_OBJECT_NAME = :1
				     AND ( (INSTANCE_LABEL IS NULL AND :2 IS NULL) OR
				       (INSTANCE_LABEL IS NOT NULL AND :3 IS NOT NULL AND INSTANCE_LABEL = :4))
				     AND
				     ( (ORG_ID IS NULL AND :5 IS NULL) OR
				       (ORG_ID IS NOT NULL AND :6 IS NOT NULL AND ORG_ID = :7))';


g_sResultValuesSql VARCHAR2(1000) := 'SELECT RULE_DETAIL_ID , RESULT_VALUE ,  RESULT_APPLICATION_ID  , RULE_NAME
                                      FROM FUN_RULE_DETAILS WHERE RULE_DETAIL_ID = :1' ;


g_sDefaultValuesSql varchar2(1000) := 'SELECT DEFAULT_VALUE ,  DEFAULT_APPLICATION_ID FROM FUN_RULE_OBJ_ATTRIBUTES
                                      WHERE RULE_OBJECT_ID = :1 ';


g_sRuleObjectSql_orig   VARCHAR2(2000) := g_sRuleObjectSql;
g_sRuleDetailSql_orig   VARCHAR2(2000) := g_sRuleDetailSql;

C_LIKE			varchar2(10) := 'LIKE';
C_CONTAINS		varchar2(10) := 'CONTAIN';
C_EQUALS		varchar2(10) := 'EQUALS';
C_NOT_EQUALS		varchar2(30) := 'NOT_EQUALS';
C_IN			varchar2(10) := 'IN';
C_NOT_IN		varchar2(10) := 'NOT_IN';
C_GREATER_THAN		varchar2(10) := 'GREATER';
C_LESSER_THAN		varchar2(10) := 'LESS';
C_GREATER_THAN_EQUAL    varchar2(40) := 'GREATER_EQUALS';
C_LESSER_THAN_EQUAL     varchar2(40) := 'LESS_EQUALS';
C_BETWEEN		varchar2(30) := 'BETWEEN';
C_EMPTY                 VARCHAR2(10) := 'EMPTY';
C_NO			varchar2(10) := 'N';
C_YES			varchar2(10) := 'Y';
C_STRINGS		varchar2(10) := 'STRINGS';
C_NUMERIC		varchar2(10) := 'NUMERIC';
C_DATE			varchar2(10) := 'DATE';
C_MESSAGE		varchar2(10) := 'MESSAGES';
C_RICHTEXT		varchar2(10) := 'RICHTEXT';
C_VALUESET		varchar2(10) := 'VALUESET';
C_MULTIVALUE		varchar2(10) := 'MULTIVALUE';

C_AND		        varchar2(10) := 'AND';
C_OR		        varchar2(10) := 'OR';


C_INVALID_ORG           NUMBER := -2;

NO_DEFAULT_VALUE_EXCEPTION        EXCEPTION;
INVAILD_COLUMN_NAME               EXCEPTION;
-----------------------------------------------------------------
-- Private procedures and functions used internally by Rule
-- Engine.
-----------------------------------------------------------------

PROCEDURE getMultiValueParamsArray(p_multi_param_value OUT NOCOPY multi_param_value,
                                   p_rule_detail_id    IN NUMBER,
 			           p_rule_criteria_id  IN NUMBER,
				   p_data_type         IN VARCHAR2);

FUNCTION getResultValueDataType(p_ObjectType IN VARCHAR2 ,
                                p_RuleObjectId IN NUMBER) RETURN VARCHAR2;


PROCEDURE setResultValues(p_ret_val IN BOOLEAN,
                         p_isAnyActiveRule IN BOOLEAN,
                         p_rule_object_id IN NUMBER,
                         p_result_type IN VARCHAR2,
                         p_rule_object_name IN VARCHAR2,
                         p_flexfield_name IN VARCHAR2,
                         p_flexfield_app_short_name IN VARCHAR2,
                         p_rule_detail_id IN NUMBER);

FUNCTION populateRuleResultObjects RETURN FUN_RULE_RESULT;

FUNCTION checkIfMultiValueResultIsNull RETURN BOOLEAN;

FUNCTION matchCriteria(p_ParamName IN VARCHAR2, p_Condition VARCHAR2,
                       multiValueParamsArray IN multi_param_value, p_DataType IN VARCHAR2,
                       critObjectValue IN t_parameter_list, p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION ContainsKey(critObjectValue IN t_parameter_list,
                     p_ParamName  IN VARCHAR2) RETURN BOOLEAN;

FUNCTION get(critObjectValue IN t_parameter_list,
             p_ParamName  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getIndex(critObjectValue IN t_parameter_list,
                  p_ParamName  IN VARCHAR2) RETURN NUMBER;

FUNCTION  getDFFResultValue(p_RuleDetailId IN NUMBER,
                            p_FlexFieldName IN VARCHAR2,
                            p_FlexFieldAppShortName IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  getDFFDefaultValue(p_RuleDetailId IN NUMBER,
                             p_FlexFieldName IN VARCHAR2,
                             p_FlexFieldAppShortName IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getResultValue(p_ruleDetailId IN NUMBER, p_ObjectType IN VARCHAR2) RETURN VARCHAR2;

FUNCTION getDefaultValue(p_ruleObjectId IN NUMBER, p_ObjectType IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE getRuleObjectInfo(p_RuleObjectName IN VARCHAR2);

FUNCTION isMatched(p_ParamName VARCHAR2, p_DataType VARCHAR2,
                   p_Condition VARCHAR2, p_ParamValue VARCHAR2,
                   p_ValueToBeCompared  VARCHAR2,
                   p_CaseSensitive VARCHAR2) RETURN BOOLEAN;

FUNCTION getComparedData(p_Obj1 IN VARCHAR2, p_Obj2 IN VARCHAR2,
                         p_DataType IN VARCHAR2, p_CaseSensitive IN VARCHAR2) RETURN NUMBER;

FUNCTION compareTo(p_Obj1 IN VARCHAR2, p_Obj2 IN VARCHAR2 ,  p_DataType IN VARCHAR2)  RETURN NUMBER;


FUNCTION isMatchedLikeContain(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                              p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
     		              p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedEquals(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                         p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
  	                 p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedNotEquals(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                            p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
 	  	            p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedGreater(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                          p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
  	                  p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedLesser(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                         p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
  	                 p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedGreaterEqual(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                               p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
     	  	               p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedLesserEqual(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                              p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
  	  	              p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN;

FUNCTION isMatchedEmpty(p_ValueToBeCompared IN VARCHAR2) RETURN BOOLEAN;

FUNCTION  isRuleValid(p_param_view_name in varchar2, l_where_clause IN VARCHAR2) RETURN BOOLEAN;
FUNCTION  populateGTBulkTable(p_insert_statement IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE refreshGTBulkTable;

PROCEDURE TEST;

PROCEDURE clearInstanceContext;

  PROCEDURE init_parameter_list IS
  BEGIN
    g_parameter_count := 0;

    m_ruleDetailId         := NULL;
    m_resultApplicationId  := NULL;
    m_ruleName		   := NULL;
    m_resultValue          := NULL;
    m_resultValueDataType  := NULL;
    m_multiRuleResultFlag  := NULL;
    m_useDefaultValueFlag  := NULL;
    m_noRulesSatisfied     := FALSE;
    m_attributeCategory    := NULL;
    m_attribute1	   := NULL;
    m_attribute2           := NULL;
    m_attribute3           := NULL;
    m_attribute4           := NULL;
    m_attribute5           := NULL;
    m_attribute6           := NULL;
    m_attribute7           := NULL;
    m_attribute8           := NULL;
    m_attribute9           := NULL;
    m_attribute10          := NULL;
    m_attribute11          := NULL;
    m_attribute12          := NULL;
    m_attribute13          := NULL;
    m_attribute14          := NULL;
    m_attribute15          := NULL;

  END init_parameter_list;

  /**
   * This procedure sets the instance context for the Rule Object Instance.
   * Once set, the rule object id will be derived from the Rule Object Instance
   * and will be used throughout.
   *
   * p_application_short_name Application Short Name
   * p_rule_object_name Name of rule object
   * p_instance_label   Instance label of rule object
   * p_org_id           org id for the rule object instance.
   */

  PROCEDURE set_instance_context(p_rule_object_name IN VARCHAR2, p_application_short_name IN VARCHAR2,
               p_instance_label  IN VARCHAR2 , p_org_id  IN NUMBER) IS

    L_DUMMY               VARCHAR2(1) := 'N';
    l_org_id              NUMBER := null;
  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'set_instance_context :->p_application_short_name='||p_application_short_name||'**p_rule_object_name='||p_rule_object_name||'**p_instance_label='||p_instance_label, FALSE);
    end if;

    l_org_id := p_org_id;

    SELECT 'Y', RULE_OBJECT_ID INTO L_DUMMY, m_ruleObjectId FROM
    FUN_RULE_OBJECTS_B FRO, FND_APPLICATION APPL
    WHERE RULE_OBJECT_NAME = p_rule_object_name
    AND   FRO.APPLICATION_ID = APPL.APPLICATION_ID
    AND   APPL.APPLICATION_SHORT_NAME = p_application_short_name
    AND
     ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
       (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
    AND
     ( (ORG_ID IS NULL AND l_org_id IS NULL) OR
       (ORG_ID IS NOT NULL AND l_org_id IS NOT NULL AND ORG_ID = l_org_id))
    AND PARENT_RULE_OBJECT_ID IS NOT NULL;


    m_instance_label := p_instance_label;
    m_instance_context := 'Y';

    --If p_org_id is passed, then validate it and then store it for later use
    --in MOAC changes.

      IF (l_org_id IS NOT NULL) THEN
        IF(NOT FUN_RULE_VALIDATE_PKG.validate_org_id(l_org_id)) THEN
	   fnd_message.set_name('FUN', 'FUN_RULE_INVALID_ORG_ID');
           app_exception.raise_exception;
	END IF;
      END IF;

      m_org_id := l_org_id;

    --No need to validate the  p_application_short_name, because the above SQL anyway
    --throws NO DATA FOUND otherwise.

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.set_instance_context:->NO_DATA_FOUND', FALSE);
       END IF;

       fnd_message.set_name('FUN','FUN_RULE_INVAID_ROB_INSTANCE');
       app_exception.raise_exception;
  END;


  PROCEDURE add_parameter(name VARCHAR2, value VARCHAR2) IS
    l_parameter_rec t_parameter_rec;
  BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'add_parameter:->name='||name||'**Value='||value, FALSE);
   end if;

    l_parameter_rec.name := name;
    l_parameter_rec.value := value;

    g_parameter_count := g_parameter_count + 1;
    g_parameter_list(g_parameter_count) := l_parameter_rec;
  END add_parameter;


  PROCEDURE add_parameter(name VARCHAR2, value DATE) IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'add_parameter DATE:->name='||name||'**Value='||value, FALSE);
   end if;

    add_parameter(name, fnd_date.date_to_canonical(value));
  END add_parameter;


  PROCEDURE add_parameter(name VARCHAR2, value NUMBER) IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'add_parameter NUMBER:->name='||name||'**Value='||value, FALSE);
   end if;

    add_parameter(name, fnd_number.number_to_canonical(value));
  END add_parameter;

  FUNCTION get_string RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'get_string :->m_resultValue='||m_resultValue, FALSE);
   end if;

    RETURN m_resultValue;
  END;


  FUNCTION get_number RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'get_number :->m_resultValue='||m_resultValue, FALSE);
   end if;

    RETURN fnd_number.canonical_to_number(m_resultValue);
  END;

  FUNCTION get_date RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'get_date :->m_resultValue='||m_resultValue, FALSE);
   end if;

    RETURN fnd_date.canonical_to_date(m_resultValue);
  END;

  PROCEDURE apply_rule(p_application_short_name IN VARCHAR2, p_rule_object_name IN VARCHAR2)
  IS

    l_application_id		NUMBER;
    destination_cursor		INTEGER;
    l_num_rows_processed	INTEGER;
    params_cursor               INTEGER;
    params_rows_processed       INTEGER;

    l_ret_val                   boolean := true;
    l_all_rule_retval           boolean := false; --to track at least one rule is satisfied or not.

    l_result_type		FUN_RULE_OBJECTS_B.RESULT_TYPE%TYPE;
    l_rule_detail_id		FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
    l_prev_rule_detail_id	FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
    l_operator			FUN_RULE_DETAILS.OPERATOR%TYPE;
    l_rule_object_id		FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE;
    l_flexfield_name		FUN_RULE_OBJECTS_B.FLEXFIELD_NAME%TYPE;
    l_flexfield_app_short_name  FUN_RULE_OBJECTS_B.FLEXFIELD_APP_SHORT_NAME%TYPE;
    l_multiRuleResultFlag       FUN_RULE_OBJECTS_B.MULTI_RULE_RESULT_FLAG%TYPE;
    l_useDefaultValueFlag       FUN_RULE_OBJECTS_B.USE_DEFAULT_VALUE_FLAG%TYPE;

    l_param_name		FUN_RULE_CRIT_PARAMS_B.PARAM_NAME%TYPE;
    l_condition                 FUN_RULE_CRITERIA.CONDITION%TYPE;
    l_param_value		FUN_RULE_CRITERIA.PARAM_VALUE%TYPE;
    l_data_type			FUN_RULE_CRIT_PARAMS_B.DATA_TYPE%TYPE;
    l_case_sensitive		FUN_RULE_CRITERIA.CASE_SENSITIVE_FLAG%TYPE;
    l_criteria_id		FUN_RULE_CRITERIA.CRITERIA_ID%TYPE;

    l_ParamMultiValueList       multi_param_value;

    l_return_result             VARCHAR2(240);
    l_isAnyActiveRule           boolean := false;
    l_count                     NUMBER := 1;
    l_set_result_values         boolean := false;

    RuleResultTable  fun_Rule_Results_Table    := fun_Rule_Results_Table();
--    m_RuleResultTable  RuleResultTableType;

    l_old_moac_access_mode      VARCHAR2(1);
    l_old_org_id                NUMBER;

  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'apply_rule :->p_application_short_name='||p_application_short_name||'**p_rule_object_name='||p_rule_object_name, FALSE);
   end if;


   /*Rule Object Instance MOAC Changes:
    *    If p_org_id is passed and the set_instance_context is called, then set the MOAC context based on
    *    following logic.
    *    If Product team has not called MO_GLOBAL.INIT then raise an exception.
    *    Else, get the access_mode. If access_mode is not S, then set to S and the passed p_og_id.
    */
    l_old_moac_access_mode := MO_GLOBAL.get_access_mode();
    l_old_org_id           := MO_GLOBAL.get_current_org_id();

    --Does validation and then sets the policy context to S, if its not S and
    --the passed org id value is not same as current org id value.

    IF (m_org_id IS NOT NULL) THEN
       FUN_RULE_MOAC_PKG.SET_MOAC_ACCESS_MODE(m_org_id);
    END IF;


    l_application_id := FUN_RULE_UTILITY_PKG.getApplicationID(p_application_short_name);

    IF(l_application_id IS NULL) THEN
      l_application_id := FND_GLOBAL.RESP_APPL_ID;
    END IF;

    destination_cursor := DBMS_SQL.OPEN_CURSOR;


    --IF Instance Context is set, then append the where clause with an extra bind variable i.e
    --AND INSTANCE_LABEL = :3

    IF (m_instance_context = 'Y') THEN
      g_sRuleDetailSql := g_sRuleDetailMOACSql;
    ELSE
      g_sRuleDetailSql := g_sRuleDetailSql_orig;
    END IF;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'apply_rule :->g_sRuleDetailSql='||g_sRuleDetailSql, FALSE);
    end if;

    DBMS_SQL.PARSE(destination_cursor, g_sRuleDetailSql,DBMS_SQL.native);
    dbms_sql.bind_variable(destination_cursor , '1' , p_rule_object_name);
    dbms_sql.bind_variable(destination_cursor , '2' , l_application_id);

    IF (m_instance_context = 'Y') THEN
      dbms_sql.bind_variable(destination_cursor , '3' , m_instance_label);
      dbms_sql.bind_variable(destination_cursor , '4' , m_instance_label);
      dbms_sql.bind_variable(destination_cursor , '5' , m_instance_label);

      dbms_sql.bind_variable(destination_cursor , '6' , m_org_id);
      dbms_sql.bind_variable(destination_cursor , '7' , m_org_id);
      dbms_sql.bind_variable(destination_cursor , '8' , m_org_id);
    END IF;

    dbms_sql.define_column(destination_cursor, 1, l_result_type , 30);
    dbms_sql.define_column(destination_cursor, 2, l_rule_detail_id);
    dbms_sql.define_column(destination_cursor, 3, l_operator , 3);
    dbms_sql.define_column(destination_cursor, 4, l_rule_object_id);
    dbms_sql.define_column(destination_cursor, 5, l_flexfield_name , 80);
    dbms_sql.define_column(destination_cursor, 6, l_flexfield_app_short_name , 30);
    dbms_sql.define_column(destination_cursor, 7, l_multiRuleResultFlag , 10);
    dbms_sql.define_column(destination_cursor, 8, l_useDefaultValueFlag , 10);

    l_num_rows_processed := DBMS_SQL.EXECUTE(destination_cursor);

    while(dbms_sql.fetch_rows(destination_cursor) > 0 ) loop
       l_isAnyActiveRule := true;  --i.e Atleast one Rule is present.

       dbms_sql.column_value(destination_cursor, 1, l_result_type);
       dbms_sql.column_value(destination_cursor, 2, l_rule_detail_id );
       dbms_sql.column_value(destination_cursor, 3, l_operator);
       dbms_sql.column_value(destination_cursor, 4, l_rule_object_id);
       dbms_sql.column_value(destination_cursor, 5, l_flexfield_name);
       dbms_sql.column_value(destination_cursor, 6, l_flexfield_app_short_name);
       dbms_sql.column_value(destination_cursor, 7, l_multiRuleResultFlag);
       dbms_sql.column_value(destination_cursor, 8, l_useDefaultValueFlag);
       m_multiRuleResultFlag := l_multiRuleResultFlag;
       m_useDefaultValueFlag := l_useDefaultValueFlag;


       IF (L_OPERATOR = C_OR) THEN
         l_ret_val := false;
       ELSE
         l_ret_val := true;
       END IF;

       params_cursor := DBMS_SQL.OPEN_CURSOR;

       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'apply_rule :->g_sCriteriaParamSql='||g_sCriteriaParamSql, FALSE);
       end if;

       DBMS_SQL.PARSE(params_cursor, g_sCriteriaParamSql,DBMS_SQL.native);
       dbms_sql.bind_variable(params_cursor , '1' , l_rule_detail_id);
       dbms_sql.bind_variable(params_cursor , '2' , l_rule_detail_id);

       dbms_sql.define_column(params_cursor, 1, l_param_name , 30);
       dbms_sql.define_column(params_cursor, 2, l_condition , 15);
       dbms_sql.define_column(params_cursor, 3, l_param_value , 1024);
       dbms_sql.define_column(params_cursor, 4, l_data_type, 15);
       dbms_sql.define_column(params_cursor, 5, l_case_sensitive, 1);
       dbms_sql.define_column(params_cursor, 6, l_criteria_id);

       params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

       while(dbms_sql.fetch_rows(params_cursor) > 0 ) loop
	       dbms_sql.column_value(params_cursor, 1, l_param_name );
	       dbms_sql.column_value(params_cursor, 2, l_condition );
	       dbms_sql.column_value(params_cursor, 3, l_param_value);
	       dbms_sql.column_value(params_cursor, 4, l_data_type);
	       dbms_sql.column_value(params_cursor, 5, l_case_sensitive);
	       dbms_sql.column_value(params_cursor, 6, l_criteria_id);


               if(l_param_name = 'APPLICATION') then
                 if(NOT containsKey(g_parameter_list,'APPLICATION')) then
                  add_parameter('APPLICATION' , FND_GLOBAL.RESP_APPL_ID);
		 end if;
               end if;

               if(l_param_name =  'RESPONSIBILITY') then
                if(NOT containsKey(g_parameter_list,'RESPONSIBILITY')) then
                  add_parameter('RESPONSIBILITY' , FND_GLOBAL.RESP_ID);
                end if;
               end if;


               /********************************************************************************
                MOAC Handle:
		1) When the product team calls applyRule(), and if the ORGANIZATION parameter is
		   explicitly passed, we should just use that value.
		2) If it is not, then see if the access mode is single. If it is, use that org
		   as the parameter value.
		3) If it is not, then any criteria which uses ORGANIZATION as the parameter
		   fails - always.
               **********************************************************************************/

               if(l_param_name = 'ORGANIZATION') then
                if(NOT containsKey(g_parameter_list,'ORGANIZATION')) then
                  add_parameter('ORGANIZATION' , FUN_RULE_UTILITY_PKG.get_moac_org_id);
                end if;
	       end if;

               if(l_param_name = 'USER') then
                if(NOT containsKey(g_parameter_list,'USER')) then
                  add_parameter('USER' , FND_GLOBAL.USER_ID);
                end if;
               end if;


               getMultiValueParamsArray(l_ParamMultiValueList, l_rule_detail_id, l_criteria_id , l_data_type);

	       IF(l_operator = C_AND) THEN
	         l_ret_val := matchCriteria(l_param_name, l_condition, l_ParamMultiValueList,
                                            l_data_type, g_parameter_list, l_case_sensitive) AND l_ret_val ;
	       ELSIF(l_operator = C_OR) THEN
	         l_ret_val := matchCriteria(l_param_name, l_condition, l_ParamMultiValueList,
                                            l_data_type, g_parameter_list, l_case_sensitive) OR l_ret_val ;
	       END IF;
       end loop;
      DBMS_SQL.CLOSE_CURSOR(params_cursor);

      l_all_rule_retval := l_all_rule_retval OR l_ret_val;

      setResultValues(l_ret_val,
    	              l_isAnyActiveRule,
		      l_rule_object_id,
		      l_result_type,
		      p_rule_object_name,
    		      l_flexfield_name,
 		      l_flexfield_app_short_name,
   		      l_rule_detail_id);


      if(l_multiRuleResultFlag = 'N') then
        if (l_ret_val) then exit; end if;
      else
	--For AR's Multi Rule Result we populate RuleResultObject here.
              if(l_ret_val) then
	        RuleResultTable.extend;
   	        RuleResultTable(l_count) := populateRuleResultObjects;
	        l_count := l_count+1;
              end if;
      end if;

    end loop;

    DBMS_SQL.CLOSE_CURSOR(destination_cursor);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'apply_rule :->Before calling setResultValues', FALSE);
    end if;

    if(NOT l_all_rule_retval) then    --implies that not a single Rule is satisfied.
      setResultValues(l_ret_val,
    	              l_isAnyActiveRule,
		      l_rule_object_id,
		      l_result_type,
		      p_rule_object_name,
    		      l_flexfield_name,
 		      l_flexfield_app_short_name,
   		      l_rule_detail_id);
    else
        /*In case of Multi Rule Result, we should not make m_noRulesSatisfied as false
         * if at least one result is returned i.e bAllRuleRetVal is true.
         * */
      if(l_multiRuleResultFlag = 'Y') then
        m_noRulesSatisfied := false;
      end if;

    end if;


    --If (no Rules are satisfied OR Not a single rule is there) and use default flag is NOT Y
    --then return false;
    if((m_noRulesSatisfied OR (NOT l_isAnyActiveRule)) AND  m_useDefaultValueFlag <> 'Y') then
         RAISE NO_DEFAULT_VALUE_EXCEPTION;
    end if;


    if(l_multiRuleResultFlag = 'Y') then  --For Multi RUle Result Object Type
      if(NOT l_all_rule_retval) then
	        RuleResultTable.extend;
   	        RuleResultTable(l_count) := populateRuleResultObjects;
      end if;
        m_RuleResultTable := RuleResultTable;
    end if;


   /*Rule Object Instance MOAC Changes:
    *Revert back the access mode and org id to the l_old_acess_mode and l_old_org_id
    *And Clear The Instance Context if set.
    */
   IF (m_org_id IS NOT NULL) THEN
    FUN_RULE_MOAC_PKG.SET_MOAC_POLICY_CONTEXT(l_old_moac_access_mode , l_old_org_id , m_org_id);
   END IF;

   clearInstanceContext;

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End apply_rule', FALSE);
   end if;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.apply_rule:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN NO_DEFAULT_VALUE_EXCEPTION THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.apply_rule:->NO_DEFAULT_VALUE_EXCEPTION', FALSE);
       END IF;

       fnd_message.set_name('FUN','NO_DEFAULT_VALUE_EXCEPTION');
       app_exception.raise_exception;

    WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(destination_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(destination_cursor);
       END IF;
       IF DBMS_SQL.IS_OPEN(params_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(params_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.APLY_RULE:->'||SQLERRM, FALSE);
       END IF;

       RAISE;
  END apply_rule;


  FUNCTION apply_rule(p_application_short_name IN VARCHAR2, p_rule_object_name IN VARCHAR2)
  RETURN BOOLEAN
  IS

    l_application_id		NUMBER;
    destination_cursor		INTEGER;
    l_num_rows_processed	INTEGER;
    params_cursor               INTEGER;
    params_rows_processed       INTEGER;

    l_ret_val                   boolean := true;
    l_all_rule_retval           boolean := false; --to track at least one rule is satisfied or not.

    l_result_type		FUN_RULE_OBJECTS_B.RESULT_TYPE%TYPE;
    l_rule_detail_id		FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
    l_prev_rule_detail_id	FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
    l_operator			FUN_RULE_DETAILS.OPERATOR%TYPE;
    l_rule_object_id		FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE;
    l_flexfield_name		FUN_RULE_OBJECTS_B.FLEXFIELD_NAME%TYPE;
    l_flexfield_app_short_name  FUN_RULE_OBJECTS_B.FLEXFIELD_APP_SHORT_NAME%TYPE;
    l_multiRuleResultFlag       FUN_RULE_OBJECTS_B.MULTI_RULE_RESULT_FLAG%TYPE;
    l_useDefaultValueFlag       FUN_RULE_OBJECTS_B.USE_DEFAULT_VALUE_FLAG%TYPE;

    l_param_name		FUN_RULE_CRIT_PARAMS_B.PARAM_NAME%TYPE;
    l_condition                 FUN_RULE_CRITERIA.CONDITION%TYPE;
    l_param_value		FUN_RULE_CRITERIA.PARAM_VALUE%TYPE;
    l_data_type			FUN_RULE_CRIT_PARAMS_B.DATA_TYPE%TYPE;
    l_case_sensitive		FUN_RULE_CRITERIA.CASE_SENSITIVE_FLAG%TYPE;
    l_criteria_id		FUN_RULE_CRITERIA.CRITERIA_ID%TYPE;

    l_ParamMultiValueList       multi_param_value;

    l_return_result             VARCHAR2(240);
    l_isAnyActiveRule           boolean := false;
    l_count                     NUMBER := 1;
    l_set_result_values         boolean := false;

    RuleResultTable  fun_Rule_Results_Table    := fun_Rule_Results_Table();
--    m_RuleResultTable  RuleResultTableType;

    l_old_moac_access_mode      VARCHAR2(1);
    l_old_org_id                NUMBER;

  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.APPLY_RULE Boolean:->p_application_short_name='||p_application_short_name||'**p_rule_object_name='||p_rule_object_name, FALSE);
   end if;

   /*Rule Object Instance MOAC Changes:
    *    If p_org_id is passed and the set_instance_context is called, then set the MOAC context based on
    *    following logic.
    *    If Product team has not called MO_GLOBAL.INIT then raise an exception.
    *    Else, get the access_mode. If access_mode is not S, then set to S and the passed p_og_id.
    */
    l_old_moac_access_mode := MO_GLOBAL.get_access_mode();
    l_old_org_id           := MO_GLOBAL.get_current_org_id();

    --Does validation and then sets the policy context to S, if its not S and
    --the passed org id value is not same as current org id value.

    IF (m_org_id IS NOT NULL) THEN
       FUN_RULE_MOAC_PKG.SET_MOAC_ACCESS_MODE(m_org_id);
    END IF;

    l_application_id := FUN_RULE_UTILITY_PKG.getApplicationID(p_application_short_name);

    IF(l_application_id IS NULL) THEN
      l_application_id := FND_GLOBAL.RESP_APPL_ID;
    END IF;

    destination_cursor := DBMS_SQL.OPEN_CURSOR;

    --IF Instance Context is set, then append the where clause with an extra bind variable i.e
    --AND INSTANCE_LABEL = :3

    IF (m_instance_context = 'Y') THEN
      g_sRuleDetailSql := g_sRuleDetailMOACSql;
    ELSE
      g_sRuleDetailSql := g_sRuleDetailSql_orig;
    END IF;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.APPLY_RULE Boolean:->g_sRuleDetailSql='||g_sRuleDetailSql, FALSE);
    end if;

    DBMS_SQL.PARSE(destination_cursor, g_sRuleDetailSql,DBMS_SQL.native);
    dbms_sql.bind_variable(destination_cursor , '1' , p_rule_object_name);
    dbms_sql.bind_variable(destination_cursor , '2' , l_application_id);

    IF (m_instance_context = 'Y') THEN
      dbms_sql.bind_variable(destination_cursor , '3' , m_instance_label);
      dbms_sql.bind_variable(destination_cursor , '4' , m_instance_label);
      dbms_sql.bind_variable(destination_cursor , '5' , m_instance_label);

      dbms_sql.bind_variable(destination_cursor , '6' , m_org_id);
      dbms_sql.bind_variable(destination_cursor , '7' , m_org_id);
      dbms_sql.bind_variable(destination_cursor , '8' , m_org_id);

    END IF;


    dbms_sql.define_column(destination_cursor, 1, l_result_type , 30);
    dbms_sql.define_column(destination_cursor, 2, l_rule_detail_id);
    dbms_sql.define_column(destination_cursor, 3, l_operator , 3);
    dbms_sql.define_column(destination_cursor, 4, l_rule_object_id);
    dbms_sql.define_column(destination_cursor, 5, l_flexfield_name , 80);
    dbms_sql.define_column(destination_cursor, 6, l_flexfield_app_short_name , 30);
    dbms_sql.define_column(destination_cursor, 7, l_multiRuleResultFlag , 10);
    dbms_sql.define_column(destination_cursor, 8, l_useDefaultValueFlag , 10);

    l_num_rows_processed := DBMS_SQL.EXECUTE(destination_cursor);

    while(dbms_sql.fetch_rows(destination_cursor) > 0 ) loop
       l_isAnyActiveRule := true;  --i.e Atleast one Rule is present.

       dbms_sql.column_value(destination_cursor, 1, l_result_type);
       dbms_sql.column_value(destination_cursor, 2, l_rule_detail_id );
       dbms_sql.column_value(destination_cursor, 3, l_operator);
       dbms_sql.column_value(destination_cursor, 4, l_rule_object_id);
       dbms_sql.column_value(destination_cursor, 5, l_flexfield_name);
       dbms_sql.column_value(destination_cursor, 6, l_flexfield_app_short_name);
       dbms_sql.column_value(destination_cursor, 7, l_multiRuleResultFlag);
       dbms_sql.column_value(destination_cursor, 8, l_useDefaultValueFlag);
       m_multiRuleResultFlag := l_multiRuleResultFlag;
       m_useDefaultValueFlag := l_useDefaultValueFlag;

       IF (L_OPERATOR = C_OR) THEN
         l_ret_val := false;
       ELSE
         l_ret_val := true;
       END IF;

       params_cursor := DBMS_SQL.OPEN_CURSOR;

       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.APPLY_RULE Boolean:->g_sCriteriaParamSql='||g_sCriteriaParamSql, FALSE);
       end if;

       DBMS_SQL.PARSE(params_cursor, g_sCriteriaParamSql,DBMS_SQL.native);
       dbms_sql.bind_variable(params_cursor , '1' , l_rule_detail_id);
       dbms_sql.bind_variable(params_cursor , '2' , l_rule_detail_id);

       dbms_sql.define_column(params_cursor, 1, l_param_name , 30);
       dbms_sql.define_column(params_cursor, 2, l_condition , 15);
       dbms_sql.define_column(params_cursor, 3, l_param_value , 1024);
       dbms_sql.define_column(params_cursor, 4, l_data_type, 15);
       dbms_sql.define_column(params_cursor, 5, l_case_sensitive, 1);
       dbms_sql.define_column(params_cursor, 6, l_criteria_id);

       params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

       while(dbms_sql.fetch_rows(params_cursor) > 0 ) loop
	       dbms_sql.column_value(params_cursor, 1, l_param_name );
	       dbms_sql.column_value(params_cursor, 2, l_condition );
	       dbms_sql.column_value(params_cursor, 3, l_param_value);
	       dbms_sql.column_value(params_cursor, 4, l_data_type);
	       dbms_sql.column_value(params_cursor, 5, l_case_sensitive);
	       dbms_sql.column_value(params_cursor, 6, l_criteria_id);

               if(l_param_name = 'APPLICATION') then
                 if(NOT containsKey(g_parameter_list,'APPLICATION')) then
                  add_parameter('APPLICATION' , FND_GLOBAL.RESP_APPL_ID);
		 end if;
               end if;

               if(l_param_name =  'RESPONSIBILITY') then
                if(NOT containsKey(g_parameter_list,'RESPONSIBILITY')) then
                  add_parameter('RESPONSIBILITY' , FND_GLOBAL.RESP_ID);
                end if;
               end if;


               /********************************************************************************
                MOAC Handle:
		1) When the product team calls applyRule(), and if the ORGANIZATION parameter is
		   explicitly passed, we should just use that value.
		2) If it is not, then see if the access mode is single. If it is, use that org
		   as the parameter value.
		3) If it is not, then any criteria which uses ORGANIZATION as the parameter
		   fails - always.
               **********************************************************************************/

               if(l_param_name = 'ORGANIZATION') then
                if(NOT containsKey(g_parameter_list,'ORGANIZATION')) then
		   add_parameter('ORGANIZATION' , FUN_RULE_UTILITY_PKG.get_moac_org_id);
                end if;
	       end if;

               if(l_param_name = 'USER') then
                if(NOT containsKey(g_parameter_list,'USER')) then
                  add_parameter('USER' , FND_GLOBAL.USER_ID);
                end if;
               end if;


               getMultiValueParamsArray(l_ParamMultiValueList, l_rule_detail_id, l_criteria_id , l_data_type);

	       IF(l_operator = C_AND) THEN
	         l_ret_val := matchCriteria(l_param_name, l_condition, l_ParamMultiValueList,
                                            l_data_type, g_parameter_list, l_case_sensitive) AND l_ret_val ;
	       ELSIF(l_operator = C_OR) THEN
	         l_ret_val := matchCriteria(l_param_name, l_condition, l_ParamMultiValueList,
                                            l_data_type, g_parameter_list, l_case_sensitive) OR l_ret_val ;
	       END IF;
       end loop;
      DBMS_SQL.CLOSE_CURSOR(params_cursor);

      l_all_rule_retval := l_all_rule_retval OR l_ret_val;

      setResultValues(l_ret_val,
    	              l_isAnyActiveRule,
		      l_rule_object_id,
		      l_result_type,
		      p_rule_object_name,
    		      l_flexfield_name,
 		      l_flexfield_app_short_name,
   		      l_rule_detail_id);


      if(l_multiRuleResultFlag = 'N') then
        if (l_ret_val) then exit; end if;
      else
	--For AR's Multi Rule Result we populate RuleResultObject here.
              if(l_ret_val) then
	        RuleResultTable.extend;
   	        RuleResultTable(l_count) := populateRuleResultObjects;
	        l_count := l_count+1;
              end if;
      end if;

    end loop;

    DBMS_SQL.CLOSE_CURSOR(destination_cursor);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.APPLY_RULE Boolean:->before setResultValues', FALSE);
    end if;

    if(NOT l_all_rule_retval) then    --implies that not a single Rule is satisfied.
      setResultValues(l_ret_val,
    	              l_isAnyActiveRule,
		      l_rule_object_id,
		      l_result_type,
		      p_rule_object_name,
    		      l_flexfield_name,
 		      l_flexfield_app_short_name,
   		      l_rule_detail_id);
    else
        /*In case of Multi Rule Result, we should not make m_noRulesSatisfied as false
         * if at least one result is returned i.e bAllRuleRetVal is true.
         * */
      if(l_multiRuleResultFlag = 'Y') then
        m_noRulesSatisfied := false;
      end if;
    end if;

    --If no Rules are satisfied and use default flag is NOT Y
    --then return false;
    if((m_noRulesSatisfied OR (NOT l_isAnyActiveRule)) AND  m_useDefaultValueFlag <> 'Y') then
	   /*Rule Object Instance MOAC Changes:
	    *    Revert back the access mode and org id to the l_old_acess_mode and l_old_org_id
	    *    And Clear The Instance Context if set.
	    */

	   IF (m_org_id IS NOT NULL) THEN
	     FUN_RULE_MOAC_PKG.SET_MOAC_POLICY_CONTEXT(l_old_moac_access_mode , l_old_org_id , m_org_id);
	   END IF;
           clearInstanceContext;
           return false;
    end if;

    if(l_multiRuleResultFlag = 'Y') then  --For Multi Rule Result Object Type
      if(NOT l_all_rule_retval) then
	        RuleResultTable.extend;
   	        RuleResultTable(l_count) := populateRuleResultObjects;
      end if;
        m_RuleResultTable := RuleResultTable;
    end if;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.APPLY_RULE Boolean', FALSE);
    end if;

    /*Rule Object Instance MOAC Changes:
     *    Revert back the access mode and org id to the l_old_acess_mode and l_old_org_id
     *    And Clear The Instance Context if set.
     */

    IF (m_org_id IS NOT NULL) THEN
      FUN_RULE_MOAC_PKG.SET_MOAC_POLICY_CONTEXT(l_old_moac_access_mode , l_old_org_id , m_org_id);
    END IF;
    clearInstanceContext;
    return true;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.apply_rule BOOLEAN:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(destination_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(destination_cursor);
       END IF;
       IF DBMS_SQL.IS_OPEN(params_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(params_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.APLY_RULE Boolean:->'||SQLERRM, FALSE);
       END IF;

       RAISE;
  END apply_rule;

  FUNCTION apply_rule_wrapper(p_application_short_name IN VARCHAR2, p_rule_object_name IN VARCHAR2)
  RETURN NUMBER
  IS
  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_wrapper', FALSE);
    end if;

     IF (apply_rule(p_application_short_name, p_rule_object_name)) THEN
        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'FUN_RULE_PUB.apply_rule_wrapper-> SuccessFul Rule Evaluation', FALSE);
        end if;

        RETURN 1;
     ELSE
        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'FUN_RULE_PUB.apply_rule_wrapper-> Failed Rule Evaluation', FALSE);
        end if;

        RETURN 0;
     END IF;
  END apply_rule_wrapper;


  FUNCTION populateRuleResultObjects RETURN FUN_RULE_RESULT IS
    l_RuleResultObject   FUN_RULE_RESULT;
  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.populateRuleResultObjects', FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.populateRuleResultObjects:->m_resultValueDataType='||m_resultValueDataType, FALSE);
    end if;

--    l_RuleResultObject := RuleResultObject(m_ruleDetailId);
      IF(m_resultValueDataType = C_NUMERIC) THEN
	      l_RuleResultObject := FUN_RULE_RESULT( get_rule_detail_id,
						     get_string,
						     get_number,
						     null,
						     get_result_application_id,
						     get_rule_name,
						     get_attribute_category,
						     get_attribute1,
						     get_attribute2,
						     get_attribute3,
						     get_attribute4,
						     get_attribute5,
						     get_attribute6,
						     get_attribute7,
						     get_attribute8,
						     get_attribute9,
						     get_attribute10,
						     get_attribute11,
						     get_attribute12,
						     get_attribute13,
						     get_attribute14,
						     get_attribute15,
						     get_message_app_name);

      ELSIF(m_resultValueDataType = C_DATE) THEN
	      l_RuleResultObject := FUN_RULE_RESULT( get_rule_detail_id,
						     get_string,
						     null,
						     get_date,
						     get_result_application_id,
						     get_rule_name,
						     get_attribute_category,
						     get_attribute1,
						     get_attribute2,
						     get_attribute3,
						     get_attribute4,
						     get_attribute5,
						     get_attribute6,
						     get_attribute7,
						     get_attribute8,
						     get_attribute9,
						     get_attribute10,
						     get_attribute11,
						     get_attribute12,
						     get_attribute13,
						     get_attribute14,
						     get_attribute15,
						     get_message_app_name);

      ELSE
	      l_RuleResultObject := FUN_RULE_RESULT( get_rule_detail_id,
						     get_string,
						     null,
						     null,
						     get_result_application_id,
						     get_rule_name,
						     get_attribute_category,
						     get_attribute1,
						     get_attribute2,
						     get_attribute3,
						     get_attribute4,
						     get_attribute5,
						     get_attribute6,
						     get_attribute7,
						     get_attribute8,
						     get_attribute9,
						     get_attribute10,
						     get_attribute11,
						     get_attribute12,
						     get_attribute13,
						     get_attribute14,
						     get_attribute15,
						     get_message_app_name);

	END IF;

        if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.populateRuleResultObjects', FALSE);
        end if;

       return l_RuleResultObject;
  END populateRuleResultObjects;

PROCEDURE setResultValues(p_ret_val IN BOOLEAN,
                         p_isAnyActiveRule IN BOOLEAN,
                         p_rule_object_id IN NUMBER,
                         p_result_type IN VARCHAR2,
                         p_rule_object_name IN VARCHAR2,
                         p_flexfield_name IN VARCHAR2,
                         p_flexfield_app_short_name IN VARCHAR2,
                         p_rule_detail_id IN NUMBER)
  IS
    l_ret_val                   BOOLEAN     := p_ret_val;
    l_isAnyActiveRule           BOOLEAN     := p_isAnyActiveRule;
    l_rule_object_id            NUMBER      := p_rule_object_id;
    l_result_type               VARCHAR2(80):= p_result_type;
    l_rule_object_name          VARCHAR2(80):= p_rule_object_name;
    l_flexfield_name            VARCHAR2(80):= p_flexfield_name;
    l_flexfield_app_short_name  VARCHAR2(80):= p_flexfield_app_short_name;
    l_rule_detail_id            NUMBER      := P_rule_detail_id;
    l_return_result             VARCHAR2(240);

  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues', FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_rule_object_id='||to_char(p_rule_object_id), FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_result_type='||p_result_type, FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_rule_object_name='||p_rule_object_name, FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_result_type='||p_result_type, FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_flexfield_name='||p_flexfield_name, FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_flexfield_app_short_name='||p_flexfield_app_short_name, FALSE);
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->p_rule_detail_id='||to_char(p_rule_detail_id), FALSE);
    end if;

    /*getDFFResultValue returns Result having result value as
     *Attribute Category.
     *Similairy getDFFDefaultValue returns result  having result value as
     *Attribute Category from DFF table having rule_detail_id as -99.
    */

    m_resultValueDataType := getResultValueDataType(p_result_type , p_rule_object_id);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.setResultValues:->m_resultValueDataType='||m_resultValueDataType, FALSE);
    end if;

    --If No Active Rules Are present, then Default Value must be passed.
    if(NOT l_isAnyActiveRule) then

         l_ret_val := false;
         getRuleObjectInfo(p_rule_object_name);
         l_result_type := m_ruleObjectType;
	 l_rule_object_id := m_ruleObjectId;
         l_flexfield_name := m_flexFieldName;
         l_flexfield_app_short_name := m_flexFieldAppShortName;
     end if;

    if(l_ret_val) then
         if(l_result_type = C_MULTIVALUE ) then

           l_return_result := getDFFResultValue(l_rule_detail_id ,
                                               l_flexfield_name,
                        	               l_flexfield_app_short_name);

         else

           l_return_result := getResultValue(l_rule_detail_id,
  		               l_result_type);

         end if;
    else

         m_noRulesSatisfied  := TRUE;

         if(l_result_type = C_MULTIVALUE) then
            l_return_result := getDFFDefaultValue(l_rule_detail_id ,
                                   l_flexfield_name,
 	   	                   l_flexfield_app_short_name);

         else
            l_return_result := getDefaultValue(l_rule_object_id,
                    	       l_result_type);
         end if;

    end if;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.setResultValues', FALSE);
    end if;

END setResultValues;


  FUNCTION checkIfMultiValueResultIsNull RETURN BOOLEAN  IS
     l_bMultiValueResultNull BOOLEAN  := false;
  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.checkIfMultiValueResultIsNull', FALSE);
    end if;

    for  i in 1..15 loop
      l_bMultiValueResultNull := (l_bMultiValueResultNull OR
                                         ( get_attribute_at_index(i) is null OR
					   get_attribute_at_index(i) = '')
					 );
    end loop;
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.checkIfMultiValueResultIsNull', FALSE);
    end if;

    return l_bMultiValueResultNull;
  END checkIfMultiValueResultIsNull;

  FUNCTION get_attribute_at_index(p_Index IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute_at_index:->p_Index='||to_char(p_Index), FALSE);
    end if;

    if (p_Index =1 ) then return get_attribute1;
     elsif (p_Index =2 ) then return get_attribute2;
     elsif (p_Index =3 ) then return get_attribute3;
     elsif (p_Index =4 ) then return get_attribute4;
     elsif (p_Index =5 ) then return get_attribute5;
     elsif (p_Index =6 ) then return get_attribute6;
     elsif (p_Index =7 ) then return get_attribute7;
     elsif (p_Index =8 ) then return get_attribute8;
     elsif (p_Index =9 ) then return get_attribute9;
     elsif (p_Index =10 ) then return get_attribute10;
     elsif (p_Index =11 ) then return get_attribute11;
     elsif (p_Index =12 ) then return get_attribute12;
     elsif (p_Index =13 ) then return get_attribute13;
     elsif (p_Index =14 ) then return get_attribute14;
     elsif (p_Index =15 ) then return get_attribute15;
     else return NULL;
    end if;

  END get_attribute_at_index;

  FUNCTION getResultValueDataType(p_ObjectType IN VARCHAR2 , p_RuleObjectId IN NUMBER) RETURN VARCHAR2 IS
    params_cursor               INTEGER;
    params_rows_processed       INTEGER;

    l_ValueSetType  VARCHAR2(10);

  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getResultValueDataType:->p_ObjectType'||p_ObjectType||'**p_RuleObjectId='||to_char(p_RuleObjectId), FALSE);
    end if;

    if(p_ObjectType IS null OR p_ObjectType = '') then
        return C_STRINGS;

    elsif(C_MESSAGE = p_ObjectType OR C_RICHTEXT = p_ObjectType OR C_MULTIVALUE = p_ObjectType) then
         return C_STRINGS;

    elsif (C_VALUESET = p_ObjectType) then

       params_cursor := DBMS_SQL.OPEN_CURSOR;
       DBMS_SQL.PARSE(params_cursor, g_sValueSetSql,DBMS_SQL.native);
       dbms_sql.bind_variable(params_cursor , '1' , p_RuleObjectId);

       dbms_sql.define_column(params_cursor, 1, l_ValueSetType , 10);

       params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

       if(dbms_sql.fetch_rows(params_cursor) > 0 ) then
          dbms_sql.column_value(params_cursor, 1, l_ValueSetType );
       end if;
     end if;

     DBMS_SQL.CLOSE_CURSOR(params_cursor);

     if( l_ValueSetType = 'C' ) then return C_STRINGS;
     elsif ( l_ValueSetType = 'N' ) then return C_NUMERIC;
     elsif ( l_ValueSetType = 'D' OR l_ValueSetType = 'T' OR l_ValueSetType = 't' OR l_ValueSetType = 'X') then return C_DATE;
     else return C_STRINGS;
     end if;

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getResultValueDataType', FALSE);
    end if;

     return C_STRINGS;
   EXCEPTION

     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getResultValueDataType:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(params_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(params_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_log.message(FND_LOG.LEVEL_EXCEPTION,  'FUN_RULE_PUB.getResultValueDataType:->g_sValueSetSql='||g_sValueSetSql, FALSE);
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getResultValueDataType:->'||SQLERRM, FALSE);
       END IF;

       RAISE;
  END getResultValueDataType;


  PROCEDURE getMultiValueParamsArray(p_multi_param_value OUT NOCOPY multi_param_value,
                                     p_rule_detail_id    IN NUMBER,
				     p_rule_criteria_id  IN NUMBER,
				     p_data_type         IN VARCHAR2) IS

    params_cursor               INTEGER;
    params_rows_processed       INTEGER;

    l_param_value		FUN_RULE_PARAM_VALUES.PARAM_VALUE%TYPE;
    l_counter                   NUMBER := 1;

  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getMultiValueParamsArray', FALSE);
    end if;

       params_cursor := DBMS_SQL.OPEN_CURSOR;
       DBMS_SQL.PARSE(params_cursor, g_sMultiCriteriaParamValueSql,DBMS_SQL.native);
       dbms_sql.bind_variable(params_cursor , '1' , p_rule_detail_id);
       dbms_sql.bind_variable(params_cursor , '2' , p_rule_criteria_id);

       dbms_sql.define_column(params_cursor, 1, l_param_value , 1024);

       params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

       while(dbms_sql.fetch_rows(params_cursor) > 0 ) loop
          dbms_sql.column_value(params_cursor, 1, l_param_value );
          p_multi_param_value(l_counter) := l_param_value;
	  l_counter := l_counter + 1;
       end loop;

      DBMS_SQL.CLOSE_CURSOR(params_cursor);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getMultiValueParamsArray', FALSE);
    end if;

   EXCEPTION

     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getMultiValueParamsArray:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(params_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(params_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getMultiValueParamsArray:->g_sMultiCriteriaParamValueSql='||g_sMultiCriteriaParamValueSql, FALSE);
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getMultiValueParamsArray:->'||SQLERRM, FALSE);
       END IF;
       RAISE;

  END getMultiValueParamsArray;

  FUNCTION matchCriteria(p_ParamName IN VARCHAR2, p_Condition VARCHAR2,
                         multiValueParamsArray IN multi_param_value, p_DataType IN VARCHAR2,
                         critObjectValue IN t_parameter_list, p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS

     l_ret_val		   boolean;
     l_valueToBeCompared   VARCHAR2(240);
  BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.matchCriteria', FALSE);
    end if;

    /*If the condition is IN and NOT_IN that means there exists multiple values.
     * So the retVal must be OR'ed instead of AND'ed
     * */

    IF (p_Condition = C_NOT_IN OR p_Condition = C_IN )   THEN
      l_ret_val := FALSE;
    ELSE
      l_ret_val := TRUE;
    END IF;

    if(ContainsKey(critObjectValue , p_ParamName)) THEN
     l_valueToBeCompared := get(critObjectValue, p_ParamName);
     --MOAC Handling.
     IF (p_ParamName = 'ORGANIZATION' AND l_valueToBeCompared = C_INVALID_ORG) THEN
         RETURN FALSE;
     END IF;

     FOR i in 1..multiValueParamsArray.count LOOP
        if(p_Condition = C_NOT_IN OR p_Condition = C_IN) then
           l_ret_val := isMatched(p_ParamName,p_DataType,p_Condition,multiValueParamsArray(i),l_ValueToBeCompared,p_CaseSensitive) OR l_ret_val ;
        else
           l_ret_val := isMatched(p_ParamName,p_DataType,p_Condition,multiValueParamsArray(i),l_ValueToBeCompared,p_CaseSensitive) AND l_ret_val ;
        end if;

    END LOOP;
     return l_ret_val;
    end if;
    return false;

  END matchCriteria;

FUNCTION  getDFFResultValue(p_RuleDetailId IN NUMBER,p_FlexFieldName IN VARCHAR2,
                            p_FlexFieldAppShortName IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR DFF_CUR(p_FlexFieldName IN VARCHAR2, p_FlexFieldAppShortName IN VARCHAR2) IS
    SELECT DISTINCT FDF.APPLICATION_TABLE_NAME
    FROM   FND_DESCRIPTIVE_FLEXS FDF
    WHERE FDF.DESCRIPTIVE_FLEXFIELD_NAME = p_FlexFieldName
    AND  APPLICATION_ID IN (SELECT APPLICATION_ID FROM FND_APPLICATION_VL WHERE APPLICATION_SHORT_NAME = p_FlexFieldAppShortName);

 source_cursor          INTEGER;
 l_num_rows_processed	INTEGER;

 l_RuleDetailId		NUMBER;
 concatentated_ids	VARCHAR2(250);


 BEGIN

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getDFFResultValue:->p_FlexFieldName='||p_FlexFieldName||'***p_FlexFieldAppShortName='||p_FlexFieldAppShortName, FALSE);
    end if;

   for i in DFF_CUR(p_FlexFieldName, p_FlexFieldAppShortName) loop
      sDFFTableName := i.application_table_name;
   end loop;

   -- Prepare a cursor to select from the source table:
  source_cursor := dbms_sql.open_cursor;

  /*If the Rule Object is an instance, then query the DFF table with RULE_OBJECT_ID as well.*/

  if(m_instance_context = 'Y') then
    DBMS_SQL.PARSE(source_cursor,
                 'SELECT DFF.RULE_DETAIL_ID, ATTRIBUTE_CATEGORY,	ATTRIBUTE1,	ATTRIBUTE2,
                  ATTRIBUTE3,	ATTRIBUTE4,	ATTRIBUTE5,	ATTRIBUTE6,	ATTRIBUTE7,
                  ATTRIBUTE8,	ATTRIBUTE9,	ATTRIBUTE10,	ATTRIBUTE11,	ATTRIBUTE12,
                  ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15 , RULE_NAME , RESULT_APPLICATION_ID
                  FROM '|| sDFFTableName ||' DFF , FUN_RULE_DETAILS FRD
                  WHERE DFF.RULE_DETAIL_ID = :1 AND DFF.RULE_OBJECT_ID = :2 AND  DFF.RULE_DETAIL_ID = FRD.RULE_DETAIL_ID'
		 ,  DBMS_SQL.native);
  else
      DBMS_SQL.PARSE(source_cursor,
                 'SELECT DFF.RULE_DETAIL_ID, ATTRIBUTE_CATEGORY,	ATTRIBUTE1,	ATTRIBUTE2,
                  ATTRIBUTE3,	ATTRIBUTE4,	ATTRIBUTE5,	ATTRIBUTE6,	ATTRIBUTE7,
                  ATTRIBUTE8,	ATTRIBUTE9,	ATTRIBUTE10,	ATTRIBUTE11,	ATTRIBUTE12,
                  ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15 , RULE_NAME , RESULT_APPLICATION_ID
                  FROM '|| sDFFTableName ||' DFF , FUN_RULE_DETAILS FRD
                  WHERE DFF.RULE_DETAIL_ID = :1 AND  DFF.RULE_DETAIL_ID = FRD.RULE_DETAIL_ID'
		 ,  DBMS_SQL.native);
  end if;

  dbms_sql.bind_variable(source_cursor , '1' , p_RuleDetailId);

  if(m_instance_context = 'Y') then
      dbms_sql.bind_variable(source_cursor , '2' , m_ruleObjectId);
  end if;

  DBMS_SQL.DEFINE_COLUMN(source_cursor, 1, l_RuleDetailId);     DBMS_SQL.DEFINE_COLUMN(source_cursor, 2, m_attributeCategory, 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 3, m_attribute1 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 4, m_attribute2 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 5, m_attribute3 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 6, m_attribute4 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 7, m_attribute5 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 8, m_attribute6 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 9, m_attribute7 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 10, m_attribute8 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 11, m_attribute9 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 12, m_attribute10 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 13, m_attribute11 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 14, m_attribute12 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 15, m_attribute13 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 16, m_attribute14 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 17, m_attribute15 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 18, m_ruleName , 80);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 19, m_resultApplicationId);


  l_num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

  while(dbms_sql.fetch_rows(source_cursor) > 0 ) loop
    DBMS_SQL.column_value(source_cursor, 1, l_RuleDetailId);     DBMS_SQL.column_value(source_cursor, 2, m_attributeCategory);
    DBMS_SQL.column_value(source_cursor, 3, m_attribute1); DBMS_SQL.column_value(source_cursor, 4, m_attribute2);
    DBMS_SQL.column_value(source_cursor, 5, m_attribute3); DBMS_SQL.column_value(source_cursor, 6, m_attribute4);
    DBMS_SQL.column_value(source_cursor, 7, m_attribute5); DBMS_SQL.column_value(source_cursor, 8, m_attribute6);
    DBMS_SQL.column_value(source_cursor, 9, m_attribute7); DBMS_SQL.column_value(source_cursor, 10, m_attribute8);
    DBMS_SQL.column_value(source_cursor, 11, m_attribute9); DBMS_SQL.column_value(source_cursor, 12, m_attribute10);
    DBMS_SQL.column_value(source_cursor, 13, m_attribute11); DBMS_SQL.column_value(source_cursor, 14, m_attribute12);
    DBMS_SQL.column_value(source_cursor, 15, m_attribute13); DBMS_SQL.column_value(source_cursor, 16, m_attribute14);
    DBMS_SQL.column_value(source_cursor, 17, m_attribute15);
    DBMS_SQL.column_value(source_cursor, 18, m_ruleName);
    DBMS_SQL.column_value(source_cursor, 19, m_resultApplicationId);

    m_ruleDetailId := l_RuleDetailId;
--    m_resultValue := m_attributeCategory;
   fnd_flex_descval.set_column_value('ATTRIBUTE_CATEGORY', m_attributeCategory);
   fnd_flex_descval.set_column_value('ATTRIBUTE1', m_attribute1);
   fnd_flex_descval.set_column_value('ATTRIBUTE2', m_attribute2);
   fnd_flex_descval.set_column_value('ATTRIBUTE3', m_attribute3);
   fnd_flex_descval.set_column_value('ATTRIBUTE4', m_attribute4);
   fnd_flex_descval.set_column_value('ATTRIBUTE5', m_attribute5);
   fnd_flex_descval.set_column_value('ATTRIBUTE6', m_attribute6);
   fnd_flex_descval.set_column_value('ATTRIBUTE7', m_attribute7);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', m_attribute8);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', m_attribute9);
   fnd_flex_descval.set_column_value('ATTRIBUTE10', m_attribute10);
   fnd_flex_descval.set_column_value('ATTRIBUTE11', m_attribute11);
   fnd_flex_descval.set_column_value('ATTRIBUTE12', m_attribute12);
   fnd_flex_descval.set_column_value('ATTRIBUTE13', m_attribute13);
   fnd_flex_descval.set_column_value('ATTRIBUTE14', m_attribute14);
   fnd_flex_descval.set_column_value('ATTRIBUTE15', m_attribute15);


   IF  FND_FLEX_DESCVAL.validate_desccols(p_FlexFieldAppShortName, p_FlexFieldName) THEN
     IF (NVL(LENGTH(FND_FLEX_DESCVAL.concatenated_ids),0) > 1) THEN
        m_resultValue := FND_FLEX_DESCVAL.concatenated_ids;
     ELSE
        m_resultValue := FND_FLEX_DESCVAL.concatenated_values;
     END IF;
   END IF;

  end loop;

  DBMS_SQL.CLOSE_CURSOR(source_cursor);

  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getDFFResultValue', FALSE);
  end if;

  return m_attributeCategory;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getDFFResultValue:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getDFFResultValue:->'||SQLERRM, FALSE);
       END IF;

       RAISE;

END getDFFResultValue;


FUNCTION  getDFFDefaultValue(p_RuleDetailId IN NUMBER,
                              p_FlexFieldName IN VARCHAR2,
                              p_FlexFieldAppShortName IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR DFF_CUR(p_FlexFieldName IN VARCHAR2, p_FlexFieldAppShortName IN VARCHAR2) IS
    SELECT DISTINCT FDF.APPLICATION_TABLE_NAME
    FROM   FND_DESCRIPTIVE_FLEXS FDF
    WHERE FDF.DESCRIPTIVE_FLEXFIELD_NAME = p_FlexFieldName
    AND  APPLICATION_ID IN (SELECT APPLICATION_ID FROM FND_APPLICATION_VL WHERE APPLICATION_SHORT_NAME = p_FlexFieldAppShortName);

 l_DFFTableName     VARCHAR2(30);

 source_cursor          INTEGER;
 l_num_rows_processed	INTEGER;


 params_cursor      INTEGER;
 params_ignore      INTEGER;
 l_RuleDetailId     NUMBER;
 concatentated_ids  VARCHAR2(250);


 BEGIN

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getDFFDefaultValue:->p_FlexFieldName='||p_FlexFieldName||'***p_FlexFieldAppShortName='||p_FlexFieldAppShortName, FALSE);
    end if;

   for i in DFF_CUR(p_FlexFieldName, p_FlexFieldAppShortName) loop
      sDFFTableName := i.application_table_name;
   end loop;

   -- Prepare a cursor to select from the source table:
   source_cursor := dbms_sql.open_cursor;

  /*If the Rule Object is an instance, then query the DFF table with RULE_OBJECT_ID as well.*/

  if(m_instance_context = 'Y') then
     DBMS_SQL.PARSE(source_cursor,
                 'SELECT DFF.RULE_DETAIL_ID, ATTRIBUTE_CATEGORY,	ATTRIBUTE1,	ATTRIBUTE2,
                  ATTRIBUTE3,	ATTRIBUTE4,	ATTRIBUTE5,	ATTRIBUTE6,	ATTRIBUTE7,
                  ATTRIBUTE8,	ATTRIBUTE9,	ATTRIBUTE10,	ATTRIBUTE11,	ATTRIBUTE12,
                  ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
                  FROM '|| sDFFTableName ||' DFF
                  WHERE DFF.RULE_DETAIL_ID = -99 AND RULE_OBJECT_ID = :1'
		 ,  DBMS_SQL.native);
  else
     DBMS_SQL.PARSE(source_cursor,
                 'SELECT DFF.RULE_DETAIL_ID, ATTRIBUTE_CATEGORY,	ATTRIBUTE1,	ATTRIBUTE2,
                  ATTRIBUTE3,	ATTRIBUTE4,	ATTRIBUTE5,	ATTRIBUTE6,	ATTRIBUTE7,
                  ATTRIBUTE8,	ATTRIBUTE9,	ATTRIBUTE10,	ATTRIBUTE11,	ATTRIBUTE12,
                  ATTRIBUTE13, ATTRIBUTE14, ATTRIBUTE15
                  FROM '|| sDFFTableName ||' DFF
                  WHERE DFF.RULE_DETAIL_ID = -99 '
		 ,  DBMS_SQL.native);

  end if;

  if(m_instance_context = 'Y') then
      dbms_sql.bind_variable(source_cursor , '1' , m_ruleObjectId);
  end if;


  DBMS_SQL.DEFINE_COLUMN(source_cursor, 1, l_RuleDetailId);     DBMS_SQL.DEFINE_COLUMN(source_cursor, 2, m_attributeCategory, 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 3, m_attribute1 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 4, m_attribute2 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 5, m_attribute3 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 6, m_attribute4 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 7, m_attribute5 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 8, m_attribute6 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 9, m_attribute7 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 10, m_attribute8 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 11, m_attribute9 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 12, m_attribute10 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 13, m_attribute11 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 14, m_attribute12 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 15, m_attribute13 , 150); DBMS_SQL.DEFINE_COLUMN(source_cursor, 16, m_attribute14 , 150);
  DBMS_SQL.DEFINE_COLUMN(source_cursor, 17, m_attribute15 , 150);

  l_num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

  while(dbms_sql.fetch_rows(source_cursor) > 0 ) loop
    DBMS_SQL.column_value(source_cursor, 1, l_RuleDetailId);     DBMS_SQL.column_value(source_cursor, 2, m_attributeCategory);
    DBMS_SQL.column_value(source_cursor, 3, m_attribute1); DBMS_SQL.column_value(source_cursor, 4, m_attribute2);
    DBMS_SQL.column_value(source_cursor, 5, m_attribute3); DBMS_SQL.column_value(source_cursor, 6, m_attribute4);
    DBMS_SQL.column_value(source_cursor, 7, m_attribute5); DBMS_SQL.column_value(source_cursor, 8, m_attribute6);
    DBMS_SQL.column_value(source_cursor, 9, m_attribute7); DBMS_SQL.column_value(source_cursor, 10, m_attribute8);
    DBMS_SQL.column_value(source_cursor, 11, m_attribute9); DBMS_SQL.column_value(source_cursor, 12, m_attribute10);
    DBMS_SQL.column_value(source_cursor, 13, m_attribute11); DBMS_SQL.column_value(source_cursor, 14, m_attribute12);
    DBMS_SQL.column_value(source_cursor, 15, m_attribute13); DBMS_SQL.column_value(source_cursor, 16, m_attribute14);
    DBMS_SQL.column_value(source_cursor, 17, m_attribute15);

    m_ruleDetailId := -99;
    m_ruleName := 'Default Result';
--    m_resultValue := m_attributeCategory;
   fnd_flex_descval.set_column_value('ATTRIBUTE_CATEGORY', m_attributeCategory);
   fnd_flex_descval.set_column_value('ATTRIBUTE1', m_attribute1);
   fnd_flex_descval.set_column_value('ATTRIBUTE2', m_attribute2);
   fnd_flex_descval.set_column_value('ATTRIBUTE3', m_attribute3);
   fnd_flex_descval.set_column_value('ATTRIBUTE4', m_attribute4);
   fnd_flex_descval.set_column_value('ATTRIBUTE5', m_attribute5);
   fnd_flex_descval.set_column_value('ATTRIBUTE6', m_attribute6);
   fnd_flex_descval.set_column_value('ATTRIBUTE7', m_attribute7);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', m_attribute8);
   fnd_flex_descval.set_column_value('ATTRIBUTE8', m_attribute9);
   fnd_flex_descval.set_column_value('ATTRIBUTE10', m_attribute10);
   fnd_flex_descval.set_column_value('ATTRIBUTE11', m_attribute11);
   fnd_flex_descval.set_column_value('ATTRIBUTE12', m_attribute12);
   fnd_flex_descval.set_column_value('ATTRIBUTE13', m_attribute13);
   fnd_flex_descval.set_column_value('ATTRIBUTE14', m_attribute14);
   fnd_flex_descval.set_column_value('ATTRIBUTE15', m_attribute15);

   IF  FND_FLEX_DESCVAL.validate_desccols(p_FlexFieldAppShortName, p_FlexFieldName) THEN
     IF (NVL(LENGTH(FND_FLEX_DESCVAL.concatenated_ids),0) > 1) THEN
        m_resultValue := FND_FLEX_DESCVAL.concatenated_ids;
     ELSE
        m_resultValue := FND_FLEX_DESCVAL.concatenated_values;
     END IF;
   END IF;

  end loop;

  DBMS_SQL.CLOSE_CURSOR(source_cursor);

  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getDFFDefaultValue', FALSE);
  end if;

  return m_resultValue;

  EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getDFFDefaultValue:->'||SQLERRM, FALSE);
       END IF;

       RAISE;

END getDFFDefaultValue;


FUNCTION getResultValue(p_ruleDetailId IN NUMBER, p_ObjectType IN VARCHAR2) RETURN VARCHAR2
IS
 source_cursor			  INTEGER;
 l_num_rows_processed             INTEGER;

 l_rule_detail_id		NUMBER;
 l_result_value			VARCHAR2(1024);
 l_result_application_id	NUMBER;
 l_rule_name			VARCHAR2(30);

BEGIN
  if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getResultValue:->p_ruleDetailId='||to_char(p_ruleDetailId)||'***p_ObjectType='||p_ObjectType, FALSE);
  end if;

    source_cursor := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE(source_cursor,   g_sResultValuesSql, DBMS_SQL.native);
    dbms_sql.bind_variable(source_cursor , '1' , p_ruleDetailId);

    dbms_sql.define_column(source_cursor, 1, l_rule_detail_id);
    dbms_sql.define_column(source_cursor, 2, l_result_value , 1024);
    dbms_sql.define_column(source_cursor, 3, l_result_application_id);
    dbms_sql.define_column(source_cursor, 4, l_rule_name , 30);

    l_num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

    while(dbms_sql.fetch_rows(source_cursor) > 0 ) loop
       dbms_sql.column_value(source_cursor, 1, l_rule_detail_id);
       dbms_sql.column_value(source_cursor, 2, l_result_value);
       dbms_sql.column_value(source_cursor, 3, l_result_application_id);
       dbms_sql.column_value(source_cursor, 4, l_rule_name);

       m_ruleDetailId := l_rule_detail_id;
       m_resultApplicationId := l_result_application_id;
       m_resultValue := l_result_value;
       m_ruleName := l_rule_name;
       exit;
    end loop;

    DBMS_SQL.CLOSE_CURSOR(source_cursor);

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getResultValue', FALSE);
    end if;

    return m_resultValue;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getResultValue:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getResultValue:->'||SQLERRM, FALSE);
       END IF;

       RAISE;

END getResultValue;


FUNCTION getDefaultValue(p_ruleObjectId IN NUMBER, p_ObjectType IN VARCHAR2) RETURN VARCHAR2
IS
 source_cursor			INTEGER;
 l_num_rows_processed		INTEGER;

 l_rule_detail_id		NUMBER;
 l_default_value		VARCHAR2(1024);
 l_default_application_id	NUMBER;

BEGIN

    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getDefaultValue', FALSE);
    end if;

  /*Assumption : For default value, Rule_Detail_Id = -99
   *                                Rule name = "Default Result"
   */

   source_cursor := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE(source_cursor,   g_sDefaultValuesSql, DBMS_SQL.native);
   dbms_sql.bind_variable(source_cursor , '1' , p_ruleObjectId);

   dbms_sql.define_column(source_cursor, 1, l_default_value , 1024);
   dbms_sql.define_column(source_cursor, 2, l_default_application_id);

   l_num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

   while(dbms_sql.fetch_rows(source_cursor) > 0 ) loop
      dbms_sql.column_value(source_cursor, 1, l_default_value);
      dbms_sql.column_value(source_cursor, 2, l_default_application_id);

      m_ruleDetailId := -99;
      m_resultApplicationId := l_default_application_id;
      m_resultValue := l_default_value;
      m_ruleName := 'Default Result';
      exit;
   end loop;

   DBMS_SQL.CLOSE_CURSOR(source_cursor);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getDefaultValue', FALSE);
   end if;

   return m_resultValue;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getDefaultValue:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getDefaultValue:->'||SQLERRM, FALSE);
       END IF;

       RAISE;

END getDefaultValue;

PROCEDURE getRuleObjectInfo(p_RuleObjectName IN VARCHAR2) IS
   source_cursor		INTEGER;
   l_num_rows_processed		INTEGER;

BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getRuleObjectInfo:->p_RuleObjectName='||p_RuleObjectName, FALSE);
   end if;

    --IF Instance Context is set, then append the where clause with an extra bind variable i.e
    --AND INSTANCE_LABEL = :2

    IF (m_instance_context = 'Y') THEN
	g_sRuleObjectSql := g_sRuleObjectMOACSql;
    ELSE
      g_sRuleObjectSql := g_sRuleObjectSql_orig;
    END IF;

    m_ruleObjectType := null;
    m_ruleObjectId := 0;
    m_flexFieldName := null;
    m_flexFieldAppShortName := null;

    source_cursor := DBMS_SQL.OPEN_CURSOR;

    DBMS_SQL.PARSE(source_cursor,   g_sRuleObjectSql, DBMS_SQL.native);
    dbms_sql.bind_variable(source_cursor , '1' , p_RuleObjectName);

    IF (m_instance_context = 'Y') THEN
      dbms_sql.bind_variable(source_cursor , '2' , m_instance_label);
      dbms_sql.bind_variable(source_cursor , '3' , m_instance_label);
      dbms_sql.bind_variable(source_cursor , '4' , m_instance_label);

      dbms_sql.bind_variable(source_cursor , '5' , m_org_id);
      dbms_sql.bind_variable(source_cursor , '6' , m_org_id);
      dbms_sql.bind_variable(source_cursor , '7' , m_org_id);
    END IF;

    dbms_sql.define_column(source_cursor, 1, m_ruleObjectType , 15);
    dbms_sql.define_column(source_cursor, 2, m_ruleObjectId);
    dbms_sql.define_column(source_cursor, 3, m_flexFieldName , 30);
    dbms_sql.define_column(source_cursor, 4, m_flexFieldAppShortName , 10);

    l_num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

    while(dbms_sql.fetch_rows(source_cursor) > 0 ) loop
      dbms_sql.column_value(source_cursor, 1, m_ruleObjectType);
      dbms_sql.column_value(source_cursor, 2, m_ruleObjectId);
      dbms_sql.column_value(source_cursor, 3, m_flexFieldName);
      dbms_sql.column_value(source_cursor, 4, m_flexFieldAppShortName);

      exit;
    end loop;

    DBMS_SQL.CLOSE_CURSOR(source_cursor);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.getRuleObjectInfo', FALSE);
   end if;

  EXCEPTION


     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getRuleObjectInfo:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getRuleObjectInfo:->g_sRuleObjectSql='||g_sRuleObjectSql, FALSE);
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.getRuleObjectInfo:->'||SQLERRM, FALSE);
       END IF;
       RAISE;

 END getRuleObjectInfo;

FUNCTION ContainsKey(critObjectValue IN t_parameter_list,
                     p_ParamName  IN VARCHAR2) RETURN BOOLEAN IS
 BEGIN
   FOR i in 1..critObjectValue.count LOOP
     IF(critObjectValue(i).name = p_ParamName) THEN
       RETURN TRUE;
     END IF;
   END LOOP;
   RETURN FALSE;
 END ContainsKey;

FUNCTION get(critObjectValue IN t_parameter_list,
              p_ParamName  IN VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
   FOR i in 1..critObjectValue.count LOOP
    IF(critObjectValue(i).name = p_ParamName) THEN
       RETURN critObjectValue(i).value;
     END IF;
   END LOOP;
   RETURN NULL;
 END get;

FUNCTION getIndex(critObjectValue IN t_parameter_list,
                  p_ParamName  IN VARCHAR2) RETURN NUMBER IS
 BEGIN
   FOR i in 1..critObjectValue.count LOOP
    IF(critObjectValue(i).name = p_ParamName) THEN
       RETURN i;
     END IF;
   END LOOP;
   RETURN 0;
 END getIndex;


FUNCTION isMatched(p_ParamName VARCHAR2, p_DataType VARCHAR2,
                     p_Condition VARCHAR2, p_ParamValue VARCHAR2,
                     p_ValueToBeCompared  VARCHAR2,
		     p_CaseSensitive VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatched:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatched:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatched:->p_Condition='||p_Condition, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatched:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatched:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatched:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

    IF p_Condition = C_EMPTY  THEN
        RETURN (isMatchedEmpty(p_ValueToBeCompared));
    ELSIF (p_Condition IS null OR p_Condition = '' OR
           p_ParamValue IS null OR p_ParamValue = '' OR
     	   p_ValueToBeCompared IS null OR p_ValueToBeCompared = '') THEN
	RETURN false;
    ELSIF p_Condition = C_LIKE  THEN
        RETURN (isMatchedLikeContain(p_ParamName, p_DataType, p_ParamValue,
	                             p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_EQUALS  THEN
        RETURN (isMatchedEquals(p_ParamName, p_DataType, p_ParamValue,
                                p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_IN  THEN
        RETURN (isMatchedEquals(p_ParamName, p_DataType, p_ParamValue,
                                p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_NOT_EQUALS  THEN
        RETURN (isMatchedNotEquals(p_ParamName, p_DataType, p_ParamValue,
                                   p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_NOT_IN  THEN
        RETURN (isMatchedNotEquals(p_ParamName, p_DataType, p_ParamValue,
                                   p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_GREATER_THAN  THEN
        RETURN (isMatchedGreater(p_ParamName, p_DataType, p_ParamValue,
                                 p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_LESSER_THAN  THEN
        RETURN (isMatchedLesser(p_ParamName, p_DataType, p_ParamValue,
                                p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_GREATER_THAN_EQUAL  THEN
        RETURN (isMatchedGreaterEqual(p_ParamName, p_DataType, p_ParamValue,
 	                              p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_LESSER_THAN_EQUAL  THEN
        RETURN (isMatchedLesserEqual(p_ParamName, p_DataType, p_ParamValue,
	                             p_ValueToBeCompared , p_CaseSensitive));
    ELSIF p_Condition = C_CONTAINS  THEN
        RETURN (isMatchedLikeContain(p_ParamName, p_DataType, p_ParamValue,
	                             p_ValueToBeCompared , p_CaseSensitive));
    END IF;

  END isMatched;

  FUNCTION getComparedData(p_Obj1 IN VARCHAR2, p_Obj2 IN VARCHAR2,
                           p_DataType IN VARCHAR2, p_CaseSensitive IN VARCHAR2) RETURN NUMBER IS

     l_Obj1		 VARCHAR2(300);
     l_Obj2		 VARCHAR2(300);
     l_DataType		 VARCHAR2(30);
     l_CaseSensitive     VARCHAR2(1);
  BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getComparedData', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getComparedData:->p_Obj1='||p_Obj1, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getComparedData:->p_Obj2='||p_Obj2, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getComparedData:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.getComparedData:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

     IF(p_Obj1 IS NULL OR p_Obj2 IS NULL OR p_Obj1 = '' OR p_Obj2 = '') THEN
      return -1;
     END IF;

     IF(p_DataType IS NULL OR p_DataType = '') THEN
      l_DataType := C_STRINGS;
     ELSE
      l_DataType := p_DataType;
     END IF;

     IF(p_CaseSensitive IS NULL OR p_CaseSensitive = '') THEN
      l_CaseSensitive := C_NO;
     ELSE
      l_CaseSensitive := p_CaseSensitive;
     END IF;

     IF(p_DataType = C_STRINGS AND p_CaseSensitive = C_NO) THEN
        l_Obj1 := UPPER(p_Obj1);
        l_Obj2 := UPPER(p_Obj2);
     ELSE
        l_Obj1 := p_Obj1;
        l_Obj2 := p_Obj2;
     END IF;

     IF (l_DataType = C_STRINGS) THEN
       RETURN (compareTo(l_Obj1, l_Obj2 , l_DataType));
     ELSIF (l_DataType = C_NUMERIC) THEN
       RETURN (compareTo(l_Obj1, l_Obj2 , l_DataType));
     ELSIF (l_DataType = C_DATE) THEN
       RETURN (compareTo(l_Obj1, l_Obj2 , l_DataType));
     END IF;

     RETURN -1;
  END getComparedData;

  FUNCTION compareTo(p_Obj1 IN VARCHAR2, p_Obj2 IN VARCHAR2, p_DataType IN VARCHAR2)
              RETURN NUMBER IS

     l_Obj1		 VARCHAR2(300);
     l_Obj2		 VARCHAR2(300);

  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.compareTo', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.compareTo:->p_Obj1='||p_Obj1, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.compareTo:->p_Obj2='||p_Obj2, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.compareTo:->p_DataType='||p_DataType, FALSE);
   end if;

    l_Obj1 := p_Obj1;  l_Obj2 := p_Obj2;

    IF(l_Obj1 IS NULL OR l_Obj2 IS NULL OR l_Obj1 = '' OR l_Obj2 = '') THEN
      return -1;
    END IF;

--Date is stored in the DB as RRRR/MM/DD HH:MI:SS format

   IF(p_DataType = C_NUMERIC) THEN
    IF(FND_NUMBER.CANONICAL_TO_NUMBER(l_Obj1) > FND_NUMBER.CANONICAL_TO_NUMBER(l_Obj2))THEN
      RETURN 1;
    ELSIF(FND_NUMBER.CANONICAL_TO_NUMBER(l_Obj1) < FND_NUMBER.CANONICAL_TO_NUMBER(l_Obj2))THEN
      RETURN -1;
    ELSIF(FND_NUMBER.CANONICAL_TO_NUMBER(l_Obj1) = FND_NUMBER.CANONICAL_TO_NUMBER(l_Obj2))THEN
      RETURN 0;
    END IF;
   ELSIF (p_DataType = C_DATE) THEN
    IF(FND_DATE.CANONICAL_TO_DATE(l_Obj1) > FND_DATE.CANONICAL_TO_DATE(l_Obj2))THEN
      RETURN 1;
    ELSIF(FND_DATE.CANONICAL_TO_DATE(l_Obj1) < FND_DATE.CANONICAL_TO_DATE(l_Obj2))THEN
      RETURN -1;
    ELSIF(FND_DATE.CANONICAL_TO_DATE(l_Obj1) = FND_DATE.CANONICAL_TO_DATE(l_Obj2))THEN
      RETURN 0;
    END IF;
   ELSE
    IF(l_Obj1 > l_Obj2)THEN
      RETURN 1;
    ELSIF(l_Obj1 < l_Obj2)THEN
      RETURN -1;
    ELSIF(l_Obj1 = l_Obj2)THEN
      RETURN 0;
    END IF;
   END IF;
    return -1;
  END compareTo;


  FUNCTION isMatchedLikeContain(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                                p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
				p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS

   l_ValueToBeCompared		VARCHAR2(240);
   l_ParamValue			VARCHAR2(240);

  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLikeContain', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLikeContain:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLikeContain:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLikeContain:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLikeContain:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLikeContain:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

     IF (p_CaseSensitive = C_NO) THEN
        l_ValueToBeCompared := UPPER(p_ValueToBeCompared);
        l_ParamValue := UPPER(p_ParamValue);
     ELSE
        l_ValueToBeCompared := p_ValueToBeCompared;
        l_ParamValue := p_ParamValue;
     END IF;

     IF (INSTR(p_ValueToBeCompared , p_ParamValue) > 0 ) THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
     END IF;
  END isMatchedLikeContain;

  FUNCTION isMatchedEmpty(p_ValueToBeCompared IN VARCHAR2) RETURN BOOLEAN IS

   l_ValueToBeCompared		VARCHAR2(240);
   l_ParamValue			VARCHAR2(240);

  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEmpty', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEmpty:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
   end if;

     IF(p_ValueToBeCompared IS NULL or p_ValueToBeCompared = '') THEN
       RETURN TRUE;
     ELSE
       RETURN FALSE;
     END IF;
  END isMatchedEmpty;

  FUNCTION isMatchedEquals(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                           p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
		  	   p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEquals', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEquals:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEquals:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEquals:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEquals:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedEquals:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;


     IF (getComparedData(p_ValueToBeCompared, p_ParamValue, p_DataType , p_CaseSensitive) = 0 ) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END isMatchedEquals;

  FUNCTION isMatchedNotEquals(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                              p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
		  	      p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedNotEquals', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedNotEquals:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedNotEquals:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedNotEquals:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedNotEquals:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedNotEquals:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

     IF (getComparedData(p_ValueToBeCompared, p_ParamValue, p_DataType , p_CaseSensitive) <> 0 ) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END isMatchedNotEquals;

  FUNCTION isMatchedGreater(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                            p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
		  	    p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreater', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreater:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreater:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreater:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreater:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreater:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

     IF (getComparedData(p_ValueToBeCompared, p_ParamValue, p_DataType , p_CaseSensitive) > 0 ) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END isMatchedGreater;

  FUNCTION isMatchedLesser(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                           p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
		  	   p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesser', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesser:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesser:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesser:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesser:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesser:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

     IF (getComparedData(p_ValueToBeCompared, p_ParamValue, p_DataType , p_CaseSensitive) < 0 ) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END isMatchedLesser;

  FUNCTION isMatchedGreaterEqual(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                                 p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
 	     	  	         p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreaterEqual', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreaterEqual:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreaterEqual:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreaterEqual:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreaterEqual:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedGreaterEqual:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;


     IF (getComparedData(p_ValueToBeCompared, p_ParamValue, p_DataType , p_CaseSensitive) >= 0 ) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END isMatchedGreaterEqual;

  FUNCTION isMatchedLesserEqual(p_ParamName IN VARCHAR2, p_DataType IN VARCHAR2,
                                p_ParamValue IN VARCHAR2,p_ValueToBeCompared IN VARCHAR2,
	   	  	        p_CaseSensitive IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesserEqual', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesserEqual:->p_ParamName='||p_ParamName, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesserEqual:->p_DataType='||p_DataType, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesserEqual:->p_ParamValue='||p_ParamValue, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesserEqual:->p_ValueToBeCompared='||p_ValueToBeCompared, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isMatchedLesserEqual:->p_CaseSensitive='||p_CaseSensitive, FALSE);
   end if;

     IF (getComparedData(p_ValueToBeCompared, p_ParamValue, p_DataType , p_CaseSensitive) <= 0 ) THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END isMatchedLesserEqual;

  FUNCTION get_rule_detail_id RETURN NUMBER IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_rule_detail_id', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_rule_detail_id:->m_ruleDetailId'||to_char(m_ruleDetailId), FALSE);
   end if;

    return m_ruleDetailId;

  END get_rule_detail_id;

  FUNCTION get_result_application_id RETURN NUMBER IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_result_application_id', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_result_application_id:->m_resultApplicationId'||to_char(m_resultApplicationId), FALSE);
   end if;

    return m_resultApplicationId;

  END get_result_application_id;

  FUNCTION get_rule_name RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_rule_name', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_rule_name:->m_ruleName'||m_ruleName, FALSE);
   end if;

    return m_ruleName;

  END get_rule_name;

  FUNCTION get_attribute_category RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute_category', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute_category:->m_attributeCategory'||m_attributeCategory, FALSE);
   end if;

    return m_attributeCategory;

  END get_attribute_category;

  FUNCTION get_attribute1 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute1', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute1:->m_attribute1='||m_attribute1, FALSE);
   end if;

    return m_attribute1;

  END get_attribute1;

  FUNCTION get_attribute2 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute2', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute2:->m_attribute2='||m_attribute2, FALSE);
   end if;


    return m_attribute2;

  END get_attribute2;

  FUNCTION get_attribute3 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute3', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute3:->m_attribute3='||m_attribute3, FALSE);
   end if;


    return m_attribute3;

  END get_attribute3;

  FUNCTION get_attribute4 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute4', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute4:->m_attribute4='||m_attribute4, FALSE);
   end if;


    return m_attribute4;

  END get_attribute4;

  FUNCTION get_attribute5 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute5', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute5:->m_attribute1='||m_attribute5, FALSE);
   end if;


    return m_attribute5;

  END get_attribute5;

  FUNCTION get_attribute6 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute6', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute6:->m_attribute6='||m_attribute6, FALSE);
   end if;


    return m_attribute6;
  END get_attribute6;

  FUNCTION get_attribute7 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute7', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute7:->m_attribute7='||m_attribute7, FALSE);
   end if;


    return m_attribute7;
  END get_attribute7;

  FUNCTION get_attribute8 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute8', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute8:->m_attribute8='||m_attribute8, FALSE);
   end if;


    return m_attribute8;
  END get_attribute8;

  FUNCTION get_attribute9 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute9', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute9:->m_attribute9='||m_attribute9, FALSE);
   end if;


    return m_attribute9;
  END get_attribute9;

  FUNCTION get_attribute10 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute10', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute10:->m_attribute10='||m_attribute10, FALSE);
   end if;


    return m_attribute10;

  END get_attribute10;

  FUNCTION get_attribute11 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute11', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute11:->m_attribute11='||m_attribute11, FALSE);
   end if;


    return m_attribute11;
  END get_attribute11;

  FUNCTION get_attribute12 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute12', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute12:->m_attribute12'||m_attribute12, FALSE);
   end if;


    return m_attribute12;
  END get_attribute12;

  FUNCTION get_attribute13 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute13', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute13:->m_attribute13='||m_attribute13, FALSE);
   end if;


    return m_attribute13;
  END get_attribute13;

  FUNCTION get_attribute14 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute14', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute14:->m_attribute14'||m_attribute14, FALSE);
   end if;


    return m_attribute14;
  END get_attribute14;

  FUNCTION get_attribute15 RETURN VARCHAR2 IS
  BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute15', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.get_attribute15:->m_attribute15='||m_attribute15, FALSE);
   end if;

   return m_attribute15;
  END get_attribute15;

  FUNCTION get_message_app_name RETURN VARCHAR2 IS
  BEGIN
      if (m_resultApplicationId = 0 OR m_resultApplicationId is null) then
        return 'FUN';
      else
        return(FUN_RULE_UTILITY_PKG.getApplicationShortName(m_resultApplicationId));
      end if;
  END get_message_app_name;

  FUNCTION GET_MULTI_RULE_RESULTS_TABLE RETURN fun_rule_results_table is
  BEGIN
    return m_RuleResultTable;
  END GET_MULTI_RULE_RESULTS_TABLE;

  PROCEDURE apply_rule_bulk(p_application_short_name  IN VARCHAR2,
                            p_rule_object_name        IN VARCHAR2,
                            p_param_view_name         IN VARCHAR2,
		            p_additional_where_clause IN VARCHAR2,
	                    p_primary_key_column_name IN VARCHAR2 DEFAULT 'ID') IS

  l_application_id  		 NUMBER;
  l_theCursor			 INTEGER;
  l_stringToParse                VARCHAR2(20000);
  l_colValue			 VARCHAR2(4000);
  l_counter			 PLS_INTEGER := 0;
  l_descTbl	                 DBMS_SQL.DESC_TAB;
  l_numColumns		         INTEGER;

  source_cursor			  INTEGER;
  l_num_rows_processed            INTEGER;
  l_crit_param_name               VARCHAR2(100);

  destination_cursor		  INTEGER;
  params_cursor                   INTEGER;
  params_rows_processed           INTEGER;

  l_result_type			  FUN_RULE_OBJECTS_B.RESULT_TYPE%TYPE;
  l_rule_detail_id		  FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
  l_prev_rule_detail_id		  FUN_RULE_DETAILS.RULE_DETAIL_ID%TYPE;
  l_operator			  FUN_RULE_DETAILS.OPERATOR%TYPE;
  l_rule_object_id		  FUN_RULE_DETAILS.RULE_OBJECT_ID%TYPE;
  l_flexfield_name		  FUN_RULE_OBJECTS_B.FLEXFIELD_NAME%TYPE;
  l_flexfield_app_short_name      FUN_RULE_OBJECTS_B.FLEXFIELD_APP_SHORT_NAME%TYPE;
  l_multiRuleResultFlag           FUN_RULE_OBJECTS_B.MULTI_RULE_RESULT_FLAG%TYPE;

  l_param_name		          FUN_RULE_CRIT_PARAMS_B.PARAM_NAME%TYPE;
  l_condition                     FUN_RULE_CRITERIA.CONDITION%TYPE;
  l_param_value		          FUN_RULE_CRITERIA.PARAM_VALUE%TYPE;
  l_data_type			  FUN_RULE_CRIT_PARAMS_B.DATA_TYPE%TYPE;
  l_case_sensitive		  FUN_RULE_CRITERIA.CASE_SENSITIVE_FLAG%TYPE;
  l_criteria_id		          FUN_RULE_CRITERIA.CRITERIA_ID%TYPE;

  l_ParamMultiValueList           multi_param_value;

  l_result_value                  VARCHAR2(1024);

  l_select_query                  VARCHAR2(20000);
  l_default_select_query          VARCHAR2(20000);
  l_where_clause                  VARCHAR2(2000) := '';
  l_insert_statement              VARCHAR2(20000);

  paramVal_cursor                  INTEGER;
  paramVal_rows_processed          INTEGER;

  l_counter                        NUMBER := 1;
  l_count                          NUMBER;
  l_isRuleValid                    BOOLEAN := FALSE;

  l_paramPresent                   BOOLEAN := FALSE;
  l_isAnyRuleOk                    BOOLEAN := FALSE;
  l_noRuleActive                   BOOLEAN := FALSE;

  l_old_moac_access_mode      VARCHAR2(1);
  l_old_org_id                NUMBER;
  l_date_format               VARCHAR2(50) := 'YYYY/MM/DD HH24:MI:SS';
  l_param_type                VARCHAR2(20);
  l_criteria_parameter_id     FUN_RULE_CRIT_PARAMS_B.CRITERIA_PARAM_ID%TYPE;

BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->p_application_short_name='||p_application_short_name, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->p_rule_object_name='||p_rule_object_name, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->p_param_view_name='||p_param_view_name, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->p_additional_where_clause='||p_additional_where_clause, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->p_primary_key_column_name='||p_primary_key_column_name, FALSE);
   end if;



    IF ( p_application_short_name IS NULL OR p_application_short_name = '') THEN
      fnd_message.set_name('FND','FND_NO_APP_SHORT_NAME');
      fnd_message.set_token('APP_SHORT_NAME',p_application_short_name);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF ( p_rule_object_name IS NULL OR p_rule_object_name = '') THEN
      fnd_message.set_name('FND','FND_NO_RULE_OBJECT_NAME');
      fnd_message.set_token('RULE_OBJECT_NAME',p_rule_object_name);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    IF ( p_param_view_name IS NULL OR p_param_view_name = '') THEN
      fnd_message.set_name('FND','FND_NO_PARAM_VIEW_NAME');
      fnd_message.set_token('PARAM_VIEW_NAME',p_param_view_name);
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


   /*Rule Object Instance MOAC Changes:
    *    If p_org_id is passed and the set_instance_context is called, then set the MOAC context based on
    *    following logic.
    *    If Product team has not called MO_GLOBAL.INIT then raise an exception.
    *    Else, get the access_mode. If access_mode is not S, then set to S and the passed p_og_id.
    */
    l_old_moac_access_mode := MO_GLOBAL.get_access_mode();
    l_old_org_id           := MO_GLOBAL.get_current_org_id();

    --Does validation and then sets the policy context to S, if its not S and
    --the passed org id value is not same as current org id value.

    IF (m_org_id IS NOT NULL) THEN
      FUN_RULE_MOAC_PKG.SET_MOAC_ACCESS_MODE(m_org_id);
    END IF;


    refreshGTBulkTable;
    init_parameter_list;
    l_application_id := FUN_RULE_UTILITY_PKG.getApplicationID(p_application_short_name);



    IF(l_application_id IS NULL) THEN
      l_application_id := FND_GLOBAL.RESP_APPL_ID;
    END IF;

    IF (p_additional_where_clause IS NULL) THEN
       l_stringToParse := 'select * from ' || p_param_view_name || ' where ROWNUM = 1';
    ELSE
       l_stringToParse := 'select * from ' || p_param_view_name || ' where ' || p_additional_where_clause || ' AND ROWNUM = 1';
    END IF;


    l_theCursor := dbms_sql.open_cursor;
    dbms_sql.parse( c             => l_theCursor,
                    statement     => l_stringToParse,
                    language_flag => dbms_sql.native);

    dbms_sql.describe_columns(l_theCursor, l_numColumns, l_descTbl);


      destination_cursor := DBMS_SQL.OPEN_CURSOR;

      if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->g_sRuleDetailSql='||g_sRuleDetailSql, FALSE);
      end if;

      --IF Instance Context is set, then append the where clause with an extra bind variable i.e
      --AND INSTANCE_LABEL = :3

      IF (m_instance_context = 'Y') THEN
          g_sRuleDetailSql := g_sRuleDetailMOACSql;
      ELSE
          g_sRuleDetailSql := g_sRuleDetailSql_orig;
      END IF;


      DBMS_SQL.PARSE(destination_cursor, g_sRuleDetailSql,DBMS_SQL.native);
      dbms_sql.bind_variable(destination_cursor , '1' , p_rule_object_name);
      dbms_sql.bind_variable(destination_cursor , '2' , l_application_id);

      IF (m_instance_context = 'Y') THEN
	      dbms_sql.bind_variable(destination_cursor , '3' , m_instance_label);
	      dbms_sql.bind_variable(destination_cursor , '4' , m_instance_label);
	      dbms_sql.bind_variable(destination_cursor , '5' , m_instance_label);

	      dbms_sql.bind_variable(destination_cursor , '6' , m_org_id);
	      dbms_sql.bind_variable(destination_cursor , '7' , m_org_id);
	      dbms_sql.bind_variable(destination_cursor , '8' , m_org_id);
      END IF;

      dbms_sql.define_column(destination_cursor, 1, l_result_type , 30);
      dbms_sql.define_column(destination_cursor, 2, l_rule_detail_id);
      dbms_sql.define_column(destination_cursor, 3, l_operator , 3);
      dbms_sql.define_column(destination_cursor, 4, l_rule_object_id);
      dbms_sql.define_column(destination_cursor, 5, l_flexfield_name , 80);
      dbms_sql.define_column(destination_cursor, 6, l_flexfield_app_short_name , 30);
      dbms_sql.define_column(destination_cursor, 7, l_multiRuleResultFlag , 10);

      l_num_rows_processed := DBMS_SQL.EXECUTE(destination_cursor);

      --If No rules active.
      if(l_num_rows_processed = 0) then
        l_noRuleActive := TRUE;
      end if;

      while(dbms_sql.fetch_rows(destination_cursor) > 0 ) loop
       l_count := 1;
       /* Initialize the var l_paramPresent for each rule. If any param matches then make it true
        * and insert the record into FUN_RULE_BULK_RESULT_GT table.
	*/
       l_paramPresent := FALSE;


       l_select_query        := 'SELECT '||p_primary_key_column_name||' , ';
       l_where_clause        := '';
       l_insert_statement    := 'insert into FUN_RULE_BULK_RESULT_GT(ID, RESULT_VALUE , RULE_NAME ,RESULT_APPLICATION_ID, RULE_DETAIL_ID )  ';

       dbms_sql.column_value(destination_cursor, 1, l_result_type);
       dbms_sql.column_value(destination_cursor, 2, l_rule_detail_id );
       dbms_sql.column_value(destination_cursor, 3, l_operator);
       dbms_sql.column_value(destination_cursor, 4, l_rule_object_id);
       dbms_sql.column_value(destination_cursor, 5, l_flexfield_name);
       dbms_sql.column_value(destination_cursor, 6, l_flexfield_app_short_name);
       dbms_sql.column_value(destination_cursor, 7, l_multiRuleResultFlag);

       params_cursor := DBMS_SQL.OPEN_CURSOR;

       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.apply_rule_bulk:->g_sCriteriaParamSql='||g_sCriteriaParamSql, FALSE);
       end if;

       DBMS_SQL.PARSE(params_cursor, g_sCriteriaParamSql,DBMS_SQL.native);

       dbms_sql.bind_variable(params_cursor , '1' , l_rule_detail_id);
       dbms_sql.bind_variable(params_cursor , '2' , l_rule_detail_id);

       dbms_sql.define_column(params_cursor, 1, l_param_name , 30);
       dbms_sql.define_column(params_cursor, 2, l_condition , 15);
       dbms_sql.define_column(params_cursor, 3, l_param_value , 1024);
       dbms_sql.define_column(params_cursor, 4, l_data_type, 15);
       dbms_sql.define_column(params_cursor, 5, l_case_sensitive, 1);
       dbms_sql.define_column(params_cursor, 6, l_criteria_id);

       params_rows_processed := DBMS_SQL.EXECUTE(params_cursor);

       while(dbms_sql.fetch_rows(params_cursor) > 0 ) loop
	     dbms_sql.column_value(params_cursor, 1, l_param_name );
	     dbms_sql.column_value(params_cursor, 2, l_condition );
	     dbms_sql.column_value(params_cursor, 3, l_param_value);
	     dbms_sql.column_value(params_cursor, 4, l_data_type);
	     dbms_sql.column_value(params_cursor, 5, l_case_sensitive);
	     dbms_sql.column_value(params_cursor, 6, l_criteria_id);
       /*
         START: RULES ENGINE ENHANCEMNT FOR CUSTOM PARAMETERS
         If the parameter is a custom parameter, then select the
         column name as the param name. Down the line, a query is
         built with param name in the where condition. Custom Param
         Name given while creating is not identical with the column
         name.If the parameter chosen is a custom parameter, change the
         name of the param name to the associated column name
       */

       SELECT parameter_type,criteria.criteria_param_id INTO l_param_type,l_criteria_parameter_id
       FROM fun_rule_crit_params_b param, fun_rule_criteria criteria
       WHERE criteria.criteria_id = l_criteria_id
       AND criteria.criteria_param_id = param.criteria_param_id;

       IF (l_param_type = 'CUSTOM') THEN
       SELECT COLUMN_NAME into l_param_name
       FROM FUN_RULE_CRIT_PARAMS_B
       WHERE criteria_param_id =  l_criteria_parameter_id;
       END IF;
       /*END: RULES ENGINE ENHANCEMNT FOR CUSTOM PARAMETERS*/

	     IF (l_data_type = C_DATE) THEN
	       l_param_value := fnd_date.canonical_to_date(l_param_value);
	     ELSIF (l_data_type  = C_NUMERIC) THEN
	       l_param_value := fnd_number.canonical_to_number(l_param_value);
	     END IF;

             for i in 1..l_numColumns
             loop
	       l_crit_param_name := l_descTbl(i).col_name;
               if(l_crit_param_name = l_param_name) then
                       l_paramPresent := TRUE;
		       paramVal_cursor := DBMS_SQL.OPEN_CURSOR;

                       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                           fnd_log.message(FND_LOG.LEVEL_STATEMENT,
			            'Start FUN_RULE_PUB.apply_rule_bulk:->g_sMultiCriteriaParamValueSql='||g_sMultiCriteriaParamValueSql, FALSE);
                       end if;

		       DBMS_SQL.PARSE(paramVal_cursor, g_sMultiCriteriaParamValueSql,DBMS_SQL.native);
		       dbms_sql.bind_variable(paramVal_cursor , '1' , l_rule_detail_id);
		       dbms_sql.bind_variable(paramVal_cursor , '2' , l_criteria_id);

		       dbms_sql.define_column(paramVal_cursor, 1, l_param_value , 1024);

		       paramVal_rows_processed := DBMS_SQL.EXECUTE(paramVal_cursor);

		       if(l_condition = C_IN) then
			l_where_clause := l_where_clause || l_param_name || ' IN (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ';
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''','''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||')';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_NOT_IN) then
			l_where_clause := l_where_clause || l_param_name || '  NOT IN (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ';
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_LIKE OR l_condition = C_CONTAINS) then
			l_where_clause := l_where_clause || l_param_name || '   LIKE (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS OR l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' '''||'%'|| l_param_value ||'%'||''' ,' ;
			    NULL;
			  else
			    l_where_clause := l_where_clause || ' %'|| l_param_value ||'%  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_EQUALS) then
			l_where_clause := l_where_clause || l_param_name || '   = (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ' ;
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_NOT_EQUALS) then
			l_where_clause := l_where_clause || l_param_name || '   <> (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ' ;
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_GREATER_THAN) then
			l_where_clause := l_where_clause || l_param_name || '   > (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ' ;
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_LESSER_THAN) then
			l_where_clause := l_where_clause || l_param_name || '   < (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ' ;
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_GREATER_THAN_EQUAL) then
			l_where_clause := l_where_clause || l_param_name || '   >= (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ' ;
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		       elsif (l_condition = C_LESSER_THAN_EQUAL) then
			l_where_clause := l_where_clause || l_param_name || '   <= (';
			while(dbms_sql.fetch_rows(paramVal_cursor) > 0 ) loop
			  dbms_sql.column_value(paramVal_cursor, 1, l_param_value );
			  if(l_data_type = C_STRINGS) then
			    l_where_clause := l_where_clause || ' '''|| l_param_value ||''', ' ;
			  elsif(l_data_type = C_DATE) then
			    l_where_clause := l_where_clause || ' to_date('''|| l_param_value ||''', '''|| l_date_format ||''' ), ';
			  else
			    l_where_clause := l_where_clause || ' '|| l_param_value ||'  ,' ;
			  end if;
			end loop;
			l_where_clause := l_where_clause ||' ) ';
                        l_where_clause := substr(l_where_clause,1,instr(l_where_clause,',',-1)-1) || substr(l_where_clause,instr(l_where_clause,',',-1)+1);
		      end if;
  	              l_where_clause := l_where_clause || ' ' || l_operator || ' ';
		      DBMS_SQL.CLOSE_CURSOR(paramVal_cursor);
             else
  	       NULL;
             end if; --If l_crit_param_name = l_param_name
	   end loop; --End loop of l_descCol
       end loop; --End Loop params sql

       IF (l_where_clause IS NOT NULL) THEN
          l_where_clause := rtrim(l_where_clause);
          l_where_clause := substr(l_where_clause, 0, length(l_where_clause)-3);
       END IF;


       /*Check for value of l_paramPresent. If this is false, that means not a single column in the
        *product team's GT table has got correct criteria parameter names.
	*/

       if(NOT l_paramPresent) then
         raise  INVAILD_COLUMN_NAME;
       end if;

       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'FUN_RULE_PUB.apply_rule_bulk:->before setResultValues', FALSE);
       end if;

       if(l_rule_detail_id IS NOT NULL) then
          l_isRuleValid := isRuleValid(p_param_view_name , l_where_clause);

	  --Check for a single ruile that gets satisfied, else this is to track
	  --the default result to be returned.

          l_isAnyRuleOk := l_isAnyRuleOk OR l_isRuleValid;

          if (l_isRuleValid) then
   	    setResultValues(l_isRuleValid,
	  		    TRUE,
			    l_rule_object_id,
			    l_result_type,
			    p_rule_object_name,
			    l_flexfield_name,
			    l_flexfield_app_short_name,
			    l_rule_detail_id);
	    l_select_query := l_select_query ||' '''||m_resultValue||''',  '''||m_ruleName||''', '||NVL(m_resultApplicationId, FND_GLOBAL.resp_appl_id)||' , '||m_ruleDetailId||'  FROM '||p_param_view_name||' WHERE ';
	    l_default_select_query := l_select_query || ' AND ROWNUM =1 ';
	    if(l_where_clause IS NOT NULL) then
	       l_select_query := l_select_query || l_where_clause;
	    end if;
          end if;
      end if;


      IF (p_additional_where_clause IS NOT NULL) THEN
         l_select_query := l_select_query || '   AND ' || p_additional_where_clause;
      END IF;

      DBMS_SQL.CLOSE_CURSOR(params_cursor);

    if(l_isRuleValid) then
        l_insert_statement := l_insert_statement || '  ' || l_select_query ||
				' AND NOT EXISTS(SELECT 1 FROM FUN_RULE_BULK_RESULT_GT WHERE ID='|| p_param_view_name||'.'||p_primary_key_column_name||')';
        IF (populateGTBulkTable(l_insert_statement)) THEN
          NULL;
        END IF;
    end if;

  end loop;

  /*If not a single rule is satisfied then simply insert the default result SELECT statement*/

  /* bug  7337383  */
  -- if (NOT l_isAnyRuleOk) then
  --  refreshGTBulkTable;

    l_select_query        := 'SELECT '||p_primary_key_column_name||' , ';
    l_where_clause        := ' AND NOT EXISTS(SELECT  1 FROM FUN_RULE_BULK_RESULT_GT WHERE ID='|| p_param_view_name||'.'||p_primary_key_column_name||')';
    l_insert_statement    := 'insert into FUN_RULE_BULK_RESULT_GT(ID, RESULT_VALUE , RULE_NAME ,RESULT_APPLICATION_ID, RULE_DETAIL_ID )  ';

    if(l_noRuleActive) then

      setResultValues(l_isRuleValid,
      		      FALSE,
		      l_rule_object_id,
		      l_result_type,
		      p_rule_object_name,
		      l_flexfield_name,
		      l_flexfield_app_short_name,
		      l_rule_detail_id);
    else

      setResultValues(l_isRuleValid,
      		      TRUE,
		      l_rule_object_id,
		      l_result_type,
		      p_rule_object_name,
		      l_flexfield_name,
		      l_flexfield_app_short_name,
		      l_rule_detail_id);
    end if;

    l_select_query := l_select_query ||' '''||m_resultValue||''',  '''||m_ruleName||''', '||NVL(m_resultApplicationId, FND_GLOBAL.resp_appl_id)||' , '||m_ruleDetailId||'  FROM '||p_param_view_name||' WHERE 1=1 ';
    l_select_query := l_select_query || l_where_clause;

    IF (p_additional_where_clause IS NOT NULL) THEN
         l_select_query := l_select_query || '   AND ' || p_additional_where_clause;
    END IF;

    l_insert_statement := l_insert_statement || '  ' || l_select_query;
    IF (populateGTBulkTable(l_insert_statement)) THEN
      NULL;
    END IF;

 /* bug  7337383  */
--  end if;

  DBMS_SQL.CLOSE_CURSOR(destination_cursor);

  -- start bug 7385974
  IF DBMS_SQL.IS_OPEN(l_theCursor) THEN
    DBMS_SQL.CLOSE_CURSOR(l_theCursor);
  END IF;
  -- end bug 7385974

   /*Rule Object Instance MOAC Changes:
    *    Revert back the access mode and org id to the l_old_acess_mode and l_old_org_id
    *    And Clear The Instance Context if set.
    */

   IF (m_org_id IS NOT NULL) THEN
     FUN_RULE_MOAC_PKG.SET_MOAC_POLICY_CONTEXT(l_old_moac_access_mode , l_old_org_id , m_org_id);
   END IF;
   clearInstanceContext;

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.apply_rule_bulk', FALSE);
   end if;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.apply_rule_bulk:->NO_DATA_FOUND', FALSE);
       END IF;

       RAISE;

     WHEN INVAILD_COLUMN_NAME THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.apply_rule_bulk:->INVAILD_COLUMN_NAME', FALSE);
       END IF;

       fnd_message.set_name('FUN','FUN_RULE_NO_VALID_COLUMNS');
       FND_MESSAGE.SET_TOKEN('TABLE_NAME', p_param_view_name);
       FND_MESSAGE.SET_TOKEN('RULE_OBJECT_NAME', p_rule_object_name);
       app_exception.raise_exception;

     WHEN OTHERS THEN
       -- start bug 7385974
       IF DBMS_SQL.IS_OPEN(l_theCursor) THEN
	 DBMS_SQL.CLOSE_CURSOR(l_theCursor);
       END IF;
       -- end bug 7385974
       IF DBMS_SQL.IS_OPEN(destination_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(destination_cursor);
       END IF;
       IF DBMS_SQL.IS_OPEN(params_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(params_cursor);
       END IF;
       IF DBMS_SQL.IS_OPEN(paramVal_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(paramVal_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.apply_rule_bulk Others:->'||SQLERRM, FALSE);
       END IF;

       RAISE;

END apply_rule_bulk;

PROCEDURE refreshGTBulkTable
IS
   source_cursor      INTEGER;
   ignore             INTEGER;

BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.refreshGTBulkTable', FALSE);
   end if;

-- Prepare a cursor to select from the source table:
   source_cursor := DBMS_SQL.OPEN_CURSOR;

   DBMS_SQL.PARSE(source_cursor, 'delete from FUN_RULE_BULK_RESULT_GT', DBMS_SQL.native);

   ignore := DBMS_SQL.EXECUTE(source_cursor);

   DBMS_SQL.CLOSE_CURSOR(source_cursor);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.refreshGTBulkTable', FALSE);
   end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.refreshGTBulkTable:->'||SQLERRM, FALSE);
       END IF;
       --No Need of Raising in this case.

     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.refreshGTBulkTable:->'||SQLERRM, FALSE);
       END IF;
       RAISE;

END refreshGTBulkTable;

FUNCTION  populateGTBulkTable(p_insert_statement IN VARCHAR2) RETURN BOOLEAN
IS
   destination_cursor INTEGER;
   ignore             INTEGER;

BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.populateGTBulkTable', FALSE);
   end if;

-- Prepare a cursor to insert into the destination table:
     destination_cursor := DBMS_SQL.OPEN_CURSOR;

     DBMS_SQL.PARSE(destination_cursor,p_insert_statement,DBMS_SQL.native);

     ignore := DBMS_SQL.EXECUTE(destination_cursor);
     DBMS_SQL.CLOSE_CURSOR(destination_cursor);

     if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.populateGTBulkTable', FALSE);
     end if;

     IF(ignore > 0) THEN RETURN TRUE;
     ELSE RETURN FALSE;
     END IF;

EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(destination_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(destination_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.populateGTBulkTable:->'||p_insert_statement, FALSE);
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.populateGTBulkTable:->'||SQLERRM, FALSE);
       END IF;

       RAISE;

END populateGTBulkTable;

PROCEDURE TEST
IS
  CURSOR C1 IS SELECT * FROM FUN_RULE_BULK_RESULT_GT;
BEGIN
   for c_rec in c1 loop
     --dbms_output.put_line('rule_name='||c_rec.rule_name||'***result_value='||c_rec.result_value);
     NULL;
   end loop;
END TEST;

FUNCTION  isRuleValid(p_param_view_name in varchar2, l_where_clause IN VARCHAR2) RETURN BOOLEAN
IS
   source_cursor		INTEGER;
   l_num_rows_processed		INTEGER;
   l_num                        NUMBER;
   x_where_clause               VARCHAR2(20000) := l_where_clause;

   l_select    VARCHAR2(20000) := 'SELECT COUNT(1) FROM '|| p_param_view_name ||' WHERE ';
   l_present   BOOLEAN := FALSE;
BEGIN

  IF (x_where_clause IS NOT NULL) THEN
     l_select := l_select || ' ' || x_where_clause || ' ';
   ELSE
     l_select := l_select || ' 1 = 1';
   END IF;


   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isRuleValid', FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isRuleValid:->p_param_view_name='||p_param_view_name, FALSE);
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.isRuleValid:->l_where_clause'||x_where_clause, FALSE);
   end if;

    source_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(source_cursor,   l_select, DBMS_SQL.native);

    DBMS_SQL.DEFINE_COLUMN(source_cursor, 1, l_num);
    l_num_rows_processed := DBMS_SQL.EXECUTE(source_cursor);

    /*IF  its not a valid SQL statement, then here it goes to Exception
     *Else return TRUE.
     */
    IF DBMS_SQL.FETCH_ROWS(source_cursor)>0 THEN
      -- get column values of the row
      DBMS_SQL.COLUMN_VALUE(source_cursor, 1, l_num);
      IF(l_num > 0) THEN
        l_present := true;
      END IF;
    END IF;

    DBMS_SQL.CLOSE_CURSOR(source_cursor);
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.isRuleValid', FALSE);
   end if;

   RETURN l_present;

  EXCEPTION
     WHEN OTHERS THEN
       IF DBMS_SQL.IS_OPEN(source_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(source_cursor);
       END IF;
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.isRuleValid:->'||SQLERRM, FALSE);
       END IF;
       RAISE;

 END isRuleValid;

 FUNCTION GET_ALL_RULE_NAMES  RETURN VARCHAR2
 IS
    results                    FUN_RULE_RESULTS_TABLE := fun_Rule_Results_Table();
    l_rule_name                VARCHAR2(200);
    l_concatenated_rules_name  VARCHAR2(2000) := '';
 BEGIN
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.GET_ALL_RULE_NAMES', FALSE);
   end if;

   IF(m_multiRuleResultFlag = 'Y') THEN
    results := FUN_RULE_PUB.get_multi_rule_results_table;
    for i in 1..results.COUNT loop
      l_rule_name := results(i).get_rule_name;
      l_concatenated_rules_name := l_concatenated_rules_name || l_rule_name || ' ; ';
    end loop;
    return l_concatenated_rules_name;
   ELSE
    return m_ruleName;
   END IF;
 END GET_ALL_RULE_NAMES;

 /*Clears the instance context*/
 PROCEDURE clearInstanceContext IS
 BEGIN

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.clearInstanceContext', FALSE);
   end if;

   IF (NVL(m_instance_context , 'N') = 'Y') THEN
     m_instance_label       := NULL;
     m_org_id               := NULL;
     m_instance_context     := 'N';
   END IF;

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End FUN_RULE_PUB.clearInstanceContext', FALSE);
   end if;
 END clearInstanceContext;

END FUN_RULE_PUB;

/
