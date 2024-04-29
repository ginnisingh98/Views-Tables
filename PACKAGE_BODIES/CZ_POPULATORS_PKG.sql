--------------------------------------------------------
--  DDL for Package Body CZ_POPULATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_POPULATORS_PKG" AS
/*	$Header: czpopb.pls 120.8.12010000.3 2010/01/23 11:15:50 kksriram ship $		*/

ITEMS_POP            CONSTANT INTEGER:=1;
ITEM_TYPES_POP       CONSTANT INTEGER:=2;
PROPERTIES_POP       CONSTANT INTEGER:=3;
PROPERTY_VALUES_POP  CONSTANT INTEGER:=4;

BEGINSWITH_OPERATOR  CONSTANT INTEGER:=300;
ENDSWITH_OPERATOR    CONSTANT INTEGER:=301;
CONTAINS_OPERATOR    CONSTANT INTEGER:=303;
MATCHES_OPERATOR     CONSTANT INTEGER:=304;
OPERATOR_IN          CONSTANT INTEGER:=502;

PS_FEATURE_TYPE      CONSTANT INTEGER:=261;

NULL_VALUE           CONSTANT INTEGER:=-1;
EPOCH_BEGIN          CONSTANT DATE:=CZ_UTILS.EPOCH_BEGIN_;
EPOCH_END            CONSTANT DATE:=CZ_UTILS.EPOCH_END_;

ISTYPEOF             CONSTANT VARCHAR2(3):=315;
ISPROPERTYOF         CONSTANT VARCHAR2(3):=305;
ISPROPERTYVAL        CONSTANT VARCHAR2(3):=318;
OPERATOR_EQUAL       CONSTANT VARCHAR2(50):='=';
OPERATOR_LIKE        CONSTANT VARCHAR2(50):='like';
OPERATOR_SQL_IN      CONSTANT VARCHAR2(50):='in';

USER_VIEW            CONSTANT VARCHAR2(50):='*';

mRUN_ID                   INTEGER:=0;

mUSE_LOCKING              VARCHAR(255)  := '1';
mDB_SETTING_USE_SECURITY  BOOLEAN       := TRUE;
mALWAYS_REGENERATE        VARCHAR2(255) := 'N';

mCOUNTER                  INTEGER:=0;

FAILED_TO_LOCK_MODEL      EXCEPTION;

mPS_NODE_SEQUENCE         VARCHAR2(255) := 'CZ_PS_NODES_S';
mINTL_TEXT_SEQUENCE       VARCHAR2(255) := 'CZ_INTL_TEXTS_S';

mINCREMENT                NUMBER := 20;

mNext_PS_Node_Id          NUMBER;
mBase_PS_Node_Id          NUMBER;

mNext_Text_Id             NUMBER;
mBase_Text_Id             NUMBER;

