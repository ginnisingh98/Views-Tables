--------------------------------------------------------
--  DDL for Package Body CZ_PS_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PS_COPY" AS
/*	$Header: czpscpb.pls 120.0 2005/05/25 07:27:11 appldev noship $ */

GLOBAL_ORIG_SYS_REF CZ_DEVL_PROJECTS.orig_sys_ref%TYPE;
BATCH_SIZE          INTEGER:=20000;
numRecords          INTEGER:=0;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                START PACKAGE
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

ENCLOSE_FOLDER INTEGER;

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
VALUES (GLOBAL_RUN_ID,
        SYSDATE,
        USER,
        1,
        p_caller,
        var_status,
        p_error_message);
COMMIT;

EXCEPTION
WHEN OTHERS THEN
     NULL;
END;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Initialize IS
BEGIN
numRecords:=0;
Sequences(1).name:='CZ_PS_NODES_S';
Sequences(2).name:='CZ_FILTER_SETS_S';
Sequences(3).name:='CZ_SUB_CON_SETS_S';
Sequences(4).name:='CZ_EXPRESSIONS_S';
Sequences(5).name:='CZ_RULES_S';
Sequences(6).name:='CZ_EXPRESSION_NODES_S';
Sequences(7).name:='CZ_POPULATORS_S';
Sequences(8).name:='CZ_RULE_FOLDERS_S';
Sequences(9).name:='CZ_GRID_DEFS_S';
Sequences(10).name:='CZ_GRID_COLS_S';
Sequences(11).name:='CZ_GRID_CELLS_S';
Sequences(12).name:='CZ_UI_DEFS_S';
Sequences(13).name:='CZ_UI_NODES_S';
Sequences(14).name:='CZ_FUNC_COMP_SPECS_S';
Sequences(15).name:='CZ_INTL_TEXTS_S';
Sequences(16).name:='CZ_MODEL_REF_EXPLS_S';

FlowId_PS_NODE.DELETE;
FlowId_INTL_TEXT.DELETE;
FlowId_EXPRESSION.DELETE;
FlowId_FILTER_SET.DELETE;
FlowId_RULE.DELETE;
FlowId_SUB_CON_SET.DELETE;
FlowId_POPULATOR.DELETE;
FlowId_EXPRESSION_NODE.DELETE;
FlowId_GRID_DEF.DELETE;
FlowId_GRID_COL.DELETE;
FlowId_GRID_CELL.DELETE;
FlowId_UI_DEF.DELETE;
FlowId_UI_NODE.DELETE;
FlowId_FUNC_COMP_SPEC.DELETE;
FlowId_RULE_FOLDER.DELETE;
FlowId_MODEL_REF_EXPL.DELETE;

FlowId_PS_NODE(NULL_):=NULL;
FlowId_INTL_TEXT(NULL_):=NULL;
FlowId_EXPRESSION(NULL_):=NULL;
FlowId_FILTER_SET(NULL_):=NULL;
FlowId_RULE(NULL_):=NULL;
FlowId_SUB_CON_SET(NULL_):=NULL;
FlowId_POPULATOR(NULL_):=NULL;
FlowId_EXPRESSION_NODE(NULL_):=NULL;
FlowId_GRID_DEF(NULL_):=NULL;
FlowId_GRID_COL(NULL_):=NULL;
FlowId_GRID_CELL(NULL_):=NULL;
FlowId_UI_DEF(NULL_):=NULL;
FlowId_UI_NODE(NULL_):=NULL;
FlowId_FUNC_COMP_SPEC(NULL_):=NULL;
FlowId_RULE_FOLDER(NULL_):=NULL;
FlowId_MODEL_REF_EXPL(NULL_):=NULL;

BEGIN
    SELECT value INTO BATCH_SIZE FROM
    CZ_DB_SETTINGS WHERE UPPER(setting_id)='BATCHSIZE';
EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN OTHERS THEN
     NULL;
END;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE PACK IS

BEGIN

IF numRecords>BATCH_SIZE THEN
   --LOG_REPORT('CZ_PS_COPY.PACK',TO_CHAR(BATCH_SIZE)|| ' records has been inserted...');
   numRecords:=0;
   COMMIT;
ELSE
   numRecords:=numRecords+1;
END IF;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_Next_Val
(p_id            IN OUT NOCOPY INTEGER,
 p_sequence_name IN     VARCHAR2) IS

var_id INTEGER;

BEGIN

FOR i IN Sequences.First..Sequences.Last
LOOP
   IF p_sequence_name=Sequences(i).name THEN
      IF NVL(p_id,1)>=NVL(Sequences(i).id,-INCREMENT)+INCREMENT-1
         OR (p_id IS NULL AND Sequences(i).id IS NOT NULL) THEN

         EXECUTE IMMEDIATE 'SELECT '||p_sequence_name||'.NEXTVAL FROM dual'
         INTO var_id;

         p_id:=var_id;
         Sequences(i).id:=var_id;
      ELSE
         p_id:=p_id+1;
      END IF;
   END IF;
END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_INTL_TEXT
(p_old_intl_text_id IN INTEGER,
 p_new_intl_text_id IN INTEGER,
 p_model_id         IN INTEGER,
 p_ui_def_id        IN INTEGER
 ) IS

BEGIN

INSERT INTO CZ_LOCALIZED_TEXTS
          (INTL_TEXT_ID,
           LOCALIZED_STR,
           LANGUAGE,
           SOURCE_LANG,
           ORIG_SYS_REF,
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER,
           UI_DEF_ID,
           MODEL_ID,
           SEEDED_FLAG)
SELECT
                       p_new_intl_text_id,
          LOCALIZED_STR,
          LANGUAGE,
          SOURCE_LANG,
          ORIG_SYS_REF,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          p_ui_def_id,
          p_model_id,
          SEEDED_FLAG
FROM CZ_LOCALIZED_TEXTS
WHERE intl_text_id=p_old_intl_text_id AND deleted_flag=NO_FLAG;

PACK;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE COPY_DEVL_PROJECT
(p_new_name        IN VARCHAR2) IS

i                   CZ_DEVL_PROJECTS%ROWTYPE;
var_name            CZ_DEVL_PROJECTS.NAME%TYPE;
var_intl_text_id    CZ_INTL_TEXTS.intl_text_id%TYPE;

BEGIN

SELECT CZ_PS_NODES_S.NEXTVAL INTO NEW_PROJECT_ID FROM dual;
SELECT * INTO i FROM CZ_DEVL_PROJECTS
WHERE DEVL_PROJECT_ID=OLD_PROJECT_ID  AND deleted_flag=NO_FLAG;

GLOBAL_ORIG_SYS_REF:=i.ORIG_SYS_REF;

IF p_new_name IS NULL THEN
   var_name:=i.Name||'-'||to_char(NEW_PROJECT_ID);
ELSE
   var_name:=p_new_name;
END IF;

var_intl_text_id:=NULL;
IF i.intl_text_id IS NOT NULL THEN
   get_Next_Val(var_intl_text_id,'CZ_INTL_TEXTS_S');
   Copy_INTL_TEXT(i.intl_text_id,var_intl_text_id,NEW_PROJECT_ID,NULL);
END IF;


INSERT INTO CZ_DEVL_PROJECTS
      (DEVL_PROJECT_ID,
       INTL_TEXT_ID,
       NAME,
       PERSISTENT_PROJECT_ID,
       VERSION,
       DESC_TEXT ,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER,
       ORIG_SYS_REF,
       LAST_STRUCT_UPDATE,
       LAST_LOGIC_UPDATE,
       PUBLISHED,
       MODEL_TYPE,
       PRODUCT_KEY,
       ORGANIZATION_ID,
       INVENTORY_ITEM_ID)
VALUES(
                          NEW_PROJECT_ID,
                          var_intl_text_id,
                          var_name,
      i.PERSISTENT_PROJECT_ID,
      i.VERSION,
      i.DESC_TEXT ,
      i.DELETED_FLAG,
      i.SECURITY_MASK,
      i.CHECKOUT_USER,
      i.ORIG_SYS_REF,
      i.LAST_STRUCT_UPDATE,
      i.LAST_LOGIC_UPDATE,
      i.PUBLISHED,
      i.MODEL_TYPE,
      i.PRODUCT_KEY,
      i.ORGANIZATION_ID,
      i.INVENTORY_ITEM_ID);

INSERT INTO CZ_RP_ENTRIES(object_type,object_id,enclosing_folder,deleted_flag,name)
SELECT object_type,NEW_PROJECT_ID,DECODE(ENCLOSE_FOLDER,-1,enclosing_folder,ENCLOSE_FOLDER),deleted_flag,var_name
FROM CZ_RP_ENTRIES
WHERE object_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG;

PACK;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_EXPRESSION IS

new_id      INTEGER;

BEGIN