TYPE INTL_ID_DESC_TEXT_TYPE IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(15);
INTL_ID_DESC_TEXT_ARRAY     INTL_ID_DESC_TEXT_TYPE;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE LOG_REPORT
(p_caller        IN VARCHAR2,
 p_error_message IN VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    var_error      BOOLEAN;
    var_status     INTEGER;
BEGIN
    var_status:=11276;
    INSERT INTO CZ_DB_LOGS
           (RUN_ID,
            LOGTIME,
            LOGUSER,
            URGENCY,
            CALLER,
            STATUSCODE,
            MESSAGE)
    VALUES (mRUN_ID,
            SYSDATE,
            USER,
            1,
            p_caller,
            var_status,
            p_error_message);
    COMMIT;

END LOG_REPORT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- this method add log message to the CZ_DB_LOGS table
--
PROCEDURE SECURITY_REPORT
  (p_run_id        IN VARCHAR2,
   p_count         IN NUMBER DEFAULT NULL) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
      IF (p_count>0) THEN
         FOR i IN 1..p_count
         LOOP
            mCOUNTER:=mCOUNTER+1;
            INSERT INTO CZ_DB_LOGS
               (RUN_ID,
                LOGTIME,
                LOGUSER,
                URGENCY,
                CALLER,
                STATUSCODE,
                MESSAGE,
                MESSAGE_ID)
            VALUES
                (p_run_id,
                SYSDATE,
                USER,
                1,
                'CZ_POPULATORS_PKG',
                11276,
                fnd_msg_pub.GET(i,fnd_api.g_false),
                mCOUNTER);
            COMMIT;
         END LOOP;
      END IF;

  EXCEPTION
      WHEN OTHERS THEN
           NULL;
  END SECURITY_REPORT;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Get_Seq_Increment IS
BEGIN
    SELECT TO_NUMBER(value) INTO mINCREMENT FROM cz_db_settings
    WHERE UPPER(setting_id)=UPPER('OracleSequenceIncr') AND section_name='SCHEMA';
END Get_Seq_Increment;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Initialize_Sequence(p_seq_name IN VARCHAR2) IS
BEGIN

  Get_Seq_Increment;

  IF p_seq_name=mPS_NODE_SEQUENCE THEN
    SELECT CZ_PS_NODES_S.NEXTVAL INTO mNext_PS_Node_Id FROM dual;
    mBase_PS_Node_Id:=mNext_PS_Node_Id;
  ELSIF p_seq_name=mINTL_TEXT_SEQUENCE THEN
    SELECT CZ_INTL_TEXTS_S.NEXTVAL INTO mNext_Text_Id FROM dual;
    mBase_Text_Id := mNext_Text_Id;
  END IF;

END Initialize_Sequence;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION get_Next_Seq_Id(p_seq_name IN VARCHAR2) RETURN NUMBER IS
BEGIN

  IF p_seq_name=mPS_NODE_SEQUENCE THEN
    IF (mNext_PS_Node_Id < mBase_PS_Node_Id+mINCREMENT-1) THEN
       mNext_PS_Node_Id := mNext_PS_Node_Id + 1;
    ELSE
       SELECT CZ_PS_NODES_S.nextval INTO mBase_PS_Node_Id FROM dual;
       mNext_PS_Node_Id:=mBase_PS_Node_Id;
    END IF;
    RETURN mNext_PS_Node_Id;
  ELSIF p_seq_name=mINTL_TEXT_SEQUENCE THEN
    IF (mNext_Text_Id < mBase_Text_Id+mINCREMENT-1) THEN
       mNext_Text_Id := mNext_Text_Id + 1;
    ELSE
       SELECT CZ_INTL_TEXTS_S.nextval INTO mBase_Text_Id FROM dual;
       mNext_Text_Id:=mBase_Text_Id;
    END IF;
    RETURN mNext_Text_Id;
  END IF;
END get_Next_Seq_Id;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

  PROCEDURE lock_Model(p_model_id        IN NUMBER,
                       p_locked_entities OUT NOCOPY cz_security_pvt.number_type_tbl) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_lock_status     VARCHAR2(255);
    l_msg_count       NUMBER;
    l_msg_index       NUMBER;
    l_msg_data        VARCHAR2(4000);
  BEGIN
    cz_security_pvt.lock_model(1.0, p_model_id,FND_API.G_FALSE,FND_API.G_FALSE,
                               p_locked_entities,
                               l_lock_status,l_msg_count,l_msg_data);
    IF (l_lock_status <> FND_API.G_RET_STS_SUCCESS) THEN
       ROLLBACK;
       l_msg_index := 1;
       WHILE l_msg_count > 0
       LOOP
        l_msg_data := fnd_msg_pub.get(l_msg_index,fnd_api.g_false);
        LOG_REPORT('CZ_POPULATORS_PKG.lock_Model',l_msg_data);
        l_msg_index := l_msg_index + 1;
        l_msg_count := l_msg_count - 1;
       END LOOP;
       FND_MSG_PUB.initialize;
       RAISE FAILED_TO_LOCK_MODEL;
    ELSE
       COMMIT;
    END IF;

  END lock_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

  PROCEDURE unlock_Model(p_model_id        IN NUMBER,
                         p_locked_entities IN OUT NOCOPY cz_security_pvt.number_type_tbl) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    l_lock_status     VARCHAR2(255);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(4000);
  BEGIN
    cz_security_pvt.unlock_model(1.0, FND_API.G_FALSE,
                                 p_locked_entities,l_lock_status,
                                 l_msg_count,l_msg_data);
    COMMIT;
  END unlock_Model;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION get_Where(p_rule_id IN INTEGER) RETURN VARCHAR2 IS
    TYPE t_arr      IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
    t_where         t_arr;
    var_data_value_tbl t_arr;
    var_where       VARCHAR2(4000);
    var_field_name  CZ_EXPRESSION_NODES.field_name%TYPE;
    var_data_value  CZ_EXPRESSION_NODES.data_value%TYPE;
    var_filter      VARCHAR2(4000);
    var_operator    VARCHAR2(50);
    var_counter     NUMBER:=0;
BEGIN
    FOR i IN(SELECT expr_node_id,field_name,expr_subtype,seq_nbr FROM CZ_EXPRESSION_NODES
             WHERE rule_id=p_rule_id AND (field_name IS NULL AND data_value IS NULL)
             AND deleted_flag='0' ORDER BY seq_nbr)
    LOOP
       BEGIN
           SELECT DECODE(field_name,'ref_part_nbr','item_master_name',field_name)
           INTO var_field_name FROM CZ_EXPRESSION_NODES
           WHERE expr_parent_id=i.expr_node_id AND field_name IS NOT NULL;
           BEGIN
               SELECT REPLACE(data_value,'''','''''') BULK COLLECT INTO var_data_value_tbl FROM CZ_EXPRESSION_NODES
               WHERE expr_parent_id=i.expr_node_id AND data_value IS NOT NULL
               AND deleted_flag='0';
               IF var_data_value_tbl.COUNT>0 THEN
                  var_data_value := var_data_value_tbl(1);
               END IF;
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    IF i.expr_subtype=ENDSWITH_OPERATOR THEN
                       var_data_value:='';
                    END IF;
           END;

           IF i.expr_subtype=BEGINSWITH_OPERATOR THEN
              var_filter:=var_data_value||'%';
              var_operator:=OPERATOR_LIKE;
           ELSIF i.expr_subtype=ENDSWITH_OPERATOR THEN
              var_filter:='%'||var_data_value;
              var_operator:=OPERATOR_LIKE;
           ELSIF i.expr_subtype=CONTAINS_OPERATOR THEN
              var_filter:='%'||var_data_value||'%';
              var_operator:=OPERATOR_LIKE;
           ELSIF i.expr_subtype=MATCHES_OPERATOR THEN
              var_filter:=var_data_value;
              var_operator:=OPERATOR_EQUAL;
           ELSIF i.expr_subtype=ISTYPEOF THEN
              var_filter:=var_data_value;
              var_operator:=OPERATOR_EQUAL;
           ELSIF i.expr_subtype IN(ISPROPERTYOF,ISPROPERTYVAL) THEN
              var_filter:=var_data_value;
              var_operator:=OPERATOR_EQUAL;
           ELSIF i.expr_subtype=OPERATOR_IN THEN

              FOR n IN var_data_value_tbl.First..var_data_value_tbl.Last
              LOOP
                 IF var_filter IS NULL THEN
                    var_filter:=var_data_value_tbl(n);
                 ELSE
                    var_filter:=var_filter||','||var_data_value_tbl(n);
                 END IF;
              END LOOP;

              var_filter := '('||var_filter||')';
              var_operator:=OPERATOR_SQL_IN;

           END IF;
           var_filter := UPPER(var_filter);
           t_where(t_where.Count+1):=' UPPER('||var_field_name||') '||var_operator||' '''||var_filter||'''';
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                NULL;
           WHEN OTHERS THEN
                NULL;
       END;
    END LOOP;

    var_where:=t_where(1);
    IF t_where.Count>1 THEN
       FOR k IN 2..t_where.Last
       LOOP
          var_where:=var_where||' and '||t_where(k);
       END LOOP;
    END IF;

    RETURN var_where;
EXCEPTION
   WHEN OTHERS THEN
        RETURN ' 0=1 ';
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

-- create sql query or view based on data  --
-- from CZ_FILTER_SETS,CZ_EXPRESSION_NODES --

PROCEDURE Regenerate_unsec
(p_populator_id IN     INTEGER,
 p_view_name    IN OUT NOCOPY VARCHAR2,
 p_sql_query    IN OUT NOCOPY VARCHAR2,
 p_err          OUT NOCOPY    INTEGER) IS
    var_view_name          CZ_POPULATORS.view_name%TYPE;
    var_based_view         CZ_POPULATORS.view_name%TYPE;
    var_sql                CZ_POPULATORS.query_syntax%TYPE;
    var_filter_set_id      CZ_FILTER_SETS.filter_set_id%TYPE;
    var_source_type        CZ_FILTER_SETS.source_type%TYPE;
    var_rule_id            CZ_FILTER_SETS.express_id%TYPE;
    var_operator           CZ_EXPRESSION_NODES.expr_subtype%TYPE;
    var_data_value         CZ_EXPRESSION_NODES.data_value%TYPE;
    var_name               CZ_PS_NODES.name%TYPE;
    var_pop_name           CZ_POPULATORS.name%TYPE;
    var_property_id        CZ_PROPERTIES.property_id%TYPE;
    var_item_type_id       CZ_ITEM_TYPES.item_type_id%TYPE;
    var_item_id            CZ_ITEM_MASTERS.item_id%TYPE;
    var_desc_text          CZ_ITEM_MASTERS.desc_text%TYPE;
    var_primary_uom_code   CZ_ITEM_MASTERS.primary_uom_code%TYPE;
    var_quoteable_flag     CZ_ITEM_MASTERS.quoteable_flag%TYPE;
    var_ps_node_type       CZ_PS_NODES.ps_node_type%TYPE;
    var_model_id           CZ_PS_NODES.devl_project_id%TYPE;
    var_ps_node_id         CZ_POPULATORS.owned_by_node_id%TYPE;
    var_level              INTEGER;
    var_current            VARCHAR2(1);
    var_filter             VARCHAR2(4000);
    var_filter1            VARCHAR2(4000);
    var_filter2            VARCHAR2(4000);
    var_level_column       VARCHAR2(20):='';
    var_where              VARCHAR2(4000);
    there_is_no_seed_data  BOOLEAN:=FALSE;

    WRONG_SQL              EXCEPTION;
    DELETED_EXPRESSION     EXCEPTION;

BEGIN

    p_err:=0;

    SELECT filter_set_id,view_name,result_type,var_ps_node_id,query_syntax,name
    INTO var_filter_set_id,var_view_name,var_ps_node_type,var_ps_node_id,var_sql,var_pop_name
    FROM CZ_POPULATORS
    WHERE populator_id=p_populator_id;

    BEGIN
        SELECT a.source_type,a.rule_id,b.view_name
        INTO var_source_type,var_rule_id,var_based_view
        FROM CZ_FILTER_SETS a, CZ_POPULATORS b
        WHERE a.filter_set_id=var_filter_set_id AND a.source_type=b.populator_id;
    EXCEPTION
        WHEN OTHERS THEN
             there_is_no_seed_data:=TRUE;
    END;

    IF there_is_no_seed_data THEN
       SELECT source_type,rule_id
       INTO var_source_type,var_rule_id
       FROM CZ_FILTER_SETS
       WHERE filter_set_id=var_filter_set_id;
       IF    var_source_type=1 THEN
             var_based_view:='CZ_ITEM_ITEM_POP_V';
       ELSIF var_source_type=2 THEN
             var_based_view:='CZ_ITEM_ITEMTYPE_POP_V';
       ELSIF var_source_type=3 THEN
             var_based_view:='CZ_ITEM_PROPERTY_POP_V';
       ELSIF var_source_type=4 THEN
             var_based_view:='CZ_ITEM_ITEMVAL_POP_V';
       ELSE
             var_based_view:=USER_VIEW;
       END IF;
    END IF;

    --
    -- create Populator sql query based on data from CZ_EXPRESSION_NODES table --
    --
    IF var_based_view<>USER_VIEW THEN
       var_sql:='select * from '||var_based_view||' where '||get_Where(var_rule_id);
    END IF;

    UPDATE CZ_POPULATORS SET query_syntax=var_sql, last_generation_date=SYSDATE
    WHERE populator_id=p_populator_id;

   --
   -- this approach is very slow                     --
   -- but sometimes views can be useful for DEBUGing --
   --
   IF mCREATE_DEBUG_VIEWS IN('Y','YES') THEN
      IF p_view_name IS NULL OR p_view_name='' THEN
         p_view_name:='CZ_POP_'||TO_CHAR(p_populator_id)||'_V';
      END IF;
      EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW '||p_view_name||' AS '||var_sql;
      UPDATE CZ_POPULATORS SET view_name=p_view_name WHERE populator_id=p_populator_id;
   END IF;

   p_sql_query:=var_sql;

EXCEPTION
    WHEN DELETED_EXPRESSION THEN
         p_err:=mRUN_ID;
         LOG_REPORT('CZ_POPULATORS_PKG.Regenerate','Regenerate populator "'||var_pop_name||'" : definition was deleted.');
    WHEN WRONG_SQL  THEN
         p_err:=mRUN_ID;
         LOG_REPORT('CZ_POPULATORS_PKG.Regenerate','Regenerate populator "'||var_pop_name||'" -wrong SQL query is used : '||SQLERRM);
    WHEN OTHERS THEN
         p_err:=mRUN_ID;
         LOG_REPORT('CZ_POPULATORS_PKG.Regenerate','Regenerate populator "'||var_pop_name||'" : '||SQLERRM);
END Regenerate_unsec;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Regenerate
(p_populator_id   IN     INTEGER,
 p_view_name      IN OUT NOCOPY VARCHAR2,
 p_sql_query      IN OUT NOCOPY VARCHAR2,
 p_err            OUT NOCOPY    INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL) IS

    l_model_id             NUMBER;
    l_locked_entities_tbl  cz_security_pvt.number_type_tbl;
    l_has_priveleges       VARCHAR2(255);
    l_msg_data             VARCHAR2(32000);
    l_lock_status          VARCHAR2(255);
    l_return_status        VARCHAR2(255);
    l_msg_count            NUMBER;

BEGIN

    p_err := 0;

    IF UPPER(p_init_fnd_stack) IN('1','Y','YES') THEN
      FND_MSG_PUB.initialize;
    END IF;

    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO mRUN_ID FROM dual;

    --
    -- check global flag that equals '1' if model is already locked
    -- by calling sequirity package
    --
    IF mDB_SETTING_USE_SECURITY THEN

       SELECT devl_project_id INTO l_model_id FROM CZ_PS_NODES
       WHERE ps_node_id IN(SELECT owned_by_node_id FROM CZ_POPULATORS
       WHERE populator_id=p_populator_id) AND deleted_flag='0' AND rownum<2;

       lock_Model(l_model_id, l_locked_entities_tbl);

    END IF;

    Regenerate_unsec(p_populator_id => p_populator_id,
                     p_view_name    => p_view_name,
                     p_sql_query    => p_sql_query,
                     p_err          => p_err);

    IF l_locked_entities_tbl.COUNT>0 AND mDB_SETTING_USE_SECURITY THEN

      unlock_Model(l_model_id, l_locked_entities_tbl);

    END IF;

EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN
      p_err := mRUN_ID;
END Regenerate;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Preview_unsec
(p_populator_id IN  INTEGER,
 p_run_id       OUT NOCOPY INTEGER,
 p_err          OUT NOCOPY INTEGER) IS
    TYPE rec_cols         IS RECORD (col_name VARCHAR2(255),col_num NUMBER);
    TYPE t_rec_cols       IS TABLE OF rec_cols INDEX BY BINARY_INTEGER;
    TYPE NamesArray       IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
    t_names               NamesArray;
    t_col                 t_rec_cols;
    var_pop_name          CZ_POPULATORS.name%TYPE;
    var_view_name         CZ_POPULATORS.view_name%TYPE;
    var_last_update       CZ_POPULATORS.last_update_date%TYPE;
    var_result_type       CZ_POPULATORS.result_type%TYPE;
    var_ps_node_type      CZ_PS_NODES.ps_node_type%TYPE;
    var_sql               CZ_POPULATORS.query_syntax%TYPE;
    var_has_level         CZ_POPULATORS.has_level%TYPE;
    var_has_item          CZ_POPULATORS.has_item%TYPE;
    var_has_item_type     CZ_POPULATORS.has_item_type%TYPE;
    var_has_property      CZ_POPULATORS.has_property%TYPE;
    var_filter_set_id     CZ_FILTER_SETS.filter_set_id%TYPE;
    var_express_id        CZ_EXPRESSIONS.express_id%TYPE;
    var_ps_node_id        CZ_PS_NODES.ps_node_id%TYPE;
    var_project_id        CZ_PS_NODES.devl_project_id%TYPE;
    var_intl_text_id      CZ_PS_NODES.intl_text_id%TYPE;
    var_new_text_id       CZ_PS_NODES.intl_text_id%TYPE;
    var_feature_type      CZ_PS_NODES.feature_type%TYPE;
    var_property_ptr      CZ_PS_NODES.property_backptr%TYPE;
    var_item_type_ptr     CZ_PS_NODES.item_type_backptr%TYPE;
    var_name              CZ_PS_NODES.name%TYPE;
    var_desc_text         CZ_ITEM_TYPES.desc_text%TYPE;
    var_property_id       CZ_PROPERTIES.property_id%TYPE;
    var_item_type_id      CZ_ITEM_TYPES.item_type_id%TYPE;
    var_item_id           CZ_ITEM_MASTERS.item_id%TYPE;
    var_primary_uom_code  CZ_ITEM_MASTERS.primary_uom_code%TYPE;
    var_quoteable_flag    CZ_ITEM_MASTERS.quoteable_flag%TYPE;
    var_tree_seq          CZ_PS_NODES.tree_seq%TYPE;
    var_node_name         CZ_PS_NODES.name%TYPE;
    var_key               CZ_PS_NODES.user_str03%TYPE;
    var_fk_key            CZ_IMP_PS_NODES.FSK_PSNODE_3_EXT%TYPE;
    var_instantiable_flag CZ_PS_NODES.instantiable_flag%TYPE;
    var_minimum           CZ_PS_NODES.minimum%TYPE;
    var_maximum           CZ_PS_NODES.maximum%TYPE;
    var_text_str          CZ_INTL_TEXTS.text_str%TYPE;
    var_level             NUMBER;
    var_cursor            NUMBER;
    var_exec              NUMBER;
    var_ind               NUMBER;
    var_ps_node_key       NUMBER;
    var_parent_key        NUMBER;
    col_cnt               INTEGER;
    var_counter           INTEGER;
    rec_tab               dbms_sql.desc_tab;
    var_rec               dbms_sql.desc_rec;
    var_col_name          VARCHAR2(255);
    var_col_num           NUMBER;
    var_col_length        NUMBER;
    var_rule_id           NUMBER;
    var_curr_date         DATE;
    var_tree_flag         BOOLEAN:=FALSE;
    exists_in_t_names    BOOLEAN;
    ps_node_already_exists BOOLEAN;
    var_level_column      VARCHAR2(20):='';
    rcode                 VARCHAR2(4000);
    var_counted_options_flag VARCHAR2(1);
    var_current_lang      CZ_LOCALIZED_TEXTS.language%TYPE := USERENV('LANG');
    SKIP_IT               EXCEPTION;
    WRONG_SQL             EXCEPTION;
    WRONG_COLUMN_TYPE     EXCEPTION;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
-- Bug6826702 : Returns true if the ps_node already exists in the model structure created out of the
--               same populator
--Bug8584377 commenting the below function.
/*FUNCTION check_for_ps_node_existence
(p_populator_id   IN  INTEGER,
p_parent_ps_node_id   IN  INTEGER,
p_property_ptr   IN  INTEGER,
p_item_type_ptr   IN  INTEGER,
p_item_id   IN  INTEGER,
p_ps_node_type   IN  INTEGER
) RETURN BOOLEAN IS
  rec_ps_node CZ_PS_NODES.ps_node_id%TYPE;
  v_found BOOLEAN;
  CURSOR cur_ps_node IS
    SELECT ps_node_id
      FROM cz_ps_nodes
     WHERE parent_id=p_parent_ps_node_id
     AND   from_populator_id=p_populator_id
     AND   NVL(property_backptr,NULL_VALUE)=NVL(p_property_ptr,NULL_VALUE)
     AND   NVL(item_type_backptr,NULL_VALUE)=NVL(p_item_type_ptr,NULL_VALUE)
     AND   NVL(item_id,NULL_VALUE)=NVL(p_item_id,NULL_VALUE)
     AND   NVL(ps_node_type,NULL_VALUE)=NVL(p_ps_node_type,NULL_VALUE)
     AND   deleted_flag='0';
BEGIN
  OPEN cur_ps_node;
  FETCH cur_ps_node INTO rec_ps_node;
  IF (cur_ps_node%FOUND) THEN
    v_found := TRUE;
  ELSE
    v_found := FALSE;
  END IF;
  CLOSE cur_ps_node;
  RETURN v_found;
END check_for_ps_node_existence;*/
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

BEGIN

    p_err:=0;

    Initialize_Sequence(mINTL_TEXT_SEQUENCE);

    --
    -- find various data for a given Populator --
    --
    SELECT filter_set_id,last_generation_date,view_name,owned_by_node_id,
           result_type,query_syntax,has_level,feature_type,name
    INTO var_filter_set_id,var_last_update,var_view_name,var_ps_node_id,
         var_result_type,var_sql,var_has_level,var_feature_type,var_pop_name
    FROM CZ_POPULATORS
    WHERE populator_id=p_populator_id;

    --
    -- convert result_type to ps_node_type
    -- * Developer sets result_type = signature_id
    --
    CZ_TYPES.get_Ps_Node_Type(p_signature_id    => var_result_type,
                              x_ps_node_type    => var_ps_node_type,
                              x_ps_node_subtype => var_feature_type);

    --
    -- find express_id which corresponds with Populator definition --
    --
    SELECT rule_id INTO var_rule_id FROM CZ_FILTER_SETS
    WHERE filter_set_id=var_filter_set_id;

    --
    -- find Timestamp of Populator definition --
    --
    SELECT LAST_UPDATE_DATE INTO var_curr_date FROM CZ_EXPRESSION_NODES
    WHERE rule_id=var_rule_id AND expr_parent_id IS NULL AND deleted_flag='0';

    --
    -- if definition has been changed then --
    -- regenerate Populator                --
    --

    -- the condition is commented out temporary
    -- because of the problem in Developer with
    -- properly setting of cz_expression_nodes.last_update_date
    --
    IF var_last_update<=var_curr_date OR var_last_update IS NULL OR mALWAYS_REGENERATE IN('1','Y') THEN
       Regenerate_unsec(p_populator_id => p_populator_id,
                       p_view_name    => var_view_name,
                       p_sql_query    => var_sql,
                       p_err          => p_err);
     END IF;

    --
    -- find devl_project_id of  populator's owner --
    --
    SELECT devl_project_id INTO var_project_id FROM CZ_PS_NODES
    WHERE ps_node_id=var_ps_node_id;

    --
    -- Allocate run_id for CZ_IMP_PS_NODES
    --
    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO p_run_id FROM dual;

    --
    -- by defualt feature has a type "List of Options" --
    --
    IF var_ps_node_type=PS_FEATURE_TYPE AND var_feature_type IS NULL THEN
       var_feature_type:='0';
    END IF;

    IF var_ps_node_type=PS_FEATURE_TYPE AND var_feature_type='0' THEN
       var_counted_options_flag := '0';
    END IF;

    var_sql:='('||var_sql||')';
    IF mCREATE_DEBUG_VIEWS IN('1','Y','YES') THEN
       var_sql:=var_view_name;
    END IF;

    BEGIN
        var_cursor := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(var_cursor, 'SELECT * FROM '||var_sql||' ORDER BY name', dbms_sql.native);
        var_exec := DBMS_SQL.EXECUTE(var_cursor);
        DBMS_SQL.DESCRIBE_COLUMNS(var_cursor, col_cnt, rec_tab);
    EXCEPTION
        WHEN OTHERS THEN
             rcode:=SQLERRM;
             RAISE WRONG_SQL;
    END;

    var_col_num := rec_tab.first;
    IF (var_col_num is not null) THEN
       LOOP
          var_col_name:=LOWER(rec_tab(var_col_num).col_name);
          var_col_length:=rec_tab(var_col_num).col_max_len;
          t_col(var_col_num).col_name:=var_col_name;
          t_col(var_col_num).col_num:=var_col_num;

          IF var_col_name='property_id'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_property_ptr);
          END IF;
          IF var_col_name='name'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_name,var_col_length);
          END IF;
          IF var_col_name='item_type_id'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_item_type_ptr);
          END IF;
          IF var_col_name='item_id'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_item_id);
          END IF;
          IF var_col_name='desc_text'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_desc_text,var_col_length);
          END IF;
          IF var_col_name='primary_uom_code'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_primary_uom_code,var_col_length);
          END IF;
          IF var_col_name='quoteable_flag'  THEN
             DBMS_SQL.DEFINE_COLUMN(var_cursor,var_col_num,var_quoteable_flag,var_col_length);
          END IF;
          var_col_num := rec_tab.next(var_col_num);
          EXIT WHEN (var_col_num is null);
       END LOOP;
    END IF;

    var_tree_seq := 0;

    LOOP
       BEGIN
       IF DBMS_SQL.FETCH_ROWS(var_cursor)=0 THEN
          EXIT;
       ELSE
          IF t_col.Count>0 THEN
             FOR i IN t_col.First..t_col.Last
             LOOP
                BEGIN
                    var_col_name:=t_col(i).col_name;
                    var_col_num:=t_col(i).col_num;
                    rcode:=var_col_name;
                    IF  var_col_name='property_id' THEN
                        DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_property_ptr);
                    END IF;
                    IF  var_col_name='name' THEN
                        DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_name);
                    END IF;
                    IF  var_col_name='item_type_id' THEN
                        DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_item_type_ptr);
                    END IF;
                    IF  var_col_name='item_id' THEN
                        DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_item_id);
                    END IF;
                    IF  var_col_name='desc_text' THEN
                        DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_desc_text);
                    END IF;
                    IF  var_col_name='primary_uom_code' THEN
                        DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_primary_uom_code);
                    END IF;
                    IF  var_col_name='quoteable_flag' THEN
                       DBMS_SQL.COLUMN_VALUE(var_cursor,var_col_num,var_quoteable_flag);
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                         RAISE WRONG_COLUMN_TYPE;
                END;
             END LOOP;
          END IF;

    --Bug6826702 : Moved code piece down

          BEGIN
            SELECT intl_text_id INTO var_new_text_id
              FROM CZ_PS_NODES
             WHERE parent_id=var_ps_node_id AND
                   FROM_POPULATOR_ID=p_populator_id AND
                   NVL(PROPERTY_BACKPTR,NULL_VALUE)=NVL(var_property_ptr,NULL_VALUE) AND
                   NVL(ITEM_TYPE_BACKPTR,NULL_VALUE)=NVL(var_item_type_ptr,NULL_VALUE) AND
                   NVL(ITEM_ID,NULL_VALUE)=NVL(var_item_id,NULL_VALUE) AND
                   NVL(PS_NODE_TYPE,NULL_VALUE)=NVL(var_ps_node_type,NULL_VALUE) AND deleted_flag='0';

                   ps_node_already_exists := TRUE;  --Bug8584377

            SELECT text_str INTO var_text_str FROM CZ_INTL_TEXTS
             WHERE intl_text_id=var_new_text_id;

            IF  NVL(var_text_str,'0') <> NVL(var_desc_text,'0') THEN

              --
              -- set localized_str to var_desc_text ( = new for current language = var_current_lang )
              -- and set source_lang to current language
              -- for those localized texts wfor which language <> current language and
              -- source language <> current language
              --
              UPDATE CZ_LOCALIZED_TEXTS
                 SET localized_str=var_desc_text,
                     source_lang=var_current_lang
               WHERE intl_text_id=var_new_text_id;

            END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
            ps_node_already_exists := FALSE;        --Bug8584377
--Bug8584377 Moved the insert into cz_intl_texts query to Execute_unsec procedure.
          END;

          var_key:=TO_CHAR(NVL(var_property_ptr,NULL_VALUE))||':'||
                   TO_CHAR(NVL(var_item_type_ptr,NULL_VALUE))||':'||
                   TO_CHAR(NVL(var_item_id,NULL_VALUE))||':'||
                   TO_CHAR(NVL(var_ps_node_type,NULL_VALUE));

/*
          IF var_has_item_type='0' AND var_item_type_ptr IS NOT NULL THEN
              var_has_item_type:='1';
          END IF;

          IF var_has_item='0' AND var_item_id IS NOT NULL THEN
             var_has_item:='1';
          END IF;

          IF var_has_property='0' AND var_property_ptr IS NOT NULL THEN
             var_has_property:='1';
          END IF;
*/
          IF var_ps_node_type IN (258,259,263) THEN
            var_instantiable_flag := 2;
            var_minimum := 1;
            var_maximum := 1;
          ELSIF var_ps_node_type = 264 THEN
            var_instantiable_flag := 3;
            var_minimum := 1;
            var_maximum := 1;
          ELSIF var_ps_node_type = 261 AND var_feature_type <> '0' THEN
            var_instantiable_flag := NULL;
            var_minimum := NULL;
            var_maximum := NULL;
          ELSE
            var_instantiable_flag := NULL;
            var_minimum := 1;
            var_maximum := 1;
          END IF;

	  --Bug6826702 : Code change to avert the deletion of an existing eligible ps_node, during repopulation
          --vsingava 08th Sep 2008
          --Bug8584377 commenting the below call,as this is achieved even without the check_for_ps_node_existence function call.
          --ps_node_already_exists := check_for_ps_node_existence(p_populator_id ,var_ps_node_id, var_property_ptr, var_item_type_ptr,
          --    var_item_id, var_ps_node_type);

          exists_in_t_names := FALSE;
          IF t_names.Count>0 THEN
             FOR h IN t_names.First..t_names.Last
             LOOP
                IF t_names(h)=var_name THEN
                   exists_in_t_names := TRUE;
                END IF;
             END LOOP;
          END IF;

          IF ps_node_already_exists AND exists_in_t_names THEN

          -- Need to update the previous entry
          --LOG_REPORT('CZ_POPULATORS_PKG.preview','Updating previous entry');
          UPDATE CZ_IMP_PS_NODES
          SET PROPERTY_BACKPTR = var_property_ptr,ITEM_TYPE_BACKPTR = var_item_type_ptr,INTL_TEXT_ID = var_new_text_id,
              ITEM_ID = var_item_id,USER_STR03 = var_key,FSK_PSNODE_3_EXT = var_fk_key,
              PRIMARY_UOM_CODE = var_primary_uom_code,
              QUOTEABLE_FLAG = var_quoteable_flag,
              INSTANTIABLE_FLAG = var_instantiable_flag,
              COUNTED_OPTIONS_FLAG = var_counted_options_flag
          WHERE RUN_ID = p_run_id AND DEVL_PROJECT_ID = var_project_id AND
                PARENT_ID = var_ps_node_id AND NAME = var_name;
          -- Implies we encountered the new node later to old node or another new node
          ELSE
            IF(NOT ps_node_already_exists) AND exists_in_t_names THEN-- Implies we encountered the new node later to old node or another new node
              --LOG_REPORT('CZ_POPULATORS_PKG.preview','Skipping entry :'||var_name);
              RAISE SKIP_IT;
            ELSE
          -- We reach here, when import_table_existence_flag is alone FALSE. May be inserting the new one or the old one
          -- Need to INSERT
                    t_names(t_names.Count+1):=var_name;
                    var_tree_seq:=var_tree_seq+1;
          --LOG_REPORT('CZ_POPULATORS_PKG.preview','Inserting entry :'||var_name);

         --Bug8584377
              IF (NOT ps_node_already_exists) THEN
                var_new_text_id := get_Next_Seq_Id(mINTL_TEXT_SEQUENCE);
              INTL_ID_DESC_TEXT_ARRAY(var_new_text_id) := var_desc_text;
              END IF;
              INSERT INTO CZ_IMP_PS_NODES
                 (RUN_ID,
                  PS_NODE_ID,
                  PARENT_ID,
                  DEVL_PROJECT_ID,
                  NAME,
                  FROM_POPULATOR_ID,
                  PROPERTY_BACKPTR,
                  ITEM_TYPE_BACKPTR,
                  INTL_TEXT_ID,
                  SUB_CONS_ID,
                  ITEM_ID,
                  MINIMUM,
                  MAXIMUM,
                  PS_NODE_TYPE,
                  FEATURE_TYPE,
                  PRODUCT_FLAG,
                  ORDER_SEQ_FLAG,
                  SYSTEM_NODE_FLAG,
                  TREE_SEQ,
                  UI_OMIT,
                  SO_ITEM_TYPE_CODE,
                  EFFECTIVE_USAGE_MASK,
                  EFFECTIVE_FROM,
                  EFFECTIVE_UNTIL,
                  UI_SECTION,
                  DELETED_FLAG,
                  USER_STR03,
                  DECIMAL_QTY_FLAG,
                  FSK_PSNODE_3_EXT,
                  PRIMARY_UOM_CODE,
                  QUOTEABLE_FLAG,
                  MULTI_CONFIG_FLAG,
                  INSTANTIABLE_FLAG,
                  COUNTED_OPTIONS_FLAG)
            VALUES
                 (p_run_id,
                  0,
                  var_ps_node_id,
                  var_project_id,
                  var_name,
                  p_populator_id,
                  var_property_ptr,
                  var_item_type_ptr,
                  var_new_text_id,
                  NULL,
                  var_item_id,
                  var_minimum,
                  var_maximum,
                  var_ps_node_type,
                  var_feature_type,
                  '0',
                  '0',
                  '0',
                  var_tree_seq,
                  '0',
                  NULL,
                  '0000000000000000',
                  EPOCH_BEGIN,
                  EPOCH_END,
                  '0',
                  '0',
                  var_key,
                  '0',
                  var_fk_key,
                  var_primary_uom_code,
                  var_quoteable_flag,
                  '1',
                  var_instantiable_flag,
                  var_counted_options_flag);
          END IF;
         END IF;
       END IF;
       EXCEPTION
          WHEN SKIP_IT THEN
               NULL;
       END;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(var_cursor);

    --
    -- set descriptive fields --
    --
    --UPDATE CZ_POPULATORS SET has_item_type=var_has_item_type,
    --                         has_item=var_has_item,
    --                         has_property=var_has_property
    --WHERE populator_id=p_populator_id;

EXCEPTION
    WHEN WRONG_COLUMN_TYPE THEN
         IF DBMS_SQL.IS_OPEN(var_cursor) THEN
            DBMS_SQL.CLOSE_CURSOR(var_cursor);
         END IF;
         p_err:=mRUN_ID;
         LOG_REPORT('CZ_POPULATORS_PKG.Preview','Preview populator "'||var_pop_name||'" - wrong type of column '||rcode);
    WHEN WRONG_SQL THEN
         IF DBMS_SQL.IS_OPEN(var_cursor) THEN
            DBMS_SQL.CLOSE_CURSOR(var_cursor);
         END IF;
         p_err:=mRUN_ID;
         LOG_REPORT('CZ_POPULATORS_PKG.Preview','Preview populator "'||var_pop_name||'" - wrong SQL query is used : '||rcode);
    WHEN OTHERS THEN
         IF DBMS_SQL.IS_OPEN(var_cursor) THEN
            DBMS_SQL.CLOSE_CURSOR(var_cursor);
         END IF;
         p_err:=mRUN_ID;
         LOG_REPORT('CZ_POPULATORS_PKG.Preview','Preview populator "'||var_pop_name||'" failed :'||SQLERRM);
END Preview_unsec;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Preview
(p_populator_id   IN  INTEGER,
 p_run_id         OUT NOCOPY INTEGER,
 p_err            OUT NOCOPY INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL) IS

    l_model_id             NUMBER;
    l_locked_entities_tbl  cz_security_pvt.number_type_tbl;
    l_has_priveleges       VARCHAR2(255);
    l_msg_data             VARCHAR2(32000);
    l_lock_status          VARCHAR2(255);
    l_return_status        VARCHAR2(255);
    l_msg_count            NUMBER;

BEGIN

    p_err := 0;

    IF UPPER(p_init_fnd_stack) IN('1','Y','YES') THEN
      FND_MSG_PUB.initialize;
    END IF;

    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO mRUN_ID FROM dual;

    --
    -- check global flag that equals '1' if model is already locked
    -- by calling sequirity package
    --
    IF mDB_SETTING_USE_SECURITY THEN

       SELECT devl_project_id INTO l_model_id FROM CZ_PS_NODES
       WHERE ps_node_id IN(SELECT owned_by_node_id FROM CZ_POPULATORS
       WHERE populator_id=p_populator_id) AND deleted_flag='0' AND rownum<2;

       lock_Model(l_model_id, l_locked_entities_tbl);

    END IF;

    Preview_unsec(p_populator_id => p_populator_id,
                  p_run_id       => p_run_id,
                  p_err          => p_err);


    IF l_locked_entities_tbl.COUNT>0 AND mDB_SETTING_USE_SECURITY THEN
      unlock_Model(l_model_id, l_locked_entities_tbl);
    END IF;

EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN
      p_err := mRUN_ID;
END Preview;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- populate PS Tree :
-- insert/update data from CZ_IMP_PS_NODES into CZ_PS_NODES
--
PROCEDURE Execute_unsec
(p_populator_id IN     INTEGER,
 p_run_id       IN OUT NOCOPY INTEGER,
 p_err          OUT NOCOPY    INTEGER) IS

    TYPE IntArray        IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    t_ps_node_id         IntArray;
    t_devl_project       IntArray;
    t_intl_text_id       IntArray;
    var_inserts          INTEGER;
    var_updates          INTEGER;
    var_failed           INTEGER;
    var_dups             INTEGER;
    var_tree_seq         INTEGER;
    var_name_counter     INTEGER;
    var_pop_name         CZ_POPULATORS.name%TYPE;
    var_name             CZ_PS_NODES.name%TYPE;
    var_view             CZ_POPULATORS.view_name%TYPE;
    var_sql              CZ_POPULATORS.query_syntax%TYPE;
    var_devl_project_id  CZ_PS_NODES.devl_project_id%TYPE;
    var_parent_id        CZ_PS_NODES.ps_node_id%TYPE;
    var_component_id     CZ_PS_NODES.component_id%TYPE;
    var_new_ps_id        CZ_PS_NODES.ps_node_id%TYPE;
    STOP_IT              EXCEPTION;

BEGIN

    p_err:=0;

    Initialize_Sequence(mPS_NODE_SEQUENCE);

    --
    -- if p_run_id is empty then we need Preview first --
    --
    IF p_run_id IS NULL OR p_run_id=0 THEN
       IF mUSE_IMPORT IN('1','Y','YES') THEN
          Regenerate_unsec(p_populator_id,var_view,var_sql,p_err);
       END IF;
       Preview_unsec(p_populator_id,p_run_id,p_err);
    END IF;

    --
    -- find owner of Populator --
    --
    SELECT owned_by_node_id,name INTO var_parent_id,var_pop_name
    FROM CZ_POPULATORS WHERE populator_id=p_populator_id;

    SELECT component_id INTO var_component_id FROM CZ_PS_NODES
    WHERE ps_node_id=var_parent_id;

    IF mUSE_IMPORT IN('1','Y','YES') THEN
       --
       -- delete those PS Tree nodes which don't satisfy  --
       -- a Populator condition anymore                   --
       --
       UPDATE CZ_PS_NODES SET deleted_flag='1'
       WHERE parent_id=var_parent_id
       AND deleted_flag='0' AND
       USER_STR03 NOT IN
       (SELECT USER_STR03
       FROM CZ_IMP_PS_NODES WHERE run_id=p_run_id) AND FROM_POPULATOR_ID=p_populator_id
       RETURNING devl_project_id,ps_node_id,intl_text_id
       BULK COLLECT INTO t_devl_project,t_ps_node_id,t_intl_text_id;

       --
       -- delete an associated non-virtual components --
       --
       IF t_ps_node_id.Count>0 THEN
          FORALL i IN t_ps_node_id.First..t_ps_node_id.Last
                 UPDATE CZ_MODEL_REF_EXPLS SET deleted_flag='1'
                 WHERE model_id=t_devl_project(i) AND
                 model_ref_expl_id
                 IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                 WHERE deleted_flag='0'
                 START WITH component_id=t_ps_node_id(i)
                 CONNECT BY PRIOR  model_ref_expl_id=parent_expl_node_id);

         FORALL i IN t_intl_text_id.First..t_intl_text_id.Last
           UPDATE CZ_LOCALIZED_TEXTS
              SET deleted_flag='1'
            WHERE intl_text_id=t_intl_text_id(i);
       END IF;


       CZ_IMP_PS_NODE.KRS_PS_NODE(p_run_id,
                                  100,
                                  1000,
                                  var_inserts,
                                  var_updates,
                                  var_failed,
                                  var_dups,
                                  mXFR_PROJECT_GROUP);
       CZ_IMP_PS_NODE.XFR_PS_NODE(p_run_id,
                                  100,
                                  1000,
                                  var_inserts,
                                  var_updates,
                                  var_failed,
                                  mXFR_PROJECT_GROUP);

       IF var_failed>0 THEN
          p_err:=mRUN_ID;
          LOG_REPORT('CZ_POPULATORS_PKG.Execute','Populator failed ...');
       END IF;
       RAISE STOP_IT;
    END IF;

    --
    -- delete those PS Tree nodes which don't satisfy  --
    -- a Populator condition anymore                   --
    --
    UPDATE CZ_PS_NODES SET deleted_flag='1'
    WHERE parent_id=var_parent_id
    AND deleted_flag='0' AND
    (NVL(PROPERTY_BACKPTR,NULL_VALUE),
     NVL(ITEM_TYPE_BACKPTR,NULL_VALUE),NVL(ITEM_ID,NULL_VALUE),
     NVL(PS_NODE_TYPE,NULL_VALUE))
    NOT IN
    (SELECT NVL(PROPERTY_BACKPTR,NULL_VALUE),
            NVL(ITEM_TYPE_BACKPTR,NULL_VALUE),NVL(ITEM_ID,NULL_VALUE),
            NVL(PS_NODE_TYPE,NULL_VALUE)
    FROM CZ_IMP_PS_NODES WHERE run_id=p_run_id) AND FROM_POPULATOR_ID=p_populator_id
    RETURNING devl_project_id,ps_node_id,intl_text_id
    BULK COLLECT INTO t_devl_project,t_ps_node_id,t_intl_text_id;

    --
    -- delete an associated non-virtual components --
    --
    IF t_ps_node_id.Count>0 THEN
       FORALL i IN t_ps_node_id.First..t_ps_node_id.Last
              UPDATE CZ_MODEL_REF_EXPLS SET deleted_flag='1'
              WHERE model_id=t_devl_project(i) AND
              model_ref_expl_id
              IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                 WHERE deleted_flag='0'
                 START WITH component_id=t_ps_node_id(i)
                 CONNECT BY PRIOR  model_ref_expl_id=parent_expl_node_id);

       FORALL i IN t_intl_text_id.First..t_intl_text_id.Last
         UPDATE CZ_LOCALIZED_TEXTS
            SET deleted_flag='1'
          WHERE intl_text_id=t_intl_text_id(i);

    END IF;

    --
    -- find MAX tree_seq under ps_node_id of owner of Populator --
    --
    SELECT NVL(MAX(tree_seq),0) INTO var_tree_seq FROM CZ_PS_NODES
    WHERE parent_id=var_parent_id AND deleted_flag='0';

    --
    -- general loop :                                                   --
    -- update PS Tree Node if there is a correlated node in CZ_PS_NODES --
    -- otherwise just insert from CZ_IMP_PS_NODES into CZ_PS_NODES      --
    -- the following CZ_PS_NODES columns are used for checking :        --
    -- FROM_POPULATOR_ID                                                --
    -- PROPERTY_BACKPTR                                                 --
    -- ITEM_TYPE_BACKPTR								--
    -- ITEM_ID										--
    -- PS_NODE_TYPE									--
    --
    FOR i IN(SELECT INTL_TEXT_ID,DEVL_PROJECT_ID,FROM_POPULATOR_ID,PROPERTY_BACKPTR,
                    ITEM_TYPE_BACKPTR,ITEM_ID,PS_NODE_TYPE,FEATURE_TYPE,QUOTEABLE_FLAG,NAME
             FROM CZ_IMP_PS_NODES WHERE run_id=p_run_id)
    LOOP

      var_name := i.name;

      SELECT COUNT(*) INTO var_name_counter FROM CZ_PS_NODES
       WHERE parent_id=var_parent_id AND deleted_flag='0' AND
             (name=i.name OR name like 'Copy (%) of '||i.name);

      IF var_name_counter>1 THEN
        var_name := 'Copy ('||TO_CHAR(var_name_counter+1)||') of '||i.name;
      END IF;

      UPDATE CZ_PS_NODES
         SET name=var_name,intl_text_id=i.intl_text_id,
             feature_type=i.feature_type,quoteable_flag=i.quoteable_flag
       WHERE parent_id=var_parent_id AND
             FROM_POPULATOR_ID=p_populator_id AND
             NVL(PROPERTY_BACKPTR,NULL_VALUE)=NVL(i.PROPERTY_BACKPTR,NULL_VALUE) AND
             NVL(ITEM_TYPE_BACKPTR,NULL_VALUE)=NVL(i.ITEM_TYPE_BACKPTR,NULL_VALUE) AND
             NVL(ITEM_ID,NULL_VALUE)=NVL(i.ITEM_ID,NULL_VALUE) AND
             NVL(PS_NODE_TYPE,NULL_VALUE)=NVL(i.PS_NODE_TYPE,NULL_VALUE) AND deleted_flag='0';

      IF SQL%ROWCOUNT=0 THEN
        IF var_name_counter>0 THEN
          var_name := 'Copy ('||TO_CHAR(var_name_counter)||') of '||i.name;
        END IF;

        var_new_ps_id := get_Next_Seq_Id(mPS_NODE_SEQUENCE);
        var_tree_seq := var_tree_seq + 1;
        INSERT INTO CZ_PS_NODES
             (PS_NODE_ID,
              PARENT_ID,
              DEVL_PROJECT_ID,
              NAME,
              FROM_POPULATOR_ID,
              PROPERTY_BACKPTR,
              ITEM_TYPE_BACKPTR,
              INTL_TEXT_ID,
              SUB_CONS_ID,
              ITEM_ID,
              MINIMUM,
              MAXIMUM,
              PS_NODE_TYPE,
              FEATURE_TYPE,
              PRODUCT_FLAG,
              ORDER_SEQ_FLAG,
              SYSTEM_NODE_FLAG,
              TREE_SEQ,
              UI_OMIT,
              SO_ITEM_TYPE_CODE,
              EFFECTIVE_USAGE_MASK,
              EFFECTIVE_FROM,
              EFFECTIVE_UNTIL,
              UI_SECTION,
              DELETED_FLAG,
              USER_STR03,
              DECIMAL_QTY_FLAG,
              PRIMARY_UOM_CODE,
              QUOTEABLE_FLAG,
              MULTI_CONFIG_FLAG,
              VIRTUAL_FLAG,
              PERSISTENT_NODE_ID,
              INSTANTIABLE_FLAG,
              COMPONENT_ID,
              COUNTED_OPTIONS_FLAG)
        SELECT
              var_new_ps_id,
              PARENT_ID,
              DEVL_PROJECT_ID,
              var_name,
              p_populator_id,
              PROPERTY_BACKPTR,
              ITEM_TYPE_BACKPTR,
              INTL_TEXT_ID,
              SUB_CONS_ID,
              ITEM_ID,
              MINIMUM,
              MAXIMUM,
              PS_NODE_TYPE,
              FEATURE_TYPE,
              PRODUCT_FLAG,
              ORDER_SEQ_FLAG,
              SYSTEM_NODE_FLAG,
                      var_tree_seq,
              UI_OMIT,
              SO_ITEM_TYPE_CODE,
              EFFECTIVE_USAGE_MASK,
              EFFECTIVE_FROM,
              EFFECTIVE_UNTIL,
              UI_SECTION,
              DELETED_FLAG,
              USER_STR03,
              DECIMAL_QTY_FLAG,
              PRIMARY_UOM_CODE,
              QUOTEABLE_FLAG,
              MULTI_CONFIG_FLAG,
              '1',
              var_new_ps_id,
              INSTANTIABLE_FLAG,
              var_component_id,
              COUNTED_OPTIONS_FLAG
           FROM CZ_IMP_PS_NODES
           WHERE run_id=p_run_id AND
           NVL(FROM_POPULATOR_ID,NULL_VALUE)=NVL(i.FROM_POPULATOR_ID,NULL_VALUE) AND
           NVL(PROPERTY_BACKPTR,NULL_VALUE)=NVL(i.PROPERTY_BACKPTR,NULL_VALUE) AND
           NVL(ITEM_TYPE_BACKPTR,NULL_VALUE)=NVL(i.ITEM_TYPE_BACKPTR,NULL_VALUE) AND
           NVL(ITEM_ID,NULL_VALUE)=NVL(i.ITEM_ID,NULL_VALUE) AND
           NVL(PS_NODE_TYPE,NULL_VALUE)=NVL(i.PS_NODE_TYPE,NULL_VALUE);
 --Bug8584377 Moved the insert code from Preview_unsec procedure.
          INSERT INTO CZ_INTL_TEXTS(
              INTL_TEXT_ID,
              TEXT_STR,
              MODEL_ID,
              UI_DEF_ID,
              DELETED_FLAG)
          VALUES(
              i.INTL_TEXT_ID,
              INTL_ID_DESC_TEXT_ARRAY(i.INTL_TEXT_ID),
              i.DEVL_PROJECT_ID,
              NULL,
              '0');
      END IF;
END LOOP;

EXCEPTION
   WHEN STOP_IT THEN
        NULL;
   WHEN OTHERS THEN
        p_err:=mRUN_ID;
        LOG_REPORT('CZ_POPULATORS_PKG.Execute','Execute populator "'||var_pop_name||'" failed : '||SQLERRM);
END Execute_unsec;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Execute
(p_populator_id   IN INTEGER,
 p_run_id         IN OUT NOCOPY INTEGER,
 p_err            OUT NOCOPY    INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL) IS

    l_model_id             NUMBER;
    l_locked_entities_tbl  cz_security_pvt.number_type_tbl;
    l_has_priveleges       VARCHAR2(255);
    l_msg_data             VARCHAR2(32000);
    l_lock_status          VARCHAR2(255);
    l_return_status        VARCHAR2(255);
    l_msg_count            NUMBER;

BEGIN

    p_err := 0;

    IF UPPER(p_init_fnd_stack) IN('1','Y','YES') THEN
      FND_MSG_PUB.initialize;
    END IF;

    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO mRUN_ID FROM dual;

    --
    -- check global flag that equals '1' if model is already locked
    -- by calling sequirity package
    --
    IF mDB_SETTING_USE_SECURITY THEN

       SELECT devl_project_id INTO l_model_id FROM CZ_PS_NODES
       WHERE ps_node_id IN(SELECT owned_by_node_id FROM CZ_POPULATORS
       WHERE populator_id=p_populator_id) AND deleted_flag='0' AND rownum<2;

       lock_Model(l_model_id, l_locked_entities_tbl);

    END IF;

    Execute_unsec(p_populator_id => p_populator_id,
                  p_run_id       => p_run_id,
                  p_err          => p_err);

    IF l_locked_entities_tbl.COUNT>0 AND mDB_SETTING_USE_SECURITY THEN
      unlock_Model(l_model_id, l_locked_entities_tbl);
    END IF;

EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN
      p_err := mRUN_ID;
END Execute;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- repopulate all Populators for a given Model --
--
PROCEDURE Repopulate_unsec
(p_model_id       IN  INTEGER,
 p_regenerate_all IN  VARCHAR2,
 p_handle_invalid IN  VARCHAR2,
 p_handle_broken  IN  VARCHAR2,
 p_err            OUT NOCOPY INTEGER) IS
   TYPE IntArray  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    t_errors            IntArray;
    var_model_id        INTEGER;
    var_run_id          INTEGER;
    var_err             INTEGER;
    var_err_id          INTEGER;
    var_counter         INTEGER:=0;
    var_view            VARCHAR2(100);
    var_sql              CZ_POPULATORS.query_syntax%TYPE;
    SKIP_IT              EXCEPTION;
    MODEL_DOES_NOT_EXIST EXCEPTION;
BEGIN

    p_err:=0;

    --
    -- this is an additional checking for using within CZ_MODEL_OPERATIONS
    --
    BEGIN
         SELECT devl_project_id INTO var_model_id
         FROM CZ_DEVL_PROJECTS WHERE devl_project_id=p_model_id AND deleted_flag='0';
    EXCEPTION
         WHEN NO_DATA_FOUND THEN
              RAISE MODEL_DOES_NOT_EXIST;
    END;

    FOR i IN(SELECT populator_id FROM CZ_POPULATORS a,CZ_PS_NODES b
             WHERE a.owned_by_node_id=b.ps_node_id AND b.devl_project_id=p_model_id AND
             a.deleted_flag='0' AND b.deleted_flag='0')
    LOOP
       var_counter:=var_counter+1;
       BEGIN
          IF p_regenerate_all='1' THEN
             Regenerate_unsec(i.populator_id,var_view,var_sql,var_err);
             IF var_err>0 THEN
                t_errors(t_errors.Count+1):=var_err;
             END IF;
             IF p_handle_broken='0' THEN
                RAISE SKIP_IT;
             END IF;
             IF var_err>0 AND p_handle_invalid='0' THEN
                RAISE SKIP_IT;
             END IF;
          END IF;

          Preview_unsec(i.populator_id,var_run_id,var_err);

          IF var_err>0 AND (p_handle_invalid='0' OR p_handle_broken='0') THEN
             RAISE SKIP_IT;
          END IF;

          Execute_unsec(i.populator_id,var_run_id,var_err);
          IF var_err>0 THEN
             t_errors(t_errors.Count+1):=var_err;
          END IF;

      EXCEPTION
          WHEN SKIP_IT THEN
               NULL;
      END;
   END LOOP;

   --
   -- just one CZ_DB_LOGS.run_id should be used by Developer
   --
   IF t_errors.Count>0 THEN
      FORALL i IN 1..t_errors.Count
         UPDATE CZ_DB_LOGS SET run_id=mRUN_ID
         WHERE run_id=t_errors(i);
      p_err:=var_err_id;
   END IF;

EXCEPTION
   WHEN MODEL_DOES_NOT_EXIST THEN
        p_err:=mRUN_ID;
        LOG_REPORT('CZ_POPULATORS_PKG.Repopulate',
        'Model with model_id='||TO_CHAR(p_model_id)||' does not exist.');
END Repopulate_unsec;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Repopulate
(p_model_id       IN  INTEGER,
 p_regenerate_all IN  VARCHAR2,
 p_handle_invalid IN  VARCHAR2,
 p_handle_broken  IN  VARCHAR2,
 p_err            OUT NOCOPY INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL) IS

    l_locked_entities_tbl  cz_security_pvt.number_type_tbl;
    l_has_priveleges       VARCHAR2(255);
    l_msg_data             VARCHAR2(32000);
    l_lock_status          VARCHAR2(255);
    l_return_status        VARCHAR2(255);
    l_msg_count            NUMBER;

BEGIN

    p_err := 0;

    IF UPPER(p_init_fnd_stack) IN('1','Y','YES') THEN
      FND_MSG_PUB.initialize;
    END IF;

    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO mRUN_ID FROM dual;

    --
    -- check global flag that equals '1' if model is already locked
    -- by calling sequirity package
    --
    IF mDB_SETTING_USE_SECURITY THEN
      lock_Model(p_model_id, l_locked_entities_tbl);
    END IF;

    Repopulate_unsec(p_model_id       => p_model_id,
                     p_regenerate_all => p_regenerate_all,
                     p_handle_invalid => p_handle_invalid,
                     p_handle_broken  => p_handle_broken,
                     p_err            => p_err);

    IF l_locked_entities_tbl.COUNT>0 AND mDB_SETTING_USE_SECURITY THEN
      unlock_Model(p_model_id, l_locked_entities_tbl);
    END IF;

EXCEPTION
    WHEN FAILED_TO_LOCK_MODEL THEN
      p_err := mRUN_ID;
END Repopulate;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

BEGIN
    BEGIN
        SELECT UPPER(value) INTO mCREATE_DEBUG_VIEWS FROM CZ_DB_SETTINGS
        WHERE UPPER(setting_id)='CREATEPOPVIEWS';
    EXCEPTION
        WHEN OTHERS THEN
             mCREATE_DEBUG_VIEWS:='N';
    END;
    BEGIN
        SELECT UPPER(value) INTO mUSE_IMPORT FROM CZ_DB_SETTINGS
        WHERE UPPER(setting_id)='USEIMPORT';
    EXCEPTION
        WHEN OTHERS THEN
             mUSE_IMPORT:='N';
    END;

    BEGIN
        SELECT value INTO mUSE_LOCKING FROM CZ_DB_SETTINGS
        WHERE setting_id = 'USE_LOCKING' AND rownum<2;

        IF UPPER(mUSE_LOCKING) IN('0','N','NO') THEN
           mDB_SETTING_USE_SECURITY := FALSE;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
             mUSE_LOCKING  := '1';
             mDB_SETTING_USE_SECURITY := TRUE;
    END;

    BEGIN
        SELECT UPPER(value) INTO mALWAYS_REGENERATE FROM CZ_DB_SETTINGS
        WHERE UPPER(setting_id)='ALWAYS_REGENERATE_POPULATORS';
    EXCEPTION
        WHEN OTHERS THEN
             mALWAYS_REGENERATE := 'N';
    END;


END CZ_POPULATORS_PKG;

/