FOR i IN (SELECT  *  FROM CZ_EXPRESSIONS
WHERE DEVL_PROJECT_ID=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   BEGIN
   get_Next_Val(new_id,'CZ_EXPRESSIONS_S');

   INSERT INTO CZ_EXPRESSIONS(
          EXPRESS_ID,
          DEVL_PROJECT_ID,
          NAME,
          EXPR_STR,
          DESC_TEXT,
          PRESENT_TYPE,
          PARSED_FLAG,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          PERSISTENT_EXPRESSION_ID)
   VALUES(
                        new_id,
                        NEW_PROJECT_ID,
          i.NAME,
          i.EXPR_STR,
          i.DESC_TEXT,
          i.PRESENT_TYPE,
          i.PARSED_FLAG,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
          i.PERSISTENT_EXPRESSION_ID);

   PACK;

   FlowId_EXPRESSION(i.express_id):=new_id;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;
END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_XFR_PROJECT_BILL IS

BEGIN

IF GLOBAL_ORIG_SYS_REF IS NOT NULL THEN
   INSERT INTO CZ_XFR_PROJECT_BILLS
          (ORGANIZATION_ID,
          COMPONENT_ITEM_ID,
          DESCRIPTION,
          LAST_IMPORT_RUN_ID,
          LAST_IMPORT_DATE,
          SOURCE_BILL_DELETED,
          TOP_ITEM_ID,
          DELETED_FLAG,
          EXPLOSION_TYPE,
          BILL_REVISION_DATE,
          EFF_FROM,
          EFF_TO,
          SOURCE_SERVER,
          MODEL_PS_NODE_ID,
          COPY_ADDL_CHILD_MODELS)
   SELECT
          ORGANIZATION_ID,
          COMPONENT_ITEM_ID,
          DESCRIPTION,
          LAST_IMPORT_RUN_ID,
          LAST_IMPORT_DATE,
          SOURCE_BILL_DELETED,
          TOP_ITEM_ID,
                              YES_FLAG,
          EXPLOSION_TYPE,
          BILL_REVISION_DATE,
          EFF_FROM,
          EFF_TO,
          SOURCE_SERVER,
                              NEW_PROJECT_ID,
          COPY_ADDL_CHILD_MODELS
   FROM CZ_XFR_PROJECT_BILLS
   WHERE  model_ps_node_id=OLD_PROJECT_ID;

   PACK;

END IF;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_FILTER_SET IS

new_id      INTEGER;
new_exp_id  INTEGER;
k           INTEGER;
BEGIN

IF FlowId_EXPRESSION.Count>0 THEN

k:=FlowId_EXPRESSION.First;
LOOP
   BEGIN
   FOR i IN (SELECT * FROM CZ_FILTER_SETS
             WHERE express_id=k AND deleted_flag=NO_FLAG)
   LOOP
      BEGIN
      new_exp_id:=FlowId_EXPRESSION(k);

      IF (new_exp_id IS not NULL) or (new_exp_id<>NULL_) THEN

         get_Next_Val(new_id,'CZ_FILTER_SETS_S');

         INSERT INTO CZ_FILTER_SETS
                (FILTER_SET_ID,
                 DEVL_PROJECT_ID,
                 EXPRESS_ID,
                 SOURCE_TYPE,
                 DELETED_FLAG,
                 SECURITY_MASK,
                 CHECKOUT_USER,
                 SOURCE_VIEW_NAME,
                 SOURCE_VIEW_OWNER,
                 SOURCE_SYNTAX)
         VALUES (              new_id,
                               NEW_PROJECT_ID,
                               new_exp_id,
                 i.SOURCE_TYPE,
                 i.DELETED_FLAG,
                 i.SECURITY_MASK,
                 i.CHECKOUT_USER,
                 i.SOURCE_VIEW_NAME,
                 i.SOURCE_VIEW_OWNER,
                 i.SOURCE_SYNTAX);

         PACK;

         FlowId_FILTER_SET(i.filter_set_id):=new_id;

       END IF;

       EXCEPTION
       WHEN NO_DATA_FOUND THEN
       NULL;
       WHEN OTHERS THEN
       NULL;
       END;
   END LOOP;

   k:=FlowId_EXPRESSION.NEXT(k);
   IF k IS NULL THEN
      EXIT;
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END IF;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_SUB_CON_SET
(p_old_sub_id  IN      INTEGER,
 p_out_sub_id  IN OUT NOCOPY  INTEGER) IS

new_id      INTEGER;

BEGIN

IF p_old_sub_id IS NOT NULL THEN
   get_Next_Val(new_id,'CZ_SUB_CON_SETS_S');
   INSERT INTO CZ_SUB_CON_SETS
   (SUB_CONS_ID,
    NAME,
    DESC_TEXT,
    DELETED_FLAG,
    SECURITY_MASK,
    CHECKOUT_USER)
   SELECT new_id,
          NAME,
          DESC_TEXT,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER
   FROM CZ_SUB_CON_SETS
   WHERE sub_cons_id=p_old_sub_id AND deleted_flag=NO_FLAG;

   PACK;

   p_out_sub_id:=new_id;
   FlowId_SUB_CON_SET(p_old_sub_id):=new_id;
ELSE
   p_out_sub_id:=NULL;
END IF;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_PS_PROP_VAL
(p_old_ps_id  IN INTEGER,
 p_new_ps_id  IN INTEGER) IS

BEGIN
-- sselahi
FOR i IN (SELECT ps_node_id,property_id,data_value,data_num_value
          FROM CZ_PS_PROP_VALS
          WHERE ps_node_id=p_old_ps_id AND deleted_flag='0')
LOOP
   INSERT INTO CZ_PS_PROP_VALS
          (PS_NODE_ID,
           PROPERTY_ID,
           DATA_VALUE,
           DATA_NUM_VALUE, -- sselahi
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER)
   SELECT  p_new_ps_id,
           PROPERTY_ID,
           DATA_VALUE,
           DATA_NUM_VALUE, -- sselahi
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER
   FROM CZ_PS_PROP_VALS
   WHERE PS_NODE_ID=p_old_ps_id AND property_id=i.property_id
   AND data_value=i.data_value AND data_num_value=i.data_num_value AND deleted_flag=NO_FLAG;

   PACK;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_MODEL_REF_EXPL IS

new_id                   INTEGER;
new_parent               INTEGER;
new_child                INTEGER;
new_referring_node_id    INTEGER;
new_component_id         INTEGER;
new_child_model_expl_id  INTEGER;

BEGIN

FOR i IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
          WHERE model_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   get_Next_Val(new_id,'CZ_MODEL_REF_EXPLS_S');
   FlowId_MODEL_REF_EXPL(i.model_ref_expl_id):=new_id;
END LOOP;

FOR i IN (SELECT * FROM CZ_MODEL_REF_EXPLS
          WHERE model_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
    IF i.parent_expl_node_id IS NOT NULL THEN
        new_parent:=FlowId_MODEL_REF_EXPL(i.parent_expl_node_id);
    ELSE
        new_parent:=NULL;
    END IF;
    new_child:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);

    IF i.referring_node_id IS NOT NULL THEN
       BEGIN
       new_referring_node_id:=FlowId_PS_NODE(i.referring_node_id);
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            new_referring_node_id:=i.referring_node_id;
       END;
    ELSE
       new_referring_node_id:=NULL;
    END IF;

    IF i.ps_node_type=REFRENCE_NODE_TYPE THEN
       new_component_id:=i.component_id;
    ELSE
       BEGIN
       new_component_id:=FlowId_PS_NODE(i.component_id);
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            new_component_id:=i.component_id;
       END;
    END IF;

    IF i.child_model_expl_id IS NOT NULL THEN
       BEGIN
       new_child_model_expl_id:=FlowId_MODEL_REF_EXPL(i.child_model_expl_id);
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
            new_child_model_expl_id:=i.child_model_expl_id;
       END;
    ELSE
       new_child_model_expl_id:=NULL;
    END IF;

    INSERT INTO CZ_MODEL_REF_EXPLS
          (model_ref_expl_id,
           parent_expl_node_id,
           referring_node_id,
           model_id,
           component_id,
           child_model_expl_id,
           ps_node_type,
           virtual_flag,
           node_depth,
           expl_node_type,
           has_trackable_children,
           deleted_flag)
    VALUES(              new_child,
                         new_parent,
                         new_referring_node_id,
                         NEW_PROJECT_ID,
                         new_component_id,
                         new_child_model_expl_id,
           i.ps_node_type,
           i.virtual_flag,
           i.node_depth,
           i.expl_node_type,
           i.has_trackable_children,
           i.deleted_flag);

   PACK;

END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_PS_NODE IS

new_parent        INTEGER;
new_child         INTEGER;
new_intl_text_id  INTEGER;
new_sub_cons_id   INTEGER;
sub_id            INTEGER;
new_id            INTEGER;

BEGIN

FOR i IN (SELECT ps_node_id FROM CZ_PS_NODES
          WHERE devl_project_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
    get_Next_Val(new_id,'CZ_PS_NODES_S');
    FlowId_PS_NODE(i.ps_node_id):=new_id;
END LOOP;

FlowId_PS_NODE(OLD_PROJECT_ID):=NEW_PROJECT_ID;

FOR i IN (SELECT * FROM CZ_PS_NODES WHERE devl_project_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   BEGIN
   IF i.parent_id IS NOT NULL THEN
      new_parent:=FlowId_PS_NODE(i.parent_id);
      new_child:=FlowId_PS_NODE(i.ps_node_id);
   ELSE
      new_parent:=NULL;
      new_child:=NEW_PROJECT_ID;
      new_intl_text_id:=NULL;
   END IF;
   IF i.intl_text_id IS NOT NULL THEN
      get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
      Copy_INTL_TEXT(i.intl_text_id,new_intl_text_id,NEW_PROJECT_ID,NULL);
   ELSE
      new_intl_text_id:=NULL;
   END IF;

   get_Next_Val(new_sub_cons_id,'CZ_SUB_CON_SETS_S');
   Copy_SUB_CON_SET(i.sub_cons_id,new_sub_cons_id);

   INSERT INTO CZ_PS_NODES
       (PS_NODE_ID,
        DEVL_PROJECT_ID,
        FROM_POPULATOR_ID,
        PROPERTY_BACKPTR,
        ITEM_TYPE_BACKPTR,
        INTL_TEXT_ID,
        SUB_CONS_ID,
        ITEM_ID,
        NAME,
        RESOURCE_FLAG,
        INITIAL_VALUE,
        initial_num_value, -- sselahi
        PARENT_ID,
        MINIMUM,
        MAXIMUM,
        PS_NODE_TYPE,
        FEATURE_TYPE,
        PRODUCT_FLAG,
        REFERENCE_ID,
        MULTI_CONFIG_FLAG,
        ORDER_SEQ_FLAG,
        SYSTEM_NODE_FLAG,
        TREE_SEQ,
        COUNTED_OPTIONS_FLAG,
        UI_OMIT,
        UI_SECTION,
        BOM_TREATMENT,
        ORIG_SYS_REF,
        BOM_REQUIRED_FLAG,
        SO_ITEM_TYPE_CODE,
        MINIMUM_SELECTED,
        MAXIMUM_SELECTED,
        DELETED_FLAG,
        SECURITY_MASK,
        CHECKOUT_USER,
        USER_NUM01,
        USER_NUM02,
        USER_NUM03,
        USER_NUM04,
        USER_STR01,
        USER_STR02,
        USER_STR03,
        USER_STR04,
        VIRTUAL_FLAG,
        DECIMAL_QTY_FLAG,
        VIOLATION_TEXT_ID,
        EFFECTIVITY_SET_ID,
        EFFECTIVE_FROM,
        EFFECTIVE_UNTIL,
        EFFECTIVE_USAGE_MASK,
        COMPONENT_SEQUENCE_ID,
        QUOTEABLE_FLAG,
        PRIMARY_UOM_CODE,
        PERSISTENT_NODE_ID,
        BOM_SORT_ORDER,
        COMPONENT_SEQUENCE_PATH,
        IB_TRACKABLE)
 VALUES(                 new_child,
                         NEW_PROJECT_ID,
        i.FROM_POPULATOR_ID,
        i.PROPERTY_BACKPTR,
        i.ITEM_TYPE_BACKPTR,
                         new_intl_text_id,
                         new_sub_cons_id,
        i.ITEM_ID,
        i.NAME,
        i.RESOURCE_FLAG,
        i.INITIAL_VALUE,
        i.initial_num_value, -- sselahi
                          new_parent,
        i.MINIMUM,
        i.MAXIMUM,
        i.PS_NODE_TYPE,
        i.FEATURE_TYPE,
        i.PRODUCT_FLAG,
        i.REFERENCE_ID,
        i.MULTI_CONFIG_FLAG,
        i.ORDER_SEQ_FLAG,
        i.SYSTEM_NODE_FLAG,
        i.TREE_SEQ,
        i.COUNTED_OPTIONS_FLAG,
        i.UI_OMIT,
        i.UI_SECTION,
        i.BOM_TREATMENT,
        i.ORIG_SYS_REF,
        i.BOM_REQUIRED_FLAG,
        i.SO_ITEM_TYPE_CODE,
        i.MINIMUM_SELECTED,
        i.MAXIMUM_SELECTED,
        i.DELETED_FLAG,
        i.SECURITY_MASK,
        i.CHECKOUT_USER,
        i.USER_NUM01,
        i.USER_NUM02,
        i.USER_NUM03,
        i.USER_NUM04,
        i.USER_STR01,
        i.USER_STR02,
        i.USER_STR03,
        i.USER_STR04,
        i.VIRTUAL_FLAG,
        i.DECIMAL_QTY_FLAG,
        i.VIOLATION_TEXT_ID,
        i.EFFECTIVITY_SET_ID,
        i.EFFECTIVE_FROM,
        i.EFFECTIVE_UNTIL,
        i.EFFECTIVE_USAGE_MASK,
        i.COMPONENT_SEQUENCE_ID,
        i.QUOTEABLE_FLAG,
        i.PRIMARY_UOM_CODE,
        i.PERSISTENT_NODE_ID,
        i.BOM_SORT_ORDER,
        i.COMPONENT_SEQUENCE_PATH,
        i.IB_TRACKABLE);

        PACK;

        Copy_PS_PROP_VAL(i.ps_node_id,new_child);

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
             NULL;
        END;
END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_FUNC_COMP_SPEC
(withRules     IN  VARCHAR2) IS  -- DEFAULT '1'

new_id                INTEGER;
new_component_id      INTEGER;
new_rule_folder_id    INTEGER;
new_model_ref_expl_id INTEGER;

BEGIN

FOR i IN (SELECT  *  FROM CZ_FUNC_COMP_SPECS
          WHERE DEVL_PROJECT_ID=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   BEGIN
   get_Next_Val(new_id,'CZ_FUNC_COMP_SPECS_S');

   IF i.component_id IS NOT NULL THEN
      BEGIN
      new_component_id:=FlowId_PS_NODE(i.component_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           new_component_id:=i.component_id;
      END;

   ELSE
      new_component_id:=NULL;
   END IF;

   IF  withRules=YES_FLAG THEN
       IF i.rule_folder_id IS NOT NULL THEN
          new_rule_folder_id:=FlowId_RULE_FOLDER(i.rule_folder_id);
       ELSE
          new_rule_folder_id:=NULL;
       END IF;
    ELSE
       new_rule_folder_id:=i.rule_folder_id;
   END IF;

   IF i.model_ref_expl_id IS NOT NULL THEN
      BEGIN
      new_model_ref_expl_id:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           new_model_ref_expl_id:=i.model_ref_expl_id;
      END;
   ELSE
      new_model_ref_expl_id:=NULL;
   END IF;

   INSERT INTO CZ_FUNC_COMP_SPECS(
          FUNC_COMP_ID,
          COMPANION_TYPE,
          DEVL_PROJECT_ID,
          COMPONENT_ID,
          NAME,
          DESC_TEXT,
          PROGRAM_STRING,
          IMPLEMENTATION_TYPE,
          RULE_FOLDER_ID,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          MODEL_REF_EXPL_ID)
   VALUES(
                                 new_id,
          i.COMPANION_TYPE,
                                 NEW_PROJECT_ID,
                                 new_component_id,
          i.NAME,
          i.DESC_TEXT,
          i.PROGRAM_STRING,
          i.IMPLEMENTATION_TYPE,
                                 new_rule_folder_id,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
                                new_model_ref_expl_id);

    PACK;

    FlowId_FUNC_COMP_SPEC(i.func_comp_id):=new_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS THEN
         NULL;
    END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_POPULATOR IS

new_id        INTEGER;
new_node_id   INTEGER;
new_filter_id INTEGER;
currSeqVal    INTEGER;
k             INTEGER;

BEGIN

get_Next_Val(new_id,'CZ_POPULATORS_S');

FOR i IN (SELECT * FROM CZ_POPULATORS a WHERE deleted_flag=NO_FLAG
          AND EXISTS(SELECT NULL FROM CZ_PS_NODES WHERE devl_project_id=OLD_PROJECT_ID
          AND ps_node_id=a.owned_by_node_id AND deleted_flag=NO_FLAG))
LOOP
    BEGIN
       SELECT CZ_POPULATORS_S.NEXTVAL INTO new_id FROM dual;

       new_node_id:=FlowId_PS_NODE(i.owned_by_node_id);
       new_filter_id:=FlowId_FILTER_SET(i.filter_set_id);

       INSERT INTO CZ_POPULATORS(
                POPULATOR_ID,
                OWNED_BY_NODE_ID,
                FILTER_SET_ID,
                RESULT_TYPE,
                DELETED_FLAG,
                SECURITY_MASK,
                CHECKOUT_USER,
                PERSISTENT_POPULATOR_ID,
                FEATURE_TYPE,
                VIEW_NAME,
                HAS_ITEM,
                HAS_ITEM_TYPE,
                HAS_PROPERTY,
                HAS_DESCRIPTION,
                HAS_LEVEL,
                QUERY_SYNTAX,
                NAME,
                DESCRIPTION)
       VALUES(
                            new_id,
                            new_node_id,
                            new_filter_id,
                i.RESULT_TYPE,
                i.DELETED_FLAG,
                i.SECURITY_MASK,
                i.CHECKOUT_USER,
                i.PERSISTENT_POPULATOR_ID,
                i.FEATURE_TYPE,
                i.VIEW_NAME,
                i.HAS_ITEM,
                i.HAS_ITEM_TYPE,
                i.HAS_PROPERTY,
                i.HAS_DESCRIPTION,
                i.HAS_LEVEL,
                i.QUERY_SYNTAX,
                i.NAME,
                i.DESCRIPTION);

       PACK;

       FlowId_POPULATOR(i.populator_id):=new_id;
       get_Next_Val(new_id,'CZ_POPULATORS_S');

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

IF FlowId_POPULATOR.Count>0 THEN
   k:=FlowId_POPULATOR.First;
   LOOP
      IF k IS NULL THEN
         EXIT;
      END IF;
      UPDATE CZ_PS_NODES SET from_populator_id=FlowId_POPULATOR(k)
      WHERE from_populator_id=k AND devl_project_id=NEW_PROJECT_ID;
      k:=FlowId_POPULATOR.NEXT(k);
   END LOOP;
END IF;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_EXPRESSION_NODE
(forRules_Subschema    IN  BOOLEAN,p_rule_id IN VARCHAR2 DEFAULT NULL) IS -- DEFAULT FALSE

new_id                INTEGER;
new_parent            INTEGER;
new_child             INTEGER;
exp_id                INTEGER;
new_express_id        INTEGER;
new_filter_id         INTEGER;
new_ps_node_id        INTEGER;
new_model_ref_expl_id INTEGER;
ind                   INTEGER;
k                     INTEGER;

BEGIN

ind:=FlowId_EXPRESSION.First;
LOOP
   BEGIN
   FOR i IN (SELECT expr_node_id FROM CZ_EXPRESSION_NODES
             WHERE express_id=ind AND deleted_flag=NO_FLAG
             ORDER BY expr_node_id)
   LOOP
      get_Next_Val(new_id,'CZ_EXPRESSION_NODES_S');
      FlowId_EXPRESSION_NODE(i.expr_node_id):=new_id;
   END LOOP;

   FOR i IN (SELECT * FROM CZ_EXPRESSION_NODES
             WHERE express_id=ind AND deleted_flag=NO_FLAG
             ORDER BY expr_node_id)
   LOOP
          BEGIN
          IF i.expr_parent_id IS NOT NULL THEN
             new_parent:=FlowId_EXPRESSION_NODE(i.expr_parent_id);
          ELSE
             new_parent:=NULL;
          END IF;

          new_child:=FlowId_EXPRESSION_NODE(i.expr_node_id);
          new_express_id:=FlowId_EXPRESSION(i.express_id);

          IF forRules_Subschema THEN
             new_ps_node_id:=i.ps_node_id;
          ELSE
              IF i.ps_node_id IS NOT NULL THEN
                 BEGIN
                 new_ps_node_id:=FlowId_PS_NODE(i.ps_node_id);
                 EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      new_ps_node_id:=i.ps_node_id;
                 END;
              ELSE
                 new_ps_node_id:=NULL;
              END IF;
          END IF;

          IF i.filter_set_id IS NOT NULL THEN
             new_filter_id:=FlowId_FILTER_SET(i.filter_set_id);
          ELSE
            new_filter_id:=NULL;
          END IF;

          IF i.model_ref_expl_id IS NOT NULL THEN
             BEGIN
             new_model_ref_expl_id:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);
             EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  new_model_ref_expl_id:=i.model_ref_expl_id;
             END;
          ELSE
             new_model_ref_expl_id:=NULL;
          END IF;

          new_child:=FlowId_EXPRESSION_NODE(i.expr_node_id);
          INSERT  INTO CZ_EXPRESSION_NODES(
                  EXPR_NODE_ID,
                  EXPRESS_ID,
                  SEQ_NBR,
                  ITEM_TYPE_ID,
                  PS_NODE_ID,
                  ITEM_ID,
                  FILTER_SET_ID,
                  GRID_COL_ID,
                  EXPR_PARENT_ID,
                  PROPERTY_ID,
                  COMPILE_ADVICE,
                  COL,
                  DATA_VALUE,
                  DATA_NUM_VALUE, -- sselahi
                  FIELD_NAME,
                  EXPR_TYPE,
                  EXPR_SUBTYPE,
                  TOKEN_LIST_SEQ,
                  DELETED_FLAG,
                  SECURITY_MASK,
                  CHECKOUT_USER,
                  CONSEQUENT_FLAG,
                  MODEL_REF_EXPL_ID,
                  RULE_ID,
                  TEMPLATE_ID,
                  ARGUMENT_SIGNATURE_ID,
                  ARGUMENT_INDEX,
                  PARAM_SIGNATURE_ID,
                  PARAM_INDEX,
                  ARGUMENT_NAME,
                  DATA_TYPE,
                  DISPLAY_NODE_DEPTH,
                  COLLECTION_FLAG,
                  SOURCE_OFFSET,
                  SOURCE_LENGTH,
                  RELATIVE_NODE_PATH,
                  MUTABLE_FLAG,
                  EVENT_EXECUTION_SCOPE)
                  VALUES(
                                     new_child,
                                     new_express_id,
                  i.SEQ_NBR,
                  i.ITEM_TYPE_ID,
                                     new_ps_node_id,
                  i.ITEM_ID,
                  i.FILTER_SET_ID,
                  i.GRID_COL_ID,
                                     new_parent,
                  i.PROPERTY_ID,
                  i.COMPILE_ADVICE,
                  i.COL,
                  i.DATA_VALUE,
                  i.DATA_NUM_VALUE, -- sselahi
                  i.FIELD_NAME,
                  i.EXPR_TYPE,
                  i.EXPR_SUBTYPE,
                  i.TOKEN_LIST_SEQ,
                  i.DELETED_FLAG,
                  i.SECURITY_MASK,
                  i.CHECKOUT_USER,
                  i.CONSEQUENT_FLAG,
                                    new_model_ref_expl_id,
                  p_rule_id,
                  i.TEMPLATE_ID,
                  i.ARGUMENT_SIGNATURE_ID,
                  i.ARGUMENT_INDEX,
                  i.PARAM_SIGNATURE_ID,
                  i.PARAM_INDEX,
                  i.ARGUMENT_NAME,
                  i.DATA_TYPE,
                  i.DISPLAY_NODE_DEPTH,
                  i.COLLECTION_FLAG,
                  i.SOURCE_OFFSET,
                  i.SOURCE_LENGTH,
                  i.RELATIVE_NODE_PATH,
                  i.MUTABLE_FLAG,
                  i.EVENT_EXECUTION_SCOPE);

     PACK;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          NULL;
     WHEN OTHERS THEN
        NULL;
     END;

   END LOOP;

   ind:=FlowId_EXPRESSION.NEXT(ind);
   IF ind IS NULL THEN
       EXIT;
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_GRID_DEF IS

new_id      INTEGER;

BEGIN

FOR i IN (SELECT  *  FROM CZ_GRID_DEFS
          WHERE devl_project_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP

      get_Next_Val(new_id,'CZ_GRID_DEFS_S');

      INSERT INTO CZ_GRID_DEFS(
             GRID_ID,
             DEVL_PROJECT_ID,
             NAME,
             DESC_TEXT,
             DELETED_FLAG,
             SECURITY_MASK,
             CHECKOUT_USER)
      VALUES(
                         new_id,
                         NEW_PROJECT_ID,
             i.NAME,
             i.DESC_TEXT,
             i.DELETED_FLAG,
             i.SECURITY_MASK,
             i.CHECKOUT_USER);

     PACK;

     FlowId_GRID_DEF(i.grid_id):=new_id;
END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_GRID_COL IS

new_id        INTEGER;
new_parent    INTEGER;
new_child     INTEGER;
new_grid_id   INTEGER;
ind           INTEGER;

BEGIN

ind:=FlowId_GRID_DEF.First;
LOOP
   BEGIN
   FOR i IN (SELECT grid_col_id FROM CZ_GRID_COLS
             WHERE grid_id=ind AND deleted_flag=NO_FLAG)
   LOOP
      get_Next_Val(new_id,'CZ_GRID_COLS_S');
      FlowId_GRID_COL(i.grid_col_id):=new_id;
   END LOOP;

   FOR i IN (SELECT grid_col_id,prev_grid_col_id,grid_id FROM CZ_GRID_COLS
             WHERE grid_id=ind AND deleted_flag=NO_FLAG
             START WITH prev_grid_col_id IS NULL
             CONNECT BY PRIOR grid_col_id=prev_grid_col_id)
   LOOP
      BEGIN
      IF i.prev_grid_col_id IS not NULL THEN
         new_parent:=FlowId_GRID_COL(i.prev_grid_col_id);
      ELSE
         new_parent:=NULL;
      END IF;

      new_child:=FlowId_GRID_COL(i.grid_col_id);

      new_grid_id:=FlowId_GRID_DEF(i.grid_id);

      INSERT  INTO CZ_GRID_COLS
              (GRID_ID,
              GRID_COL_ID,
              PREV_GRID_COL_ID,
              DATA_TYPE,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER)
      SELECT
                          new_grid_id,
                          new_child,
                          new_parent,
              DATA_TYPE,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER
     FROM CZ_GRID_COLS
     WHERE grid_col_id=i.grid_col_id;

     PACK;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
          NULL;
     WHEN OTHERS THEN
          NULL;
     END;

  END LOOP;

  ind:=FlowId_GRID_DEF.NEXT(ind);
  IF ind IS NULL THEN
      EXIT;
  END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_GRID_CELL
(fromRules IN BOOLEAN) IS -- DEFAULT FALSE

new_id            INTEGER;
new_parent        INTEGER;
new_child         INTEGER;
new_grid_col_id   INTEGER;
new_ps_node_id    INTEGER;
ind               INTEGER;

BEGIN

ind:=FlowId_GRID_COL.First;

LOOP
   BEGIN
   FOR i IN (SELECT grid_cell_id FROM CZ_GRID_CELLS
             WHERE grid_col_id=ind AND deleted_flag=NO_FLAG ORDER BY grid_cell_id)
   LOOP
      get_Next_Val(new_id,'CZ_GRID_CELLS_S');
      FlowId_GRID_CELL(i.grid_cell_id):=new_id;
   END LOOP;

   FOR i IN (SELECT grid_cell_id,prev_grid_cell_id,grid_col_id,ps_node_id
             FROM CZ_GRID_CELLS WHERE grid_col_id=ind AND deleted_flag=NO_FLAG ORDER BY grid_cell_id)
   LOOP
      BEGIN
      IF i.prev_grid_cell_id IS NOT NULL THEN
         new_parent:=FlowId_GRID_CELL(i.prev_grid_cell_id);
      ELSE
         new_parent:=NULL;
      END IF;

      new_child:=FlowId_GRID_CELL(i.grid_cell_id);

      new_grid_col_id:=FlowId_GRID_COL(i.grid_col_id);

      IF i.ps_node_id IS NOT NULL THEN
         IF fromRules THEN
            new_ps_node_id:=i.ps_node_id;
         ELSE
            BEGIN
            new_ps_node_id:=FlowId_PS_NODE(i.ps_node_id);
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 new_ps_node_id:=i.ps_node_id;
            END;
         END IF;
      ELSE
         new_ps_node_id:=NULL;
      END IF;

      INSERT  INTO CZ_GRID_CELLS(
              GRID_COL_ID,
              GRID_CELL_ID,
              STR_VALUE,
              PREV_GRID_CELL_ID,
              PS_NODE_ID,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER)
      SELECT
                            new_grid_col_id,
                            new_child,
              STR_VALUE,
                            new_parent,
                            new_ps_node_id,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER
      FROM CZ_GRID_CELLS
      WHERE grid_cell_id=i.grid_cell_id;

      PACK;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
      WHEN OTHERS THEN
           NULL;
      END;

   END LOOP;

   ind:=FlowId_GRID_COL.NEXT(ind);
   IF ind IS NULL THEN
      EXIT;
   END IF;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_UI IS

new_id                INTEGER;
new_ps_id             INTEGER;
new_parent            INTEGER;
new_child             INTEGER;
new_intl_text_id      INTEGER;
new_func_comp_id      INTEGER;
new_ps_node_id        INTEGER;
new_container_id      INTEGER;
new_tool_tip_id       INTEGER;
new_caption_id        INTEGER;
new_comp_id           INTEGER;
new_ui_def_id         INTEGER;
new_ui_node_ref_id    INTEGER;
new_ui_node_id        INTEGER;
new_component_id      INTEGER;
ind                   INTEGER;
var_temp              INTEGER;
new_model_ref_expl_id INTEGER;
new_lce_identifier    CZ_UI_NODES.lce_identifier%TYPE;

BEGIN

FOR k IN (SELECT * FROM CZ_UI_DEFS
          WHERE devl_project_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
    BEGIN
    get_Next_Val(new_ui_def_id,'CZ_UI_DEFS_S');
    IF k.component_id IS NOT NULL THEN
       new_comp_id:=FlowId_PS_NODE(k.component_id);
    ELSE
       new_comp_id:=NULL;
    END IF;

    INSERT INTO CZ_UI_DEFS
           (UI_DEF_ID,
            DESC_TEXT,
            NAME,
            DEVL_PROJECT_ID,
            COMPONENT_ID,
            TREE_SEQ,
            DELETED_FLAG,
            EFF_FROM,
            EFF_TO,
            SECURITY_MASK,
            EFF_MASK,
            CHECKOUT_USER,
            UI_STYLE,
            GEN_VERSION,
            TREENODE_DISPLAY_SOURCE,
            GEN_HEADER,
            LOOK_AND_FEEL,
            CONTROLS_PER_SCREEN,
            PERSISTENT_UI_DEF_ID,
            MODEL_TIMESTAMP,
            UI_STATUS,
            FROM_MASTER_TEMPLATE_ID,
            PAGE_SET_ID,
            START_PAGE_ID,
            ERR_RUN_ID)

    VALUES(
                         new_ui_def_id,
            k.DESC_TEXT,
            k.NAME,
                         NEW_PROJECT_ID,
                         new_comp_id,
            k.TREE_SEQ+1,
            k.DELETED_FLAG,
            k.EFF_FROM,
            k.EFF_TO,
            k.SECURITY_MASK,
            k.EFF_MASK,
            k.CHECKOUT_USER,
            k.UI_STYLE,
            k.GEN_VERSION,
            k.TREENODE_DISPLAY_SOURCE,
            k.GEN_HEADER,
            k.LOOK_AND_FEEL,
            k.CONTROLS_PER_SCREEN,
            k.PERSISTENT_UI_DEF_ID,
            k.MODEL_TIMESTAMP,
            k.UI_STATUS,
            k.FROM_MASTER_TEMPLATE_ID,
            k.PAGE_SET_ID,
            k.START_PAGE_ID,
            k.ERR_RUN_ID);

    PACK;

    INSERT INTO CZ_UI_PROPERTIES
          (KEY_STR,
           UI_DEF_ID,
           VALUE_STR,
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER)
    SELECT
           KEY_STR,
                    new_ui_def_id,
           VALUE_STR,
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER
   FROM CZ_UI_PROPERTIES
   WHERE ui_def_id=k.ui_def_id;

   PACK;

   FOR i IN (SELECT ui_node_id FROM CZ_UI_NODES WHERE
             ui_def_id=k.ui_def_id AND deleted_flag=NO_FLAG)
   LOOP
      get_Next_Val(new_id,'CZ_UI_NODES_S');
      FlowId_UI_NODE(i.ui_node_id):=new_id;
   END LOOP;

   FOR i IN (SELECT * FROM CZ_UI_NODES
             WHERE ui_def_id=k.ui_def_id AND deleted_flag=NO_FLAG)
   LOOP
      BEGIN
      new_parent:=FlowId_UI_NODE(i.parent_id);
      new_child:=FlowId_UI_NODE(i.ui_node_id);

      get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
      Copy_INTL_TEXT(i.caption_id,new_intl_text_id,NEW_PROJECT_ID,new_ui_def_id);

      /* *** tool tips are not used anymore ***
       *get_Next_Val(new_tool_tip_id,'CZ_INTL_TEXTS_S');
       *get_Next_Val(new_tool_tip_id,'CZ_INTL_TEXTS_S');
       *Copy_INTL_TEXT(i.tool_tip_id,new_tool_tip_id);
      */

      IF i.ps_node_id IS NOT NULL THEN
         BEGIN
         new_ps_node_id:=FlowId_PS_NODE(i.ps_node_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              new_ps_node_id:=i.ps_node_id;
         END;
      ELSE
         new_ps_node_id:=NULL;
      END IF;

      IF i.component_id IS NOT NULL THEN
         BEGIN
         new_component_id:=FlowId_PS_NODE(i.component_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              new_component_id:=i.component_id;
         END;
      ELSE
          new_component_id:=NULL;
      END IF;

      IF i.container_id IS NOT NULL THEN
         BEGIN
         new_container_id:=FlowId_PS_NODE(i.container_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              new_container_id:=i.container_id;
         END;
      ELSE
         new_container_id:=NULL;
      END IF;

      IF i.func_comp_id IS NOT NULL THEN
         BEGIN
         new_func_comp_id:=FlowId_FUNC_COMP_SPEC(i.func_comp_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              new_func_comp_id:=i.func_comp_id;
         END;
      ELSE
         new_func_comp_id:=NULL;
      END IF;

      IF i.ui_node_ref_id IS NOT NULL THEN
         BEGIN
         new_ui_node_ref_id:=FlowId_UI_NODE(i.ui_node_ref_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              new_ui_node_ref_id:=i.ui_node_ref_id;
         END;
      ELSE
         new_ui_node_ref_id:=NULL;
      END IF;

      IF i.lce_identifier IS NOT NULL THEN

         var_temp:=TO_NUMBER(SUBSTR(i.lce_identifier,3));

         IF FlowId_PS_NODE.EXISTS(var_temp) THEN
            new_lce_identifier:='P_'||TO_CHAR(FlowId_PS_NODE(var_temp));
         ELSE
            new_lce_identifier:='P_'||TO_CHAR(var_temp);
         END IF;
      ELSE
         new_lce_identifier:=NULL;
      END IF;

      IF i.model_ref_expl_id  IS NOT NULL THEN
         BEGIN
         new_model_ref_expl_id:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              new_model_ref_expl_id:=i.model_ref_expl_id;
         END;
      ELSE
         new_model_ref_expl_id:=NULL;
      END IF;

      INSERT INTO CZ_UI_NODES(
          UI_NODE_ID,
          UI_DEF_ID,
          FUNC_COMP_ID,
          REL_TOP_POS,
          WIDTH,
          HEIGHT,
          PARENT_ID,
          REL_LEFT_POS,
          COMPONENT_ID,
          CONTAINER_ID,
          CAPTION_ID,
          UI_NODE_TYPE,
          PS_NODE_ID,
          NAME,
          UI_NODE_REF_ID,
          BACKGROUND_COLOR,
          LCE_IDENTIFIER,
          DESC_TEXT,
          TREE_SEQ,
          TREE_DISPLAY_FLAG,
          MODIFIED_FLAGS,
          TAB_ORDER,
          DEFAULT_FONT_FLAG,
          TOOL_TIP_ID,
          DEFAULT_BKGRND_COLOR_FLAG,
          DEFAULT_BKGRND_PICTURE_FLAG,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          MODEL_REF_EXPL_ID,
          FONTBOLD,
          FONTCOLOR,
          FONTITALIC,
          FONTUNDERLINE,
          FONTSIZE,
          FONTNAME,
          BACKGROUNDSTYLE,
          CONTROLTYPE,
          BACKGROUNDPICTURE,
          BORDERS,
          PICTURENAME,
          UI_DEF_REF_ID,
          OPTION_SORT_METHOD,
          OPTION_SORT_PROPERTY,
          OPTION_SORT_ORDER,
          OPTION_SORT_SELECT_FIRST,
          PAGE_NUMBER,
          PROPERTY_ID,
          PERSISTENT_UI_NODE_ID)
        VALUES(
                         new_child,
                         new_ui_def_id,
                         new_func_comp_id,
         i.REL_TOP_POS,
         i.WIDTH,
         i.HEIGHT,
                         new_parent,
         i.REL_LEFT_POS,
                         new_component_id,
                         new_container_id,
                         new_intl_text_id,
          i.UI_NODE_TYPE,
                         new_ps_node_id,
          i.NAME,
                         new_ui_node_ref_id,
          i.BACKGROUND_COLOR,
                        new_lce_identifier,
          i.DESC_TEXT,
          i.TREE_SEQ,
          i.TREE_DISPLAY_FLAG,
          i.MODIFIED_FLAGS,
          i.TAB_ORDER,
          i.DEFAULT_FONT_FLAG,
                          new_tool_tip_id,
          i.DEFAULT_BKGRND_COLOR_FLAG,
          i.DEFAULT_BKGRND_PICTURE_FLAG,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
                         new_model_ref_expl_id,
          i.FONTBOLD,
          i.FONTCOLOR,
          i.FONTITALIC,
          i.FONTUNDERLINE,
          i.FONTSIZE,
          i.FONTNAME,
          i.BACKGROUNDSTYLE,
          i.CONTROLTYPE,
          i.BACKGROUNDPICTURE,
          i.BORDERS,
          i.PICTURENAME,
          i.ui_def_ref_id,
          i.OPTION_SORT_METHOD,
          i.OPTION_SORT_PROPERTY,
          i.OPTION_SORT_ORDER,
          i.OPTION_SORT_SELECT_FIRST,
          i.PAGE_NUMBER,
          i.PROPERTY_ID,
          i.PERSISTENT_UI_NODE_ID);


         INSERT INTO CZ_UI_NODE_PROPS
                 (UI_NODE_ID,
                  UI_DEF_ID,
                  KEY_STR,
                  VALUE_STR,
                  DELETED_FLAG,
                  SECURITY_MASK,
                  CHECKOUT_USER,
                  CONTAINER_ID)
          SELECT
                         new_child,
                         new_ui_def_id,
                  KEY_STR,
                  VALUE_STR,
                  DELETED_FLAG,
                  SECURITY_MASK,
                  CHECKOUT_USER,
                  CONTAINER_ID
         FROM CZ_UI_NODE_PROPS
         WHERE ui_node_id=i.ui_node_id AND ui_def_id=k.ui_def_id AND deleted_flag=NO_FLAG;

         PACK;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              LOG_REPORT('CZ_PS_COPY.copy_UI','UI node='||to_char(i.ui_node_id)||' is corrupted.');
         END;
    END LOOP;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

--EXCEPTION
--WHEN NO_DATA_FOUND THEN
--     NULL;
--WHEN OTHERS THEN
--     NULL;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_RULE_FOLDERS IS

new_id            INTEGER;
new_parent        INTEGER;
new_child         INTEGER;

BEGIN

FOR i IN (SELECT rule_folder_id FROM CZ_RULE_FOLDERS
          WHERE devl_project_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   get_Next_Val(new_id,'CZ_RULE_FOLDERS_S');
   FlowId_RULE_FOLDER(i.rule_folder_id):=new_id;
END LOOP;

FOR i IN (SELECT * FROM CZ_RULE_FOLDERS
          WHERE devl_project_id=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   BEGIN
   IF i.parent_rule_folder_id IS NOT NULL THEN
      new_parent:=FlowId_RULE_FOLDER(i.parent_rule_folder_id);
   ELSE
      new_parent:=NULL;
   END IF;
   new_child:=FlowId_RULE_FOLDER(i.rule_folder_id);

   INSERT  INTO CZ_RULE_FOLDERS
          (RULE_FOLDER_ID,
           NAME,
           DESC_TEXT,
           PARENT_RULE_FOLDER_ID,
           DEVL_PROJECT_ID,
           TREE_SEQ,
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER,
           FOLDER_TYPE,
           EFFECTIVE_USAGE_MASK,
           EFFECTIVE_FROM,
           EFFECTIVE_UNTIL,
           EFFECTIVITY_SET_ID,
           PERSISTENT_RULE_FOLDER_ID,
           OBJECT_TYPE,
           DISABLED_FLAG,
           ORIG_SYS_REF)
   VALUES(
                        new_child,
           i.NAME,
           i.DESC_TEXT,
                        new_parent,
                        NEW_PROJECT_ID,
           i.TREE_SEQ,
           i.DELETED_FLAG,
           i.SECURITY_MASK,
           i.CHECKOUT_USER,
           i.FOLDER_TYPE,
           i.EFFECTIVE_USAGE_MASK,
           i.EFFECTIVE_FROM,
           i.EFFECTIVE_UNTIL,
           i.EFFECTIVITY_SET_ID,
           i.PERSISTENT_RULE_FOLDER_ID,
           i.OBJECT_TYPE,
           i.DISABLED_FLAG,
           i.ORIG_SYS_REF);

   PACK;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_RULE IS

new_id             INTEGER;
new_reason_id      INTEGER;
new_amount_id      INTEGER;
new_antecedent_id  INTEGER;
new_consequent_id  INTEGER;
new_component_id   INTEGER;
new_sub_cons_id    INTEGER;
new_grid_id        INTEGER;
new_rule_folder_id INTEGER;
new_intl_text_id   INTEGER;
new_msg_id         INTEGER;

BEGIN

FOR i IN (SELECT  *  FROM CZ_RULES
          WHERE DEVL_PROJECT_ID=OLD_PROJECT_ID AND deleted_flag=NO_FLAG)
LOOP
   BEGIN
   get_Next_Val(new_id,'CZ_RULES_S');
   FlowId_RULE(i.rule_id):=new_id;

   IF i.reason_id IS NOT NULL THEN
      get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
      new_reason_id:=new_intl_text_id;
      Copy_INTL_TEXT(i.reason_id,new_reason_id,NEW_PROJECT_ID,NULL);
   ELSE
      new_reason_id:=NULL;
   END IF;

   IF i.unsatisfied_msg_id IS NOT NULL THEN
      get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
      new_msg_id:=new_intl_text_id;
      Copy_INTL_TEXT(i.unsatisfied_msg_id,new_msg_id,NEW_PROJECT_ID,NULL);
   ELSE
      new_msg_id:=i.unsatisfied_msg_id;
   END IF;

   IF i.amount_id IS NOT NULL THEN
      new_amount_id:=FlowId_EXPRESSION(i.amount_id);
   ELSE
      new_amount_id:=NULL;
   END IF;

   IF i.antecedent_id IS NOT NULL THEN
      new_antecedent_id:=FlowId_EXPRESSION(i.antecedent_id);
   ELSE
      new_antecedent_id:=NULL;
   END IF;

   IF i.consequent_id IS NOT NULL THEN
      new_consequent_id:=FlowId_EXPRESSION(i.consequent_id);
   ELSE
      new_consequent_id:=NULL;
   END IF;

   IF i.component_id IS NOT NULL THEN
      new_component_id:=FlowId_PS_NODE(i.component_id);
   ELSE
      new_component_id:=NULL;
   END IF;

   IF i.sub_cons_id IS NOT NULL THEN
      new_sub_cons_id:=FlowId_SUB_CON_SET(i.sub_cons_id);
   ELSE
      new_sub_cons_id:=NULL;
   END IF;

   IF i.grid_id IS NOT NULL THEN
      new_grid_id:=FlowId_GRID_DEF(i.grid_id);
   ELSE
      new_grid_id:=NULL;
   END IF;

   IF i.rule_folder_id IS NULL OR i.rule_folder_id=NULL_ THEN
      new_rule_folder_id:=i.rule_folder_id;
   ELSE
      new_rule_folder_id:=FlowId_RULE_FOLDER(i.rule_folder_id);
   END IF;

   INSERT INTO CZ_RULES(
          RULE_ID,
          SUB_CONS_ID,
          REASON_ID,
          AMOUNT_ID,
          GRID_ID,
          RULE_FOLDER_ID,
          DEVL_PROJECT_ID,
          INVALID_FLAG,
          DESC_TEXT,
          NAME,
          ANTECEDENT_ID,
          CONSEQUENT_ID,
          RULE_TYPE,
          EXPR_RULE_TYPE,
          COMPONENT_ID,
          REASON_TYPE,
          DISABLED_FLAG,
          ORIG_SYS_REF,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          EFFECTIVITY_SET_ID,
          EFFECTIVE_FROM,
          EFFECTIVE_UNTIL,
          EFFECTIVE_USAGE_MASK,
          PERSISTENT_RULE_ID,
          SEQ_NBR,
          RULE_FOLDER_TYPE,
          UNSATISFIED_MSG_ID,
          UNSATISFIED_MSG_SOURCE,
          SEEDED_FLAG)
    VALUES(                   new_id,
                              new_sub_cons_id,
                              new_reason_id,
                              new_amount_id,
                              new_grid_id,
                              new_rule_folder_id,
                              NEW_PROJECT_ID,
          i.INVALID_FLAG,
          i.DESC_TEXT,
                              i.NAME,
                              new_antecedent_id,
                              new_consequent_id,
          i.RULE_TYPE,
          i.EXPR_RULE_TYPE,
                              new_component_id,
          i.REASON_TYPE,
          i.DISABLED_FLAG,
          i.ORIG_SYS_REF,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
          i.EFFECTIVITY_SET_ID,
          i.EFFECTIVE_FROM,
          i.EFFECTIVE_UNTIL,
          i.EFFECTIVE_USAGE_MASK,
          i.PERSISTENT_RULE_ID,
          i.SEQ_NBR,
          i.RULE_FOLDER_TYPE,
                            new_msg_id,
          i.UNSATISFIED_MSG_SOURCE,
          i.SEEDED_FLAG);

   PACK;

   FlowId_RULE(i.rule_id):=new_id;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_COMBO_FEATURE IS

new_feature_id        INTEGER;
new_rule_id           INTEGER;
new_grid_col_id       INTEGER;
new_model_ref_expl_id INTEGER;

BEGIN

FOR i IN(SELECT  b.*  FROM CZ_RULES a,CZ_COMBO_FEATURES b
         WHERE a.devl_project_id=OLD_PROJECT_ID AND a.rule_id=b.rule_id
         AND a.deleted_flag=NO_FLAG AND b.deleted_flag=NO_FLAG)
LOOP
   BEGIN

   BEGIN
   new_feature_id:=FlowId_PS_NODE(i.feature_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_feature_id:=i.feature_id;
   END;

   new_rule_id:=FlowId_RULE(i.rule_id);

   IF i.grid_col_id IS NOT NULL THEN
      new_grid_col_id:=FlowId_GRID_COL(i.grid_col_id);
   ELSE
      new_grid_col_id:=NULL;
   END IF;

   IF i.model_ref_expl_id IS NOT NULL THEN
      BEGIN
      new_model_ref_expl_id:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           new_model_ref_expl_id:=i.model_ref_expl_id;
      END;
   ELSE
      new_model_ref_expl_id:=NULL;
   END IF;

   INSERT INTO CZ_COMBO_FEATURES
         (FEATURE_ID,
          GRID_COL_ID,
          RULE_ID,
          COL_TYPE,
          MINIMUM,
          MAXIMUM,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          MODEL_REF_EXPL_ID)
   VALUES(
                           new_feature_id,
                           new_grid_col_id,
                           new_rule_id,
          i.COL_TYPE,
          i.MINIMUM,
          i.MAXIMUM,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
                          new_model_ref_expl_id);

   PACK;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_CHART_Tables IS

new_primary_opt_id         INTEGER;
new_secondary_opt_id       INTEGER;
new_secondary_feature_id   INTEGER;
new_secondary_feat_expl_id INTEGER;
new_feature_id             INTEGER;
new_rule_id                INTEGER;
new_ref_id                 INTEGER;

BEGIN

FOR i IN (SELECT b.* FROM CZ_RULES a,CZ_DES_CHART_CELLS b
         WHERE a.devl_project_id=OLD_PROJECT_ID AND a.rule_id=b.rule_id
         AND a.deleted_flag=NO_FLAG AND b.deleted_flag=NO_FLAG)
LOOP
   BEGIN
   new_rule_id:=FlowId_RULE(i.rule_id);

   BEGIN
   new_primary_opt_id:=FlowId_PS_NODE(i.primary_opt_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_primary_opt_id:=i.primary_opt_id;
   END;
   BEGIN
   new_secondary_opt_id:=FlowId_PS_NODE(i.secondary_opt_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_secondary_opt_id:=i.secondary_opt_id;
   END;

   IF i.secondary_feature_id IS NOT NULL THEN
      BEGIN
      new_secondary_feature_id:=FlowId_PS_NODE(i.secondary_feature_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           new_secondary_feature_id:=i.secondary_feature_id;
      END;
      BEGIN
      new_secondary_feat_expl_id:=FlowId_MODEL_REF_EXPL(i.secondary_feat_expl_id);
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
           new_secondary_feat_expl_id:=i.secondary_feat_expl_id;
      END;

   ELSE
      new_secondary_feature_id:=NULL;
      new_secondary_feat_expl_id:=NULL;
   END IF;

   INSERT INTO CZ_DES_CHART_CELLS
      (RULE_ID,
       PRIMARY_OPT_ID,
       SECONDARY_OPT_ID,
       MARK_CHAR,
       SECONDARY_FEAT_EXPL_ID,
       SECONDARY_FEATURE_ID,
       DELETED_FLAG,
       SECURITY_MASK ,
       CHECKOUT_USER )
   VALUES(
                     new_rule_id,
                     new_primary_opt_id,
                     new_secondary_opt_id,
       i.MARK_CHAR,
                     new_secondary_feat_expl_id,
      	         new_secondary_feature_id,
       i.DELETED_FLAG,
       i.SECURITY_MASK,
       i.CHECKOUT_USER);

   PACK;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;

END LOOP;

FOR i IN (SELECT b.* FROM CZ_RULES a,CZ_DES_CHART_FEATURES b WHERE
          a.devl_project_id=OLD_PROJECT_ID AND a.rule_id=b.rule_id
          AND a.deleted_flag=NO_FLAG AND b.deleted_flag=NO_FLAG)
LOOP
   BEGIN
   new_rule_id:=FlowId_RULE(i.rule_id);

   BEGIN
       new_feature_id:=FlowId_PS_NODE(i.feature_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_feature_id:=i.feature_id;
   END;


   BEGIN
       new_ref_id:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_ref_id:=i.model_ref_expl_id;
   END;

   INSERT INTO CZ_DES_CHART_FEATURES
       (RULE_ID,
        FEATURE_ID,
        FEATURE_TYPE ,
        MODEL_REF_EXPL_ID,
        DELETED_FLAG,
        SECURITY_MASK,
        CHECKOUT_USER)
   VALUES(
                   new_rule_id,
                   new_feature_id,
        i.FEATURE_TYPE ,
                   new_ref_id,
        i.DELETED_FLAG,
        i.SECURITY_MASK,
        i.CHECKOUT_USER);

   PACK;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;
END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     LOG_REPORT('CZ_PS_COPY.Copy_CHART_Tables',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_PS_NODE_subtree
(p_project_id     IN     INTEGER,
 p_parent_id      IN     INTEGER,
 p_new_project_id IN     INTEGER,
 p_out_new_root   IN OUT NOCOPY INTEGER,
 p_new_parent_id  IN     INTEGER DEFAULT NULL) IS

new_parent       INTEGER;
new_child        INTEGER;
new_intl_text_id INTEGER;
var_ind          INTEGER;
ind              INTEGER;
new_id           INTEGER;
var_intl_text_id INTEGER;
var_parent_id    INTEGER;

BEGIN

/* Exception is raised for BUG No.4028599*/
RAISE_APPLICATION_ERROR(-20001, 'ERROR: CZ_PS_COPY is obsolete in 11.5.10 and later builds.');

SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

Initialize;

IF p_new_project_id IS NULL THEN
   NEW_PROJECT_ID:=p_project_id;
ELSE
   NEW_PROJECT_ID:=p_new_project_id;
END IF;

FOR i IN (SELECT * FROM CZ_PS_NODES
          WHERE devl_project_id=p_project_id AND deleted_flag=NO_FLAG
          START WITH parent_id=p_parent_id
          CONNECT BY PRIOR ps_node_id=parent_id)
LOOP
   get_Next_Val(new_id,'CZ_PS_NODES_S');
   FlowId_PS_NODE(i.ps_node_id):=new_id;

   IF i.parent_id=p_parent_id THEN
      p_out_new_root:=new_id;
   END IF;
END LOOP;

ind:=FlowId_PS_NODE.First;
LOOP
   FOR i IN (SELECT * FROM CZ_PS_NODES
             WHERE ps_node_id=ind AND deleted_flag=NO_FLAG)
   LOOP
      IF i.parent_id IS NOT NULL THEN
         new_parent:=FlowId_PS_NODE(i.parent_id);
      ELSE
         new_parent:=NULL;
         new_intl_text_id:=NULL;
      END IF;

      IF i.parent_id=p_parent_id THEN
         new_parent:=p_new_parent_id;
      END IF;

      new_child:=FlowId_PS_NODE(i.ps_node_id);

      IF i.intl_text_id IS NOT NULL THEN
         get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
         Copy_INTL_TEXT(i.intl_text_id,new_intl_text_id,NEW_PROJECT_ID,NULL);
      ELSE
         new_intl_text_id:=NULL;
      END IF;

      INSERT INTO CZ_PS_NODES
            (PS_NODE_ID,
             DEVL_PROJECT_ID,
             FROM_POPULATOR_ID,
             PROPERTY_BACKPTR,
             ITEM_TYPE_BACKPTR,
             INTL_TEXT_ID,
             SUB_CONS_ID,
             ITEM_ID,
             NAME,
             RESOURCE_FLAG,
             INITIAL_VALUE,
             initial_num_value, -- sselahi
             PARENT_ID,
             MINIMUM,
             MAXIMUM,
             PS_NODE_TYPE,
             FEATURE_TYPE,
             PRODUCT_FLAG,
             REFERENCE_ID,
             MULTI_CONFIG_FLAG,
             ORDER_SEQ_FLAG,
             SYSTEM_NODE_FLAG,
             TREE_SEQ,
             COUNTED_OPTIONS_FLAG,
             UI_OMIT,
             UI_SECTION,
             BOM_TREATMENT,
             ORIG_SYS_REF,
             BOM_REQUIRED_FLAG,
             SO_ITEM_TYPE_CODE,
             MINIMUM_SELECTED,
             MAXIMUM_SELECTED,
             DELETED_FLAG,
             SECURITY_MASK,
             CHECKOUT_USER,
             USER_NUM01,
             USER_NUM02,
             USER_NUM03,
             USER_NUM04,
             USER_STR01,
             USER_STR02,
             USER_STR03,
             USER_STR04,
             VIRTUAL_FLAG,
             VIOLATION_TEXT_ID,
             DECIMAL_QTY_FLAG,
             EFFECTIVITY_SET_ID,
             EFFECTIVE_FROM,
             EFFECTIVE_UNTIL,
             EFFECTIVE_USAGE_MASK,
             COMPONENT_SEQUENCE_ID,
             PERSISTENT_NODE_ID,
             QUOTEABLE_FLAG,
             PRIMARY_UOM_CODE,
             BOM_SORT_ORDER,
             COMPONENT_SEQUENCE_PATH,
             IB_TRACKABLE)
       VALUES(
                                   new_child,
                                   NEW_PROJECT_ID,
             i.FROM_POPULATOR_ID,
             i.PROPERTY_BACKPTR,
             i.ITEM_TYPE_BACKPTR,
                                   new_intl_text_id,
             i.SUB_CONS_ID,
             i.ITEM_ID,
             i.NAME,
             i.RESOURCE_FLAG,
             i.INITIAL_VALUE,
             i.initial_num_value, -- sselahi
                                   new_parent,
             i.MINIMUM,
             i.MAXIMUM,
             i.PS_NODE_TYPE,
             i.FEATURE_TYPE,
             i.PRODUCT_FLAG,
             i.REFERENCE_ID,
             i.MULTI_CONFIG_FLAG,
             i.ORDER_SEQ_FLAG,
             i.SYSTEM_NODE_FLAG,
             i.TREE_SEQ,
             i.COUNTED_OPTIONS_FLAG,
             i.UI_OMIT,
             i.UI_SECTION,
             i.BOM_TREATMENT,
             i.ORIG_SYS_REF,
             i.BOM_REQUIRED_FLAG,
             i.SO_ITEM_TYPE_CODE,
             i.MINIMUM_SELECTED,
             i.MAXIMUM_SELECTED,
             i.DELETED_FLAG,
             i.SECURITY_MASK,
             i.CHECKOUT_USER,
             i.USER_NUM01,
             i.USER_NUM02,
             i.USER_NUM03,
             i.USER_NUM04,
             i.USER_STR01,
             i.USER_STR02,
             i.USER_STR03,
             i.USER_STR04,
             i.VIRTUAL_FLAG,
             i.VIOLATION_TEXT_ID,
             i.DECIMAL_QTY_FLAG,
             i.EFFECTIVITY_SET_ID,
             i.EFFECTIVE_FROM,
             i.EFFECTIVE_UNTIL,
             i.EFFECTIVE_USAGE_MASK,
             i.COMPONENT_SEQUENCE_ID,
             i.PERSISTENT_NODE_ID,
             i.QUOTEABLE_FLAG,
             i.PRIMARY_UOM_CODE,
             i.BOM_SORT_ORDER,
             i.COMPONENT_SEQUENCE_PATH,
             i.IB_TRACKABLE);

       PACK;

   END LOOP;

   ind:=FlowId_PS_NODE.NEXT(ind);
   IF ind IS NULL THEN
      EXIT;
   END IF;

END LOOP;

Copy_MODEL_REF_EXPL;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_FUNC_COMP_SPEC_
(p_project_id          IN INTEGER,
 p_old_rule_folder_id  IN INTEGER,
 p_new_rule_folder_id  IN INTEGER ) IS

new_id             INTEGER;

BEGIN

Initialize;

FOR i IN (SELECT  *  FROM CZ_FUNC_COMP_SPECS
          WHERE DEVL_PROJECT_ID=p_project_id
          AND RULE_FOLDER_ID=p_old_rule_folder_id AND deleted_flag=NO_FLAG)
LOOP
   get_Next_Val(new_id,'CZ_FUNC_COMP_SPECS_S');

   INSERT INTO CZ_FUNC_COMP_SPECS
         (FUNC_COMP_ID,
          COMPANION_TYPE,
          DEVL_PROJECT_ID,
          COMPONENT_ID,
          NAME,
          DESC_TEXT,
          PROGRAM_STRING,
          IMPLEMENTATION_TYPE,
          RULE_FOLDER_ID,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          MODEL_REF_EXPL_ID)
   VALUES(
                             new_id,
          i.COMPANION_TYPE,
          i.DEVL_PROJECT_ID,
          i.COMPONENT_ID,
          i.NAME,
          i.DESC_TEXT,
          i.PROGRAM_STRING,
          i.IMPLEMENTATION_TYPE,
                             p_new_rule_folder_id,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
          i.MODEL_REF_EXPL_ID);

    PACK;

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     LOG_REPORT('CZ_PS_COPY.Copy_FUNC_COMP_SPEC_',SQLERRM);
WHEN OTHERS THEN
     LOG_REPORT('CZ_PS_COPY.Copy_FUNC_COMP_SPEC_',SQLERRM);
END;

PROCEDURE COPY_FUNC_COMPANION
(p_func_comp_id         IN      INTEGER,
 p_project_id           IN      INTEGER,
 p_new_rule_folder_id   IN      INTEGER  DEFAULT NULL,
 p_out_new_func_comp_id IN OUT NOCOPY  INTEGER ) IS

var_component_id   INTEGER;
new_rule_folder_id INTEGER;

BEGIN

/* Exception is raised for BUG No.4028599*/
RAISE_APPLICATION_ERROR(-20001, 'ERROR: CZ_PS_COPY is obsolete in 11.5.10 and later builds.');

SELECT CZ_FUNC_COMP_SPECS_S.NEXTVAL INTO p_out_new_func_comp_id FROM dual;

var_component_id:=NULL;
FOR i IN(SELECT component_id FROM CZ_FUNC_COMP_SPECS
         WHERE devl_project_id=p_project_id
         AND func_comp_id=p_func_comp_id AND deleted_flag=NO_FLAG)
LOOP
   var_component_id:=i.component_id;
END LOOP;

FOR i IN (SELECT * FROM CZ_FUNC_COMP_SPECS
          WHERE func_comp_id=p_func_comp_id
          AND devl_project_id=p_project_id AND deleted_flag=NO_FLAG)
LOOP

IF p_new_rule_folder_id IS NOT NULL AND p_new_rule_folder_id<>-1 THEN
   new_rule_folder_id:=p_new_rule_folder_id;
ELSE
   new_rule_folder_id:=i.rule_folder_id;
END IF;

INSERT INTO CZ_FUNC_COMP_SPECS(
              FUNC_COMP_ID,
              COMPANION_TYPE,
              DEVL_PROJECT_ID,
              COMPONENT_ID,
              NAME,
              DESC_TEXT,
              PROGRAM_STRING,
              IMPLEMENTATION_TYPE,
              RULE_FOLDER_ID,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER,
              MODEL_REF_EXPL_ID)
VALUES(
                               p_out_new_func_comp_id,
              i.COMPANION_TYPE,
                               p_project_id,
                               var_component_id,
              i.NAME||'-'||TO_CHAR(p_out_new_func_comp_id),
              i.DESC_TEXT,
              i.PROGRAM_STRING,
              i.IMPLEMENTATION_TYPE,
                               new_rule_folder_id,
              i.DELETED_FLAG,
              i.SECURITY_MASK,
              i.CHECKOUT_USER,
              i.MODEL_REF_EXPL_ID);

    PACK;

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     LOG_REPORT('CZ_PS_COPY.COPY_FUNC_COMPANION',SQLERRM);
WHEN OTHERS THEN
     LOG_REPORT('CZ_PS_COPY.COPY_FUNC_COMPANION',SQLERRM);
END;

PROCEDURE Copy_EXPRESSION_
(p_express_id IN INTEGER,
 p_rule_id    IN INTEGER,
 p_mode       IN VARCHAR2) IS

new_id      INTEGER;

BEGIN

FOR i IN (SELECT * FROM CZ_EXPRESSIONS
          WHERE EXPRESS_ID=p_express_id AND deleted_flag=NO_FLAG)
LOOP
   get_Next_Val(new_id,'CZ_EXPRESSIONS_S');

   INSERT INTO CZ_EXPRESSIONS(
           EXPRESS_ID,
           DEVL_PROJECT_ID,
           NAME,
           EXPR_STR,
           DESC_TEXT,
           PRESENT_TYPE,
           PARSED_FLAG,
           DELETED_FLAG,
           SECURITY_MASK,
           CHECKOUT_USER,
           PERSISTENT_EXPRESSION_ID)
   VALUES(
                        new_id,
           i.DEVL_PROJECT_ID,
           i.NAME,
           i.EXPR_STR,
           i.DESC_TEXT,
           i.PRESENT_TYPE,
           i.PARSED_FLAG,
           i.DELETED_FLAG,
           i.SECURITY_MASK,
           i.CHECKOUT_USER,
           i.PERSISTENT_EXPRESSION_ID);

   PACK;

   FlowId_EXPRESSION(i.express_id):=new_id;

   IF p_mode='ANTECEDENT_ID' THEN
      UPDATE CZ_RULES SET ANTECEDENT_ID=new_id WHERE rule_id=p_rule_id;
   END  IF;
   IF p_mode='CONSEQUENT_ID' THEN
      UPDATE CZ_RULES SET CONSEQUENT_ID=new_id WHERE rule_id=p_rule_id;
   END  IF;
   IF p_mode='AMOUNT_ID' THEN
      UPDATE CZ_RULES SET AMOUNT_ID=new_id WHERE rule_id=p_rule_id;
   END  IF;

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN OTHERS THEN
     NULL;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_CHART_Tables_
(p_old_rule_id  IN INTEGER,
 p_new_rule_id  IN INTEGER) IS

BEGIN

INSERT INTO CZ_DES_CHART_CELLS
      (RULE_ID,
       PRIMARY_OPT_ID,
       SECONDARY_OPT_ID,
       MARK_CHAR,
       SECONDARY_FEAT_EXPL_ID,
       SECONDARY_FEATURE_ID,
       DELETED_FLAG,
       SECURITY_MASK ,
       CHECKOUT_USER )
SELECT
                         p_new_rule_id,
       PRIMARY_OPT_ID,
       SECONDARY_OPT_ID,
       MARK_CHAR,
       SECONDARY_FEAT_EXPL_ID,
       SECONDARY_FEATURE_ID,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER
FROM CZ_DES_CHART_CELLS
WHERE rule_id=p_old_rule_id AND deleted_flag=NO_FLAG;

INSERT INTO CZ_DES_CHART_FEATURES
      (RULE_ID,
       FEATURE_ID,
       FEATURE_TYPE ,
       MODEL_REF_EXPL_ID,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER )
SELECT
                      p_new_rule_id,
       FEATURE_ID,
       FEATURE_TYPE ,
       MODEL_REF_EXPL_ID,
       DELETED_FLAG,
       SECURITY_MASK,
       CHECKOUT_USER
FROM CZ_DES_CHART_FEATURES
WHERE rule_id=p_old_rule_id AND deleted_flag=NO_FLAG;

PACK;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     LOG_REPORT('CZ_PS_COPY.Copy_CHART_Tables_',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_RULES_subschema
(p_rule_id             IN   INTEGER,
 p_out_new_rule_id     OUT NOCOPY  INTEGER,
 p_FUNC_COMP_Flag      IN   VARCHAR2 , -- DEFAULT '0',
 p_rule_folder_id      IN   INTEGER  DEFAULT NULL,
 p_Rules_Seq_Flag      IN   VARCHAR2   -- DEFAULT '0'
)IS

new_reason_id           INTEGER;
new_rule_id             INTEGER;
new_feature_id          INTEGER;
new_grid_id             INTEGER;
var_grid_id             INTEGER;
var_folder_id           INTEGER;
new_folder_id           INTEGER;
new_grid_col_id         INTEGER;

var_antecedent_id       INTEGER;
var_consequent_id       INTEGER;
var_amount_id           INTEGER;
new_intl_text_id        INTEGER;

new_msg_id              INTEGER;
new_RULE_FOLDER_ID      INTEGER;
new_EFFECTIVITY_SET_ID  INTEGER;
new_SEQ_NBR             INTEGER;
new_EFFECTIVE_FROM      DATE;
new_EFFECTIVE_UNTIL     DATE;

END_OPERATION           EXCEPTION;

BEGIN

/* Exception is raised for BUG No.4028599*/
RAISE_APPLICATION_ERROR(-20001, 'ERROR: CZ_PS_COPY is obsolete in 11.5.10 and later builds.');

SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;

p_out_new_rule_id:=0;

Initialize;

IF p_Rules_Seq_Flag='1' THEN
   SELECT devl_project_id INTO OLD_PROJECT_ID FROM CZ_RULE_FOLDERS
   WHERE rule_folder_id=p_rule_id AND deleted_flag=NO_FLAG;
   NEW_PROJECT_ID:=OLD_PROJECT_ID;
   copy_RULE_SEQ(p_rule_id,p_out_new_rule_id);
   RAISE END_OPERATION;
END IF;

IF p_FUNC_COMP_Flag='1' THEN
   SELECT devl_project_id INTO OLD_PROJECT_ID FROM CZ_FUNC_COMP_SPECS
   WHERE func_comp_id=p_rule_id AND deleted_flag=NO_FLAG;
   NEW_PROJECT_ID:=OLD_PROJECT_ID;
   COPY_FUNC_COMPANION(p_rule_id,OLD_PROJECT_ID,NULL,p_out_new_rule_id);
   RAISE END_OPERATION;
END IF;

BEGIN

SELECT grid_id,devl_project_id,rule_folder_id,
       antecedent_id,consequent_id,amount_id
INTO   var_grid_id,NEW_PROJECT_ID,var_folder_id,
       var_antecedent_id,var_consequent_id,var_amount_id
FROM CZ_RULES
WHERE rule_id=p_rule_id AND deleted_flag=NO_FLAG;

OLD_PROJECT_ID:=NEW_PROJECT_ID;

IF var_grid_id IS NOT NULL THEN
   FOR i IN (SELECT * FROM CZ_GRID_DEFS
             WHERE grid_id=var_grid_id AND deleted_flag=NO_FLAG)
   LOOP
       get_Next_Val(new_grid_id,'CZ_GRID_DEFS_S');
       INSERT INTO CZ_GRID_DEFS(
              GRID_ID,
              DEVL_PROJECT_ID,
              NAME,
              DESC_TEXT,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER)
       VALUES(               new_grid_id,
              i.DEVL_PROJECT_ID,
              i.NAME,
              i.DESC_TEXT,
              i.DELETED_FLAG,
              i.SECURITY_MASK,
              i.CHECKOUT_USER);

        PACK;

    END LOOP;
    FlowId_GRID_DEF(var_grid_id):=new_grid_id;
    Copy_GRID_COL;
    Copy_GRID_CELL(TRUE);
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     NULL;
WHEN OTHERS THEN
     NULL;
END;

get_Next_Val(new_rule_id,'CZ_RULES_S');

FOR i IN (SELECT * FROM CZ_RULES
          WHERE rule_id=p_rule_id AND deleted_flag=NO_FLAG)
LOOP

    get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
    new_reason_id:=new_intl_text_id;
    Copy_INTL_TEXT(i.reason_id,new_reason_id,NEW_PROJECT_ID,NULL);

    IF i.unsatisfied_msg_id IS NOT NULL THEN
       get_Next_Val(new_intl_text_id,'CZ_INTL_TEXTS_S');
       new_msg_id:=new_intl_text_id;
       Copy_INTL_TEXT(i.unsatisfied_msg_id,new_msg_id,NEW_PROJECT_ID,NULL);
    ELSE
       new_msg_id:=i.unsatisfied_msg_id;
    END IF;

    IF p_rule_folder_id IS NOT NULL AND p_rule_folder_id<>-1 THEN
       new_RULE_FOLDER_ID:=p_rule_folder_id;
       new_EFFECTIVITY_SET_ID:=NULL;
       new_EFFECTIVE_FROM:=CZ_UTILS.EPOCH_END_;
       new_EFFECTIVE_UNTIL:=CZ_UTILS.EPOCH_BEGIN_;
       SELECT NVL(MAX(SEQ_NBR),0)+1 INTO new_SEQ_NBR FROM CZ_RULES
       WHERE rule_folder_id=p_rule_folder_id AND deleted_flag=NO_FLAG;
    ELSE
       new_RULE_FOLDER_ID:=i.RULE_FOLDER_ID;
       new_EFFECTIVITY_SET_ID:=i.EFFECTIVITY_SET_ID;
       new_EFFECTIVE_FROM:=i.EFFECTIVE_FROM;
       new_EFFECTIVE_UNTIL:=i.EFFECTIVE_UNTIL;
       new_SEQ_NBR:=i.SEQ_NBR;
    END IF;

    INSERT INTO CZ_RULES(
              RULE_ID,
              SUB_CONS_ID,
              REASON_ID,
              AMOUNT_ID,
              GRID_ID,
              RULE_FOLDER_ID,
              DEVL_PROJECT_ID,
              INVALID_FLAG,
              DESC_TEXT,
              NAME,
              ANTECEDENT_ID,
              CONSEQUENT_ID,
              RULE_TYPE,
              EXPR_RULE_TYPE,
              COMPONENT_ID,
              REASON_TYPE,
              DISABLED_FLAG,
              ORIG_SYS_REF,
              DELETED_FLAG,
              SECURITY_MASK,
              CHECKOUT_USER,
              EFFECTIVITY_SET_ID,
              EFFECTIVE_FROM,
              EFFECTIVE_UNTIL,
              EFFECTIVE_USAGE_MASK,
              SEQ_NBR,
              RULE_FOLDER_TYPE,
              UNSATISFIED_MSG_ID,
              UNSATISFIED_MSG_SOURCE,
              SIGNATURE_ID,
              TEMPLATE_PRIMITIVE_FLAG,
              PRESENTATION_FLAG,
              TEMPLATE_TOKEN,
              RULE_TEXT,
              NOTES,
              CLASS_NAME,
              INSTANTIATION_SCOPE,
              MODEL_REF_EXPL_ID,
              MUTABLE_FLAG,
              SEEDED_FLAG)
      VALUES(
                              new_rule_id,
              i.SUB_CONS_ID,
                              new_reason_id,
              i.AMOUNT_ID,
                              new_grid_id,
                              new_RULE_FOLDER_ID,
              i.DEVL_PROJECT_ID,
              i.INVALID_FLAG,
              i.DESC_TEXT,
                             i.NAME||'-'||TO_CHAR(new_rule_id),
              i.ANTECEDENT_ID,
              i.CONSEQUENT_ID,
              i.RULE_TYPE,
              i.EXPR_RULE_TYPE,
              i.COMPONENT_ID,
              i.REASON_TYPE,
              i.DISABLED_FLAG,
              i.ORIG_SYS_REF,
              i.DELETED_FLAG,
              i.SECURITY_MASK,
              i.CHECKOUT_USER,
                            new_EFFECTIVITY_SET_ID,
                            new_EFFECTIVE_FROM,
                            new_EFFECTIVE_UNTIL,
              i.EFFECTIVE_USAGE_MASK,
                            new_SEQ_NBR,
              i.RULE_FOLDER_TYPE,
                            new_msg_id,
              i.UNSATISFIED_MSG_SOURCE,
              i.SIGNATURE_ID,
              i.TEMPLATE_PRIMITIVE_FLAG,
              i.PRESENTATION_FLAG,
              i.TEMPLATE_TOKEN,
              i.RULE_TEXT,
              i.NOTES,
              i.CLASS_NAME,
              i.INSTANTIATION_SCOPE,
              i.MODEL_REF_EXPL_ID,
              i.MUTABLE_FLAG,
              i.SEEDED_FLAG);

    PACK;

END LOOP;

FOR i IN (SELECT * FROM CZ_COMBO_FEATURES
          WHERE rule_id=p_rule_id AND deleted_flag=NO_FLAG)
LOOP
   IF i.grid_col_id IS NOT NULL THEN
      new_grid_col_id:=FlowId_GRID_COL(i.grid_col_id);
   ELSE
     new_grid_col_id:=NULL;
   END IF;
   INSERT INTO CZ_COMBO_FEATURES
         (FEATURE_ID,
          GRID_COL_ID,
          RULE_ID,
          COL_TYPE,
          MINIMUM,
          MAXIMUM,
          DELETED_FLAG,
          SECURITY_MASK,
          CHECKOUT_USER,
          MODEL_REF_EXPL_ID)
   VALUES(i.FEATURE_ID,
                    new_grid_col_id,
                    new_rule_id,
          i.COL_TYPE,
          i.MINIMUM,
          i.MAXIMUM,
          i.DELETED_FLAG,
          i.SECURITY_MASK,
          i.CHECKOUT_USER,
          i.MODEL_REF_EXPL_ID);

   PACK;

END LOOP;

Copy_CHART_Tables_(p_rule_id,new_rule_id);

IF p_FUNC_COMP_Flag=YES_FLAG AND NOT(var_folder_id=NULL_ OR var_folder_id IS NULL) THEN
   Copy_RULE_FOLDERS;
   IF FlowId_RULE_FOLDER.Count>0 THEN
      new_folder_id:=FlowId_RULE_FOLDER(var_folder_id);
   END IF;
   Copy_FUNC_COMP_SPEC_(NEW_PROJECT_ID,var_folder_id,new_folder_id);
END IF;

IF  var_antecedent_id IS NOT NULL THEN
    Copy_EXPRESSION_(var_antecedent_id,new_rule_id,'ANTECEDENT_ID');
END IF;
IF  var_consequent_id IS NOT NULL THEN
    Copy_EXPRESSION_(var_consequent_id,new_rule_id,'CONSEQUENT_ID');
END IF;
IF  var_amount_id IS NOT NULL THEN
    Copy_EXPRESSION_(var_amount_id,new_rule_id,'AMOUNT_ID');
END IF;

Copy_FILTER_SET;
Copy_EXPRESSION_NODE(TRUE,new_rule_id);

p_out_new_rule_id:=new_rule_id;

EXCEPTION
WHEN END_OPERATION THEN
     NULL;
WHEN NO_DATA_FOUND THEN
     LOG_REPORT('CZ_PS_COPY.Copy_RULES_subschema',SQLERRM);
WHEN OTHERS THEN
     LOG_REPORT('CZ_PS_COPY.Copy_RULES_subschema',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Copy_DES_CHART_COLUMN IS

new_rule_id           INTEGER;
new_feature_id        INTEGER;
new_option_id         INTEGER;
new_model_ref_expl_id INTEGER;

BEGIN

FOR i IN(SELECT * FROM CZ_DES_CHART_COLUMNS WHERE rule_id IN
         (SELECT rule_id FROM CZ_RULES WHERE devl_project_id=OLD_PROJECT_ID
         AND deleted_flag=NO_FLAG) AND option_id IN
         (SELECT ps_node_id FROM CZ_PS_NODES WHERE devl_project_id=OLD_PROJECT_ID
         AND deleted_flag=NO_FLAG))
LOOP
   BEGIN

   BEGIN
   new_rule_id:=FlowId_Rule(i.rule_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_rule_id:=i.rule_id;
   END;

   BEGIN
   new_option_id:=FlowId_PS_NODE(i.option_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_option_id:=i.option_id;
   END;

   BEGIN
   new_feature_id:=FlowId_PS_NODE(i.feature_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_feature_id:=i.feature_id;
   END;

   BEGIN
   new_model_ref_expl_id:=FlowId_MODEL_REF_EXPL(i.model_ref_expl_id);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        new_model_ref_expl_id:=i.model_ref_expl_id;
   END;

   INSERT INTO CZ_DES_CHART_COLUMNS
          (RULE_ID,
           OPTION_ID,
           COLUMN_WIDTH,
           FEATURE_ID,
           MODEL_REF_EXPL_ID)
   SELECT
           new_rule_id,
           new_option_id,
           i.COLUMN_WIDTH,
           new_feature_id,
           new_model_ref_expl_id
   FROM CZ_DES_CHART_COLUMNS
   WHERE rule_id=i.rule_id AND option_id=i.option_id;

   PACK;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        LOG_REPORT('CZ_PS_COPY.Copy_DES_CHART_COLUMN','rule_id='||TO_CHAR(i.rule_id)||
        ' option_id='||TO_CHAR(i.option_id)||' : '||SQLERRM);
   WHEN OTHERS THEN
        LOG_REPORT('CZ_PS_COPY.Copy_DES_CHART_COLUMN','rule_id='||TO_CHAR(i.rule_id)||
        ' option_id='||TO_CHAR(i.option_id)||' : '||SQLERRM);
   END;
END LOOP;

EXCEPTION
WHEN OTHERS THEN
     LOG_REPORT('CZ_PS_COPY.Copy_DES_CHART_COLUMN',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE copy_RULE_SEQ
(p_rule_seq_id     IN INTEGER,
 p_new_rule_seq_id IN OUT NOCOPY INTEGER) IS

new_rule_id INTEGER;

BEGIN

/* Exception is raised for BUG No.4028599*/
RAISE_APPLICATION_ERROR(-20001, 'ERROR: CZ_PS_COPY is obsolete in 11.5.10 and later builds.');

SELECT CZ_RULE_FOLDERS_S.NEXTVAL INTO p_new_rule_seq_id FROM dual;
INSERT INTO CZ_RULE_FOLDERS
       (RULE_FOLDER_ID,
        FOLDER_TYPE,
        NAME,
        DESC_TEXT,
        PARENT_RULE_FOLDER_ID,
        TREE_SEQ,
        DEVL_PROJECT_ID,
        PERSISTENT_RULE_FOLDER_ID,
        EFFECTIVE_USAGE_MASK,
        EFFECTIVE_FROM,
        EFFECTIVE_UNTIL,
        EFFECTIVITY_SET_ID,
        DELETED_FLAG,
        SECURITY_MASK,
        CHECKOUT_USER,
        OBJECT_TYPE,
        DISABLED_FLAG,
        ORIG_SYS_REF)
SELECT  p_new_rule_seq_id,
        FOLDER_TYPE,
        NAME||'-'||TO_CHAR(p_new_rule_seq_id),
        DESC_TEXT,
        PARENT_RULE_FOLDER_ID,
        TREE_SEQ,
        DEVL_PROJECT_ID,
        PERSISTENT_RULE_FOLDER_ID,
        EFFECTIVE_USAGE_MASK,
        EFFECTIVE_FROM,
        EFFECTIVE_UNTIL,
        EFFECTIVITY_SET_ID,
        DELETED_FLAG,
        SECURITY_MASK,
        CHECKOUT_USER,
        OBJECT_TYPE,
        DISABLED_FLAG,
        ORIG_SYS_REF
FROM CZ_RULE_FOLDERS WHERE rule_folder_id=p_rule_seq_id AND deleted_flag=NO_FLAG;

PACK;

FOR i IN ( SELECT rule_id FROM CZ_RULES WHERE rule_folder_id=p_rule_seq_id AND deleted_flag=NO_FLAG)
LOOP
   Copy_RULES_subschema(i.rule_id,new_rule_id, '0', NULL, '0');
   UPDATE CZ_RULES SET rule_folder_id=p_new_rule_seq_id
   WHERE rule_id=new_rule_id;

   PACK;

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     p_new_rule_seq_id:=-GLOBAL_RUN_ID;
     LOG_REPORT('CZ_PS_COPY.copy_RULE_SEQ',SQLERRM);
WHEN OTHERS THEN
     p_new_rule_seq_id:=-GLOBAL_RUN_ID;
     LOG_REPORT('CZ_PS_COPY.copy_RULE_SEQ',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE copy_RULE
(p_rule_seq_id     IN INTEGER,
 p_new_rule_seq_id IN OUT NOCOPY INTEGER) IS

new_rule_id INTEGER;

BEGIN

FOR i IN ( SELECT rule_id FROM CZ_RULES WHERE rule_folder_id=p_rule_seq_id AND deleted_flag=NO_FLAG)
LOOP
   Copy_RULES_subschema(i.rule_id,new_rule_id, '0', NULL, '0');
   UPDATE CZ_RULES SET rule_folder_id=p_new_rule_seq_id
   WHERE rule_id=new_rule_id;
END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     p_new_rule_seq_id:=-GLOBAL_RUN_ID;
     LOG_REPORT('CZ_PS_COPY.copy_RULE_SEQ',SQLERRM);
WHEN OTHERS THEN
     p_new_rule_seq_id:=-GLOBAL_RUN_ID;
     LOG_REPORT('CZ_PS_COPY.copy_RULE_SEQ',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Project_Copy
(p_old_id      IN  INTEGER,
 p_new_id      IN OUT NOCOPY  INTEGER,
 p_Copy_Rules  IN  VARCHAR2 , -- DEFAULT '1',
 p_Copy_UI     IN  VARCHAR2 , -- DEFAULT '1',
 p_name        IN  VARCHAR2 DEFAULT NULL,
 p_folder_id   IN  INTEGER  DEFAULT NULL
) IS

new_id      INTEGER;

BEGIN

/* Exception is raised for BUG No.4028599*/
RAISE_APPLICATION_ERROR(-20001, 'ERROR: CZ_PS_COPY is obsolete in 11.5.10 and later builds.');

SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO GLOBAL_RUN_ID FROM dual;
Initialize;

OLD_PROJECT_ID:=p_old_id;
ENCLOSE_FOLDER:=p_folder_id;
Copy_DEVL_PROJECT(p_name);
p_new_id:=NEW_PROJECT_ID;

Copy_EXPRESSION;
Copy_FILTER_SET;
Copy_PS_NODE;
Copy_MODEL_REF_EXPL;

IF p_Copy_Rules='1' THEN
   BEGIN
-- Copy_EXPRESSION;
-- Copy_FILTER_SET;

   Copy_RULE_FOLDERS;
   Copy_FUNC_COMP_SPEC('1');
   Copy_POPULATOR;
   Copy_EXPRESSION_NODE(FALSE);
   copy_GRID_DEF;
   Copy_GRID_COL;
   Copy_GRID_CELL(FALSE);
   Copy_RULE;
   Copy_CHART_Tables;
   Copy_COMBO_FEATURE;

   Copy_DES_CHART_COLUMN;

   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;
END IF;

IF p_Copy_UI='1' THEN
   BEGIN
   copy_UI;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
        NULL;
   END;
END IF;

Copy_XFR_PROJECT_BILL;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     p_new_id:=-GLOBAL_RUN_ID;
     LOG_REPORT('CZ_PS_COPY.Project_Copy',SQLERRM);
WHEN OTHERS THEN
     p_new_id:=-GLOBAL_RUN_ID;
     LOG_REPORT('CZ_PS_COPY.Project_Copy',SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Test
(p_id        IN INTEGER,
 p_Rules     IN VARCHAR2 , -- DEFAULT '1',
 p_UI        IN VARCHAR2 , -- DEFAULT '1',
 p_folder_id IN INTEGER    -- DEFAULT -1
) IS
new_id INTEGER;
BEGIN

/* Exception is raised for BUG No.4028599*/
RAISE_APPLICATION_ERROR(-20001, 'ERROR: CZ_PS_COPY is obsolete in 11.5.10 and later builds.');

Project_Copy(p_id,new_id,p_Rules,p_UI,NULL,p_folder_id);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                 END PACKAGE
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

END;

/
