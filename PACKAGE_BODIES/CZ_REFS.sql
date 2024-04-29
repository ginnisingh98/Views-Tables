--------------------------------------------------------
--  DDL for Package Body CZ_REFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_REFS" AS
/*	$Header: czrefb.pls 120.5.12010000.4 2010/05/18 20:35:25 smanna ship $*/

PRODUCT_TYPE   CONSTANT INTEGER:=258;
COMPONENT_TYPE CONSTANT INTEGER:=259;
FEATURE_TYPE   CONSTANT INTEGER:=261;
OPTION_TYPE    CONSTANT INTEGER:=262;
REFERENCE_TYPE CONSTANT INTEGER:=263;
CONNECTOR_TYPE CONSTANT INTEGER:=264;
BOM_MODEL_TYPE CONSTANT INTEGER:=436;

CONTRIBUTE_TO_MIN_SUBTYPE CONSTANT INTEGER:=4;
CONTRIBUTE_TO_MAX_SUBTYPE CONSTANT INTEGER:=5;

CONTRIBUTE_TO_MIN    CONSTANT INTEGER:=1;
CONTRIBUTE_TO_MAX    CONSTANT INTEGER:=2;
CONTRIBUTE_TO_MINMAX CONSTANT INTEGER:=3;

MINUS_MODE     CONSTANT VARCHAR2(1):='-';
PLUS_MODE      CONSTANT VARCHAR2(1):='+';

TYPE IdStructure  IS RECORD(new_id              INTEGER,
                            parent_id           INTEGER,
                            ps_node_id          INTEGER,
                            ps_node_type        INTEGER,
                            component_id        INTEGER,
                            child_model_id      INTEGER,
                            current_level       INTEGER,
                            expl_node_type      INTEGER,
                            virtual_flag        VARCHAR2(1),
                            expl_path           VARCHAR2(32000));

TYPE modelArrStructure  IS RECORD(model_id           INTEGER,
                                  parent_model_id    INTEGER,
                                  connector_loop     BOOLEAN:=FALSE);

TYPE ArrayId  IS TABLE   OF IdStructure INDEX BY BINARY_INTEGER;
TYPE IntArray IS TABLE   OF NUMBER INDEX BY BINARY_INTEGER;
TYPE modelArray IS TABLE OF modelArrStructure  INDEX BY BINARY_INTEGER;
TYPE Int2Array  IS TABLE OF IntArray INDEX BY BINARY_INTEGER;
TYPE Varchar2Array IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;

TYPE Int2RecArray  IS TABLE OF ArrayId INDEX BY BINARY_INTEGER;

g_hash_tree_tbl       Int2RecArray;
g_root_point_tree_tbl IntArray;
t_models              modelArray;
t_chain               modelArray;
t_projectCache        IntArray;

--9446997 fix
t_upd_node_depth_models IntArray;

t_old_expl_ids   IntArray;
t_new_expl_ids   IntArray;

m_RUN_ID         NUMBER;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE Initialize IS
BEGIN
    FND_MSG_PUB.initialize;
    SELECT CZ_XFR_RUN_INFOS_S.NEXTVAL INTO m_RUN_ID FROM dual;
END Initialize;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE LOG_REPORT
(p_caller    IN VARCHAR2,
 p_str       IN VARCHAR2) IS

   l_return BOOLEAN;

BEGIN
   l_return := cz_utils.log_report(Msg        => p_str,
                                   Urgency    => 1,
                                   ByCaller   => p_caller,
                                   StatusCode => 11276,
                                   RunId      => m_RUN_ID);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE DEBUG(p_str IN VARCHAR2) IS
BEGIN
    NULL;
    --DBMS_OUTPUT.PUT_LINE(p_str);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE DEBUG(p_str IN VARCHAR2,v_num IN NUMBER) IS
BEGIN
    DEBUG(p_str||'='||TO_CHAR(v_num));
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE DEBUG(p_name IN VARCHAR2,p_arr IN ArrayId) IS
    v_ind     PLS_INTEGER;
    v_counter PLS_INTEGER:=0;
BEGIN
    IF p_arr.COUNT=0 THEN
       RETURN;
    END IF;
    v_ind:=p_arr.FIRST;
    LOOP
       IF v_ind IS NULL THEN
          EXIT;
       END IF;
       v_counter:=v_counter+1;
       DEBUG('++++++ '||TO_CHAR(v_counter)||' ++++++');
       DEBUG(p_name||'('||TO_CHAR(v_ind)||').new_id='||TO_CHAR(p_arr(v_ind).new_id));
       DEBUG(p_name||'('||TO_CHAR(v_ind)||').parent_id='||TO_CHAR(p_arr(v_ind).parent_id));
       DEBUG(p_name||'('||TO_CHAR(v_ind)||').component_id='||TO_CHAR(p_arr(v_ind).component_id));
       v_ind:=p_arr.NEXT(v_ind);
       DEBUG('++++++++++++++++++++++++++++++++++++++');
   END LOOP;
END DEBUG;
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

-- p_out_flag=0  - it's not nonVirtual --
-- p_out_flag=1  - nonVirtual          --
/* old version
PROCEDURE IsNonVirtual
(p_ps_node_id      IN  INTEGER,
 p_model_id        IN  INTEGER,
 p_out_flag        OUT NOCOPY INTEGER) IS

BEGIN
    p_out_flag:=0;
    SELECT 1 INTO p_out_flag FROM CZ_PS_NODES
    WHERE deleted_flag = NO_FLAG
    AND ps_node_id=p_ps_node_id AND ps_node_type IN(COMPONENT_TYPE,PRODUCT_TYPE,
    REFERENCE_TYPE,CONNECTOR_TYPE,BOM_MODEL_TYPE)
    AND ps_node_id NOT IN
    (SELECT ps_node_id FROM CZ_PS_NODES nodes
    WHERE deleted_flag = NO_FLAG
    AND devl_project_id =p_model_id
    AND ps_node_type IN(COMPONENT_TYPE,REFERENCE_TYPE,CONNECTOR_TYPE,BOM_MODEL_TYPE)
    AND MINIMUM = 1
    AND MAXIMUM = 1
    AND NOT EXISTS
    (SELECT 1 FROM cz_expression_nodes x
    WHERE deleted_flag = NO_FLAG
    AND consequent_flag =YES_FLAG
    AND ps_node_id = nodes.ps_node_id
    AND EXISTS
    (SELECT NULL FROM cz_rules WHERE (antecedent_id=x.express_id OR consequent_id=x.express_id
     OR amount_id=x.express_id) AND disabled_flag=NO_FLAG
    AND devl_project_id=p_model_id AND deleted_flag=NO_FLAG)));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS        THEN
         LOG_REPORT('IsNonVirtual','Error : ps_node_id='||TO_CHAR(p_ps_node_id)||' '||SQLERRM);
END;
*/

PROCEDURE IsNonVirtual
(p_ps_node_id      IN  INTEGER,
 p_model_id        IN  INTEGER,
 p_out_flag        OUT NOCOPY INTEGER) IS

BEGIN
    p_out_flag:=0;
    SELECT 1 INTO p_out_flag FROM CZ_PS_NODES
    WHERE deleted_flag = NO_FLAG
    AND ps_node_id=p_ps_node_id AND (instantiable_flag IN (OPTIONAL_EXPL_TYPE,OPTIONAL_EXPL_TYPE) OR
    (ps_node_type IN(COMPONENT_TYPE,PRODUCT_TYPE,REFERENCE_TYPE,CONNECTOR_TYPE,BOM_MODEL_TYPE) AND NOT(MAXIMUM=1 AND MINIMUM=1)));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN OTHERS        THEN
         LOG_REPORT('IsNonVirtual','Error : ps_node_id='||TO_CHAR(p_ps_node_id)||' '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION allocate_Expl_Id RETURN NUMBER IS
    v_next_id NUMBER;
BEGIN
    SELECT CZ_MODEL_REF_EXPLS_S.NEXTVAL INTO v_next_id FROM dual;
    RETURN v_next_id;
END allocate_Expl_Id;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION get_Root_Expl_Id(p_model_id IN NUMBER) RETURN NUMBER IS
    v_expl_node_id  CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
BEGIN
     SELECT model_ref_expl_id INTO v_expl_node_id FROM CZ_MODEL_REF_EXPLS
     WHERE component_id=p_model_id AND model_id=p_model_id AND
           parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;
     RETURN v_expl_node_id;
END get_Root_Expl_Id;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION circularity_Exists
(
 p_source_model_id IN NUMBER,
 p_target_model_id IN NUMBER
) RETURN VARCHAR2 IS

    p_circularity_exists VARCHAR2(1):=NO_FLAG;

BEGIN
    SELECT YES_FLAG INTO p_circularity_exists FROM dual WHERE
    EXISTS
         (SELECT component_id FROM CZ_MODEL_REF_EXPLS
          WHERE model_id=p_target_model_id AND deleted_flag=NO_FLAG
          AND ps_node_type IN (REFERENCE_TYPE,CONNECTOR_TYPE) AND component_id=p_source_model_id) OR
          (p_target_model_id=p_source_model_id);
          RETURN p_circularity_exists;
     EXCEPTION
         WHEN OTHERS THEN
              RETURN p_circularity_exists;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

-- Bugfix 9446997
-- This procedure was introduced to reset arrays/tables
-- which will store distinct models which will be used
-- to drive update_node_depth
--
-- TO DO - Also need to check it can be used for
-- update_child_nodes
--

PROCEDURE reset_model_array IS
BEGIN
    t_upd_node_depth_models.DELETE;

END reset_model_array;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- this procedure is used in temporary fix for the bug #2425995
--
-- As a part of Bugfix 9446997 array
-- t_upd_node_depth_models will be driving population of
-- update_node_depth during refresh process. Caller to check_node from where
-- this procedure is called should make sure that the reset_model_array
-- is called before calling check_node and pass value '1' for
-- p_skip_upd_nod_depth param in check_node and call update_node_depth
-- explicitly with NULL parameter. (as in cz_imp_ps_node pkg)
--
PROCEDURE update_Node_Depth(p_model_id IN INTEGER DEFAULT NULL) IS

  t_nodes_to_delete_tbl   IntArray;

  PROCEDURE update_Node_Depth_
  (p_model_id     IN INTEGER,
   p_expl_id      IN INTEGER DEFAULT NULL,
   p_node_depth   IN INTEGER DEFAULT NULL,
   p_ps_node_id   IN INTEGER DEFAULT NULL,
   p_ps_node_type IN INTEGER DEFAULT NULL) IS

      v_node_depth         INTEGER;
      v_model_ref_expl_id  INTEGER;

  BEGIN
      IF p_node_depth IS NULL THEN
         UPDATE CZ_MODEL_REF_EXPLS
         SET node_depth=0
         WHERE model_id=p_model_id AND parent_expl_node_id IS NULL
         AND deleted_flag=NO_FLAG
         RETURNING model_ref_expl_id INTO v_model_ref_expl_id;
         update_Node_Depth_(p_model_id,v_model_ref_expl_id,0);
      ELSE
         v_node_depth:=p_node_depth+1;
         FOR i IN(SELECT model_ref_expl_id,referring_node_id,ps_node_type FROM CZ_MODEL_REF_EXPLS
                  WHERE model_id=p_model_id AND parent_expl_node_id=p_expl_id
                  AND deleted_flag=NO_FLAG)
         LOOP
            UPDATE CZ_MODEL_REF_EXPLS
            SET node_depth=v_node_depth
            WHERE model_ref_expl_id=i.model_ref_expl_id AND node_depth<>v_node_depth;

            --
            -- temporary workaround to delete possible reference duplicates
            -- t_nodes_to_delete_tbl stores duplicate nodes
            -- that need to be deleled later
            --
            IF p_ps_node_id=i.referring_node_id
               AND p_ps_node_type=i.ps_node_type THEN
               t_nodes_to_delete_tbl(t_nodes_to_delete_tbl.COUNT+1):=i.model_ref_expl_id;
            END IF;

            update_Node_Depth_(p_model_id,i.model_ref_expl_id,v_node_depth,i.referring_node_id,i.ps_node_type);
         END LOOP;
      END IF;
  END update_Node_Depth_;

BEGIN
    t_nodes_to_delete_tbl.DELETE;

    -- Bugfix 9446997
    IF p_model_id IS NULL THEN
       -- Bugfix 9446997
       -- Drive t_upd_node_depth_models array to update node depth calls
       -- as this will be called after all check_nodes call in BOM Refresh process
       FOR i IN t_upd_node_depth_models.FIRST..t_upd_node_depth_models.LAST
       LOOP
          update_Node_Depth_(t_upd_node_depth_models(i));
       END LOOP;

       -- Instead of using p_model_id as driver use t_upd_node_depth_models array as driver to
       -- delete reference duplicates
       FOR j IN t_upd_node_depth_models.FIRST..t_upd_node_depth_models.LAST
       LOOP
           IF t_nodes_to_delete_tbl.COUNT>0 THEN
              FORALL i IN t_nodes_to_delete_tbl.FIRST..t_nodes_to_delete_tbl.LAST
               UPDATE CZ_MODEL_REF_EXPLS
               SET deleted_flag=YES_FLAG
               WHERE model_ref_expl_id IN
               (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
               START WITH model_id=t_upd_node_depth_models(j) AND model_ref_expl_id=t_nodes_to_delete_tbl(i) AND deleted_flag=NO_FLAG
               CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
                        AND PRIOR deleted_flag=NO_FLAG);
              END IF;
       END LOOP;


    ELSE
       FOR i IN(SELECT DISTINCT model_id FROM cz_model_ref_expls
                WHERE ((component_id=p_model_id AND
                ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE)) OR model_id=p_model_id)
                AND deleted_flag=NO_FLAG)
       LOOP
          update_Node_Depth_(i.model_id);
       END LOOP;

       IF t_nodes_to_delete_tbl.COUNT>0 THEN
          FORALL i IN t_nodes_to_delete_tbl.FIRST..t_nodes_to_delete_tbl.LAST
            UPDATE CZ_MODEL_REF_EXPLS
            SET deleted_flag=YES_FLAG
            WHERE model_ref_expl_id IN
           (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
            START WITH model_id=p_model_id AND model_ref_expl_id=t_nodes_to_delete_tbl(i) AND deleted_flag=NO_FLAG
            CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
                            AND PRIOR deleted_flag=NO_FLAG);
       END IF;

    END IF;   -- p_model_id IS NULL


END update_Node_Depth;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

-- p_out_flag=0  - it's not nonVirtual --
-- p_out_flag=1  - nonVirtual          --

FUNCTION existContributeRule
(p_ps_node_id      IN  INTEGER,
 p_model_id        IN  INTEGER) RETURN BOOLEAN IS

    v_iret  INTEGER:=0;
    v_bret  BOOLEAN:=FALSE;
    v_instantiable_flag CZ_PS_NODES.instantiable_flag%TYPE;

BEGIN
    SELECT instantiable_flag INTO v_instantiable_flag
      FROM CZ_PS_NODES
     WHERE ps_node_id=p_ps_node_id;
    IF v_instantiable_flag IN(OPTIONAL_EXPL_TYPE,MINMAX_EXPL_TYPE) THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;
    /* old code
    BEGIN
        SELECT 1 INTO v_iret FROM dual
        WHERE
        EXISTS(SELECT NULL FROM cz_expression_nodes x
        WHERE deleted_flag = NO_FLAG
        AND consequent_flag =YES_FLAG
        AND ps_node_id = p_ps_node_id
        AND EXISTS
       (SELECT NULL FROM cz_rules WHERE (antecedent_id=x.express_id OR consequent_id=x.express_id
        OR amount_id=x.express_id) AND disabled_flag=NO_FLAG
        AND devl_project_id=p_model_id AND deleted_flag=NO_FLAG));
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
             NULL;
        WHEN OTHERS THEN
              LOG_REPORT('existContributeRule','Error : ps_node_id='||TO_CHAR(p_ps_node_id)||' '||SQLERRM);
     END;

     IF v_iret=0 THEN
        v_bret:=FALSE;
     ELSE
        v_bret:=TRUE;
     END IF;

     RETURN v_bret;
    */
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION getExprSubType(p_expr_node_id IN INTEGER) RETURN NUMBER IS

    v_expr_parent  CZ_EXPRESSION_NODES.expr_parent_id%TYPE;
    v_expr_subtype CZ_EXPRESSION_NODES.expr_subtype%TYPE;

BEGIN
    SELECT expr_parent_id INTO v_expr_parent
    FROM CZ_EXPRESSION_NODES WHERE expr_node_id=p_expr_node_id AND
    deleted_flag=NO_FLAG;

    SELECT expr_subtype INTO v_expr_subtype
    FROM CZ_EXPRESSION_NODES WHERE expr_parent_id=v_expr_parent AND ps_node_id IS NULL AND
    deleted_flag=NO_FLAG;

    RETURN v_expr_subtype;

EXCEPTION
    WHEN OTHERS THEN
         RETURN -1;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

-- p_out_flag=0  - it's not nonVirtual --
-- p_out_flag=1  - nonVirtual          --

FUNCTION getExplType
(p_ps_node_id      IN  INTEGER,
 p_model_id        IN  INTEGER,
 p_minimum         IN  INTEGER,
 p_maximum         IN  INTEGER,
 p_ps_node_type    IN  INTEGER) RETURN NUMBER IS

    v_expr_parent_id  CZ_EXPRESSION_NODES.expr_parent_id%TYPE;
    v_expr_subtype    CZ_EXPRESSION_NODES.expr_subtype%TYPE;
    v_expl_node_type  CZ_MODEL_REF_EXPLS.expl_node_type%TYPE;

BEGIN
        FOR i IN (SELECT rule_id,antecedent_id,consequent_id,NAME FROM CZ_RULES
                  WHERE devl_project_id=p_model_id AND disabled_flag=NO_FLAG
                  AND deleted_flag=NO_FLAG)
        LOOP
           BEGIN
               SELECT expr_parent_id INTO v_expr_parent_id FROM CZ_EXPRESSION_NODES
               WHERE ps_node_id=p_ps_node_id AND deleted_flag=NO_FLAG AND
               rule_id=i.rule_id;

               SELECT expr_subtype INTO v_expr_subtype
               FROM CZ_EXPRESSION_NODES WHERE expr_parent_id=v_expr_parent_id AND ps_node_id IS NULL AND
               deleted_flag=NO_FLAG;

               IF v_expr_subtype=CONTRIBUTE_TO_MIN_SUBTYPE THEN
                  IF (p_minimum=1 AND p_maximum=1) OR (p_minimum=0 AND p_maximum=1) THEN
                     v_expl_node_type:=OPTIONAL_EXPL_TYPE;
                  ELSE
                     RETURN MINMAX_EXPL_TYPE;
                  END IF;
               END IF;

               IF v_expr_subtype=CONTRIBUTE_TO_MAX_SUBTYPE THEN
                  RETURN MINMAX_EXPL_TYPE;
               END IF;

          EXCEPTION
               WHEN OTHERS THEN
                    NULL;
          END;
       END LOOP;

      IF p_minimum=1 AND p_maximum=1 AND v_expl_node_type=OPTIONAL_EXPL_TYPE THEN
         RETURN OPTIONAL_EXPL_TYPE;
      END IF;

      IF NOT(p_minimum=1 AND p_maximum=1) AND v_expl_node_type=OPTIONAL_EXPL_TYPE THEN
         IF p_minimum=0 AND p_maximum=1 THEN
            RETURN OPTIONAL_EXPL_TYPE;
         ELSE
            RETURN MINMAX_EXPL_TYPE;
         END IF;
      END IF;

      IF NOT(p_minimum=1 AND p_maximum=1) AND NOT(p_minimum=0 AND p_maximum=1) THEN
            RETURN MINMAX_EXPL_TYPE;
      END IF;

      IF p_minimum=0 AND p_maximum=1 THEN
            RETURN OPTIONAL_EXPL_TYPE;
      END IF;

      IF p_minimum=1 AND p_maximum=1 AND p_ps_node_type=REFERENCE_TYPE THEN
            RETURN MANDATORY_EXPL_TYPE;
      END IF;

      IF p_minimum=1 AND p_maximum=1 AND p_ps_node_type=CONNECTOR_TYPE THEN
            RETURN CONNECTOR_EXPL_TYPE;
      END IF;

      RETURN 0;
END;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE add_root_Model_record
(p_ps_node_id   IN  INTEGER,
 p_ps_node_type IN  INTEGER) IS

    v_expl_id NUMBER;

BEGIN
    v_expl_id:=allocate_Expl_Id;

    INSERT INTO CZ_MODEL_REF_EXPLS
           (model_ref_expl_id,
            parent_expl_node_id,
            referring_node_id,
            model_id,
            component_id,
            ps_node_type,
            virtual_flag,
            node_depth,
	    expl_node_type,
            deleted_flag)
    VALUES (v_expl_id,
            NULL,
            NULL,
            p_ps_node_id,
            p_ps_node_id,
            p_ps_node_type,
            YES_FLAG,
            0,
	      MANDATORY_EXPL_TYPE,
            NO_FLAG);

END add_root_Model_record;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- populate chain of connected models starting with model ( p_model_id )
-- format of record : model_id/parent_model_id
-- Example :
--  M3
--   |---> M2
--         |--->M1
--               |--~~~--> M3 ( Circular connector )
-- we start with M1 and go up on the tree
-- until M3
-- so t_chain is { M1/M2, M2/M3, M3/null }
-- note that element for M3 must have parent_model_id=null - not M1
-- otherwise we will have  a VERY BIG PROBLEM because of circularity :
--  check_node/move_node/delete_node  will go to infinite loop
--
PROCEDURE populate_chain
(p_model_id            IN  INTEGER) IS
TYPE IntArray IS TABLE   OF NUMBER INDEX BY VARCHAR2(15);
t_models             IntArray;
v_circularity_exists BOOLEAN:=FALSE;

    PROCEDURE pop(p_id IN NUMBER) IS
        v_ind NUMBER:=0;
    BEGIN
        FOR i IN(SELECT DISTINCT devl_project_id FROM CZ_PS_NODES a
                 WHERE reference_id=p_id AND deleted_flag=NO_FLAG AND
                 devl_project_id IN(SELECT object_id FROM CZ_RP_ENTRIES
                 WHERE object_id=a.devl_project_id AND object_type='PRJ' AND deleted_flag=NO_FLAG))
        LOOP
           v_ind:=t_chain.COUNT+1;
           t_chain(v_ind).model_id:=i.devl_project_id;
           t_chain(v_ind).parent_model_id:=p_id;

           v_circularity_exists:=t_models.EXISTS(i.devl_project_id);
           t_models(i.devl_project_id):=p_id;

           IF i.devl_project_id <> p_model_id AND
              NOT(v_circularity_exists) THEN
              pop(i.devl_project_id);
           ELSE
              --t_chain(v_ind).parent_model_id:=NULL;
              NULL;
           END IF;
        END LOOP;
    END pop;

BEGIN
    pop(p_model_id);
END populate_chain;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE calc_Expl_Paths(p_root_expl_id IN NUMBER,x_paths_tbl OUT NOCOPY Varchar2Array ) IS
BEGIN

  FOR m IN(SELECT model_ref_expl_id,parent_expl_node_id,component_id,referring_node_id
             FROM CZ_MODEL_REF_EXPLS
            START WITH model_ref_expl_id=p_root_expl_id
            CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag='0' AND PRIOR deleted_flag='0')
  LOOP

    IF m.referring_node_id IS NULL THEN

      IF x_paths_tbl.EXISTS(m.parent_expl_node_id) THEN
        IF x_paths_tbl(m.parent_expl_node_id)='.' THEN
          x_paths_tbl(m.model_ref_expl_id) := TO_CHAR(m.component_id);
        ELSE
          x_paths_tbl(m.model_ref_expl_id) := TO_CHAR(m.component_id)||'.'||x_paths_tbl(m.parent_expl_node_id);
        END IF;
      ELSE
        x_paths_tbl(m.model_ref_expl_id) := '.';
      END IF;

    ELSE

      IF x_paths_tbl.EXISTS(m.parent_expl_node_id) THEN
        IF x_paths_tbl(m.parent_expl_node_id)='.' THEN
          x_paths_tbl(m.model_ref_expl_id) := TO_CHAR(m.referring_node_id);
        ELSE
          x_paths_tbl(m.model_ref_expl_id) := TO_CHAR(m.referring_node_id)||'.'||x_paths_tbl(m.parent_expl_node_id);
        END IF;
      ELSE
        x_paths_tbl(m.model_ref_expl_id) := '.';
      END IF;

    END IF;

  END LOOP;

END calc_Expl_Paths;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- populate target subtree = array that contains expl tree of the target model ( p_target_model_id )
-- Example :
--     M3
--     |-->M2
--         |--C2
--         |------>M1
--                 |--->C1
-- now if we add a circular connector  from M4 to M3
-- then target subtree will look like :
--     M3
--     |-->M2
--         |--C2
--         |------>M1
--                 |--->C1
--
PROCEDURE get_Expl_Tree
(
 p_target_model_id         IN  NUMBER,
 px_root_expl_id           OUT NOCOPY NUMBER,
 p_target_subtree_tbl      IN OUT NOCOPY ArrayId
) IS
  l_paths_tbl VArchar2Array;
  l_expl_id   NUMBER;
BEGIN
     FOR i IN (SELECT  parent_expl_node_id,referring_node_id,ps_node_type,
                       virtual_flag,component_id,expl_node_type,model_ref_expl_id,LEVEL
               FROM CZ_MODEL_REF_EXPLS
               START WITH model_id=p_target_model_id AND component_id=p_target_model_id -- this condition specifies root of expl tree
                          AND deleted_flag=NO_FLAG
               CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
     LOOP
        IF i.parent_expl_node_id IS NULL THEN
           px_root_expl_id:=i.model_ref_expl_id;
        END IF;
        p_target_subtree_tbl(i.model_ref_expl_id).new_id:=i.model_ref_expl_id;
        p_target_subtree_tbl(i.model_ref_expl_id).parent_id:=i.parent_expl_node_id;
        p_target_subtree_tbl(i.model_ref_expl_id).ps_node_id:=i.referring_node_id;
        p_target_subtree_tbl(i.model_ref_expl_id).ps_node_type:=i.ps_node_type;
        p_target_subtree_tbl(i.model_ref_expl_id).virtual_flag:=i.virtual_flag;
        p_target_subtree_tbl(i.model_ref_expl_id).component_id:=i.component_id;
        p_target_subtree_tbl(i.model_ref_expl_id).expl_node_type:=i.expl_node_type;
        p_target_subtree_tbl(i.model_ref_expl_id).child_model_id:=i.model_ref_expl_id;
        p_target_subtree_tbl(i.model_ref_expl_id).current_level:=i.LEVEL;
    END LOOP;

    calc_Expl_Paths(px_root_expl_id,l_paths_tbl);
    l_expl_id := p_target_subtree_tbl.First;
    LOOP
      IF l_expl_id IS NULL THEN
        EXIT;
      END IF;
      p_target_subtree_tbl(l_expl_id).expl_path := l_paths_tbl(l_expl_id);
      l_expl_id := p_target_subtree_tbl.NEXT(l_expl_id);
    END LOOP;

END get_Expl_Tree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- the procedure uses target subtree to construct attached subtree in circular connectors case
--
PROCEDURE filter_Branches
(
p_target_model_id     IN NUMBER,
p_target_subtree_tbl      IN OUT NOCOPY ArrayId,       -- stores target subtree
x_subtree_tbl             IN OUT NOCOPY ArrayId        -- will store subtree
) IS

    t_model_ref_expl_ids_tbl  IntArray;

BEGIN
    --
    -- inialize OUTPUT subtree
    --
    x_subtree_tbl:=p_target_subtree_tbl;

    --
    -- collect expl_ids which belong to subtrees of the references/connectors of excluded branch
    -- Example :
    -- suppose p_target_subtree_tbl looks like :
    -- M3
    -- |---> M2
    --       |---C2
    --       |-~~~~~~~~->M1 ( CONNECTOR )
    --       |        |_C1
    --       |--------------->M5
    --  then we need to collect expl_ids of the following subtrees
    --  M1         and     M5
    --  |--C1
    --  so in this case t_model_ref_expl_ids_tbl will store 2 elements
    --
    FOR i IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
             WHERE model_id=p_target_model_id AND deleted_flag=NO_FLAG AND
             ps_node_type IN(CONNECTOR_TYPE,REFERENCE_TYPE) )
    LOOP
       FOR j IN (SELECT model_ref_expl_id,ps_node_type
                 FROM CZ_MODEL_REF_EXPLS
                 START WITH model_ref_expl_id = i.model_ref_expl_id AND deleted_flag=NO_FLAG
                 CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
       LOOP
          t_model_ref_expl_ids_tbl(t_model_ref_expl_ids_tbl.COUNT+1):=j.model_ref_expl_id;
       END LOOP;
    END LOOP;

    IF t_model_ref_expl_ids_tbl.COUNT=0 THEN
       RETURN;
    END IF;

    --
    -- remove those branches from the target subtree which point to model with model_id=p_exluded_model_id
    -- <=> remove all expl_ids from ( x_subtree_tbl that was initilized as p_target_subtree_tbl )
    -- that we collected before
    --
    FOR i IN t_model_ref_expl_ids_tbl.FIRST..t_model_ref_expl_ids_tbl.LAST
    LOOP
       x_subtree_tbl.DELETE(t_model_ref_expl_ids_tbl(i));
    END LOOP;

END filter_Branches;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- the procedure is used for attaching subtree to the new subtree root node
-- of model from the NEXT LEVEL of the chain of connected models
-- this means  that p_subtree_tbl contains subtree from the PREVIOUS LEVEL
-- we need to rekey this subtree and attach it to the new subtree root node identified by p_new_root_expl_id
-- of the model from the NEXT LEVEL
--
PROCEDURE attach_Subtree
(
p_model_id                IN NUMBER,              -- model_id of the model to which we are attaching subtree
p_new_root_expl_id        IN NUMBER,              -- expl_id of new root node
p_new_root_level          IN NUMBER,              -- node_depth of new root node
p_subtree_root_expl_id    IN NUMBER,              -- expl_id of the rood node of  subtree
p_subtree_tbl             IN ArrayId) IS          -- stores subtree

    t_subtree_tbl             ArrayId;   -- stores rehashed ( rekeyed ) subtree

    t_next_level_expl_ids_tbl ArrayId;

    v_parent_id          CZ_MODEL_REF_EXPLS.parent_expl_node_id%TYPE;
    v_level              CZ_MODEL_REF_EXPLS.node_depth%TYPE;
    v_next_id            CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_ind                CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_subtree_root_level CZ_MODEL_REF_EXPLS.node_depth%TYPE;

BEGIN

    t_subtree_tbl := p_subtree_tbl;

    ---- FIRST STEP : rehash subtree

    v_ind:=p_subtree_tbl.FIRST;
    LOOP
       IF v_ind IS NULL THEN
          EXIT;
       END IF;

       IF (v_ind = p_subtree_root_expl_id) THEN
         v_subtree_root_level := t_subtree_tbl(v_ind).current_level;
       END IF;

       t_subtree_tbl(v_ind).new_id := allocate_Expl_Id;
       v_ind:=p_subtree_tbl.NEXT(v_ind);
    END LOOP;

    ---- NEXT STEP : attach subtree

    v_ind:=t_subtree_tbl.FIRST;
    LOOP
       IF v_ind IS NULL THEN
          EXIT;
       END IF;

       IF (v_ind = p_subtree_root_expl_id) THEN
          --
          -- if this is a root node
          -- then attach the root node to a new subtree root identified by model_ref_expl_id = p_new_root_expl_id
          --
          v_parent_id := p_new_root_expl_id;
          v_level     := p_new_root_level+1;
       ELSE
          BEGIN
              v_level:= p_new_root_level + (t_subtree_tbl(v_ind).current_level-v_subtree_root_level);
              v_parent_id:=t_subtree_tbl(t_subtree_tbl(v_ind).parent_id).new_id;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   v_parent_id:=t_subtree_tbl(p_subtree_root_expl_id).new_id;
              WHEN OTHERS THEN
                   v_parent_id:=t_subtree_tbl(p_subtree_root_expl_id).new_id;
          END;
       END IF;

       IF v_parent_id=p_new_root_expl_id THEN -- this is a root of attached subtree
         g_root_point_tree_tbl(p_new_root_expl_id) := t_subtree_tbl(v_ind).new_id; -- store maping between attach point and root of attached subtree
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
               deleted_flag)
           VALUES
               (t_subtree_tbl(v_ind).new_id,
               v_parent_id,
               t_subtree_tbl(v_ind).ps_node_id,
               p_model_id,
               t_subtree_tbl(v_ind).component_id,
               NULL,
               t_subtree_tbl(v_ind).ps_node_type,
               t_subtree_tbl(v_ind).virtual_flag,
               v_level,
               t_subtree_tbl(v_ind).expl_node_type,
               NO_FLAG);

       t_next_level_expl_ids_tbl(v_ind).new_id         := t_subtree_tbl(v_ind).new_id;
       t_next_level_expl_ids_tbl(v_ind).ps_node_id     := t_subtree_tbl(v_ind).ps_node_id;
       t_next_level_expl_ids_tbl(v_ind).component_id   := t_subtree_tbl(v_ind).component_id;
       t_next_level_expl_ids_tbl(v_ind).expl_path      := t_subtree_tbl(v_ind).expl_path;


       v_ind:=t_subtree_tbl.NEXT(v_ind);
    END LOOP;

    -- release memory allocated for t_subtree_tbl array
    t_subtree_tbl.DELETE;

    FOR i IN(SELECT ps_node_id, devl_project_id FROM CZ_PS_NODES a
              WHERE reference_id=p_model_id AND deleted_flag='0'
                                            AND EXISTS (SELECT NULL FROM cz_devl_projects
                                                        WHERE devl_project_id = a.devl_project_id
                                                          AND deleted_flag='0'))
    LOOP
      FOR h IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                 WHERE model_id=i.devl_project_id AND
                       child_model_expl_id=p_new_root_expl_id AND deleted_flag='0')
      LOOP
        g_hash_tree_tbl(h.model_ref_expl_id) := t_next_level_expl_ids_tbl;
      END LOOP;
    END LOOP;

    t_next_level_expl_ids_tbl.DELETE;

END attach_Subtree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- this procedure populates child_model_expl_id's.
-- It uses global arrays g_root_point_tree_tbl and g_hash_tree_tbl which are
-- populated in attach_Subtree()
--
PROCEDURE populate_Child_Model_Expl_id IS

  t_attach_subtree_tbl       ArrayId;
  l_expl_paths_tbl           Varchar2Array;
  l_new_expl_id              NUMBER;

  v_ind                      NUMBER;
  v_expl_id                  NUMBER;
  v_root_expl_id             NUMBER;

BEGIN

  v_ind := g_hash_tree_tbl.First;
  LOOP
    IF v_ind IS NULL THEN
      EXIT;
    END IF;

    v_root_expl_id := g_root_point_tree_tbl(v_ind);
    t_attach_subtree_tbl := g_hash_tree_tbl(v_ind);

    calc_Expl_Paths(v_root_expl_id, l_expl_paths_tbl);

    l_new_expl_id := l_expl_paths_tbl.First;
    LOOP
      IF l_new_expl_id IS NULL THEN
        EXIT;
      END IF;

      v_expl_id := t_attach_subtree_tbl.First;
      LOOP
        IF v_expl_id IS NULL THEN
          EXIT;
        END IF;

        IF l_expl_paths_tbl(l_new_expl_id) = t_attach_subtree_tbl(v_expl_id).expl_path THEN

          UPDATE CZ_MODEL_REF_EXPLS
             SET child_model_expl_id=t_attach_subtree_tbl(v_expl_id).new_id
           WHERE model_ref_expl_id=l_new_expl_id;

        END IF;
        v_expl_id := t_attach_subtree_tbl.NEXT(v_expl_id);
      END LOOP;

      l_new_expl_id := l_expl_paths_tbl.NEXT(l_new_expl_id);
    END LOOP;
    l_expl_paths_tbl.DELETE;
    v_ind := g_hash_tree_tbl.NEXT(v_ind);
  END LOOP;

END populate_Child_Model_Expl_id;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- attach subtree ( presented as array ) to all connected models
--
PROCEDURE copy_Subtree
(p_model_id                IN INTEGER,            -- current model id
 p_target_model_id         IN INTEGER,
 p_parent_ps_id            IN INTEGER,            -- ps_node_id of the node to attach subtree
 p_target_root_expl_id     IN INTEGER,            -- expl_id of the root node of subtree ( <=> p_target_subtree_tbl )
 p_target_subtree_tbl      IN OUT NOCOPY ArrayId, -- array which contains subtree
 p_ps_node_type            IN INTEGER
 ) IS
    TYPE IntArrayIndexVC2 IS TABLE   OF NUMBER INDEX BY VARCHAR2(15);
    t_temp_tree_tbl            IntArray;
    t_connect_point_tbl        IntArray;
    t_models_level             IntArrayIndexVC2;   -- is populated by model_ids of the current level ( in a chain of connected models )
    t_new_models_level         IntArrayIndexVC2;   -- is populated by model_ids for the next level ( in a chain of connected models )
    t_hash_models              IntArrayIndexVC2;   -- stores already handled models
    t_subtree_tbl              ArrayId;
    v_circularity_exists       VARCHAR2(1):=NO_FLAG;
    v_connector_parent_exists  VARCHAR2(1):=NO_FLAG;
    v_ind                      NUMBER;
    v_el                       NUMBER;

BEGIN
    -- initialize global arrays which stores expl_ids
    g_hash_tree_tbl.DELETE;
    g_root_point_tree_tbl.DELETE;

    IF p_target_model_id=p_model_id THEN   -- this is an obvious circular case

       v_circularity_exists:=YES_FLAG;

       --
       -- exlude all References/Connectors from the subtree that we are attaching
       -- to the current model (p_model_id)
       -- t_subtree_tbl will store the subtree without References/Connectors subtrees
       --
       filter_Branches(p_target_model_id    => p_model_id,
                       p_target_subtree_tbl => p_target_subtree_tbl,
                       x_subtree_tbl        => t_subtree_tbl);

    ELSE
       --
       -- check circularity
       --
       v_circularity_exists := circularity_Exists(p_model_id,p_target_model_id);
       IF v_circularity_exists=YES_FLAG AND p_ps_node_type=CONNECTOR_TYPE THEN

             filter_Branches(p_target_model_id    => p_target_model_id,
                             p_target_subtree_tbl => p_target_subtree_tbl,
                             x_subtree_tbl        => t_subtree_tbl);
       ELSE
           t_subtree_tbl:=p_target_subtree_tbl;
       END IF;

    END IF;

    g_hash_tree_tbl(t_subtree_tbl(p_target_root_expl_id).parent_id) := t_subtree_tbl;

    --
    -- first - attach the subtree to the current model ( <=> p_model_id )
    --
    attach_Subtree(p_model_id                => p_model_id,    -- specifies model to which we are attaching the subtree
                   p_new_root_expl_id        => t_subtree_tbl(p_target_root_expl_id).parent_id, -- expl_id of new subtree root
                   p_new_root_level          => t_subtree_tbl(p_target_root_expl_id).current_level, -- node_depth of new subtree root
                   p_subtree_root_expl_id    => p_target_root_expl_id, -- expl_id=index of subtree root in subtree array p_subtree_tbl
                   p_subtree_tbl             => t_subtree_tbl);         -- subtree array

    --
    -- if there are no any connected models then just exit
    --
    IF t_chain.COUNT=0 THEN
       --
       -- populate child_model_expl_id's
       --
       populate_Child_Model_Expl_id();
       RETURN;
    END IF;

    --
    -- initilaize hash map of models on the current level
    --
    t_models_level(p_model_id):=p_model_id;


    --
    -- initilaize hash map of already handled models
    --
    t_hash_models(p_model_id):=p_model_id;


    --
    -- loop through t_models_level array
    -- initially t_model_level contains just p_model_id ( source model )
    --
    LOOP
       --
       -- go through all connected models
       -- in order to find all models connected to the model with model_id = t_models_level(v_ind)
       -- Example :
       -- M3
       -- |--->M2
       --      |---->M1
       --            ^
       -- M10        |
       --  |----------
       --
       -- initially we have t_model_level(M1)=M1
       -- and t_chain ( model_id/parent_model_id ) = { M1/M2, M2/M3, M3/null }
       -- so in this algorithm we go through all t_chain elements and find
       -- those which are parent elements ( elementS because the same model can be referenced from the different models )
       -- if we start with M1 then
       --    next level will contain t_chain elements for which t_chain(i).parent_model_id = M1
       --    => it will contain M2 and M10
       --  t_new_models_level will be populated with {M2, M10}
       --  at the bottom of the loop we have t_models_level:=lt_new_models_level;
       -- so on next itteration we will be using t_models_level = { M2, M10}
       --
       FOR i IN t_chain.FIRST..t_chain.LAST
       LOOP
          v_ind:=t_models_level.FIRST;
          LOOP
             IF v_ind IS NULL THEN
                EXIT;
             END IF;

             --
             -- starting with the current model go up to the chain of connected
             -- models level by level
             --
             IF t_chain(i).parent_model_id=t_models_level(v_ind)              -- find all models connected to the current one
                AND t_chain(i).model_id <> t_chain(i).parent_model_id THEN    -- if it's circular connector
                                                                              -- case then we don't need to attach
                                                                              -- the target subtree again
                --
                -- if t_chain has a duplicates of model_ids then
                -- we don't need to apply algorithm second time
                -- one model must be handled only once
                --
                IF NOT(t_hash_models.EXISTS(t_chain(i).model_id)) THEN

                --
                -- t_connect_point_tbl stores already handled branches
                -- Example :
                -- M2
                --  |--Ref1--expl_id=1000---->M1
                --
                --  |--Ref2--expl_id=2000---->M1
                --
                -- and we want to attach the target subtree under M1
                -- in model M2 we have 2 entries that have component_id = p_parent_ps_id = M1
                -- these are references Ref1 and Ref2

                FOR m IN(SELECT model_ref_expl_id,component_id,ps_node_type,node_depth
                         FROM CZ_MODEL_REF_EXPLS
                         WHERE  model_id=t_chain(i).model_id AND component_id=p_parent_ps_id AND
                                parent_expl_node_id IS NOT NULL AND deleted_flag=NO_FLAG)
                LOOP

                   BEGIN
                       v_connector_parent_exists:=NO_FLAG;
                       SELECT YES_FLAG INTO v_connector_parent_exists FROM dual
                       WHERE EXISTS(SELECT NULL FROM CZ_MODEL_REF_EXPLS
                       WHERE ps_node_type=CONNECTOR_TYPE
                       START WITH model_ref_expl_id=m.model_ref_expl_id
                       CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND deleted_flag=NO_FLAG AND deleted_flag=NO_FLAG);
                   EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            NULL;
                   END;

                   --
                   -- t_connect_point_tbl - hash map that stores expl_ids of
                   -- already handled branches
                   -- so we need to attach subtree just in case when
                   -- this given branch is not handled yet
                   --
                   IF NOT(t_connect_point_tbl.EXISTS(m.model_ref_expl_id)) AND
                      NOT( p_ps_node_type=CONNECTOR_TYPE AND v_connector_parent_exists=YES_FLAG) THEN  -- not a connector's subtree under connector

                      IF v_circularity_exists = YES_FLAG THEN

                         IF p_ps_node_type=CONNECTOR_TYPE THEN

                            --
                            -- remove all expl subtrees under References/Connectors which
                            -- belong to model with model_id=t_chain(i).model_id
                            -- t_subtree_tbl will store OUTPUT subtree
                            --
                            filter_Branches(p_target_model_id    => p_target_model_id,
                                            p_target_subtree_tbl => p_target_subtree_tbl,
                                            x_subtree_tbl        => t_subtree_tbl);

                            --
                            -- attach subtree with removed expl subtrees under References/Connectors which
                            -- belong to model with model_id=t_chain(i).model_id
                            -- to expl_id = m.model_ref_expl_id
                            --
                            attach_Subtree(p_model_id             => t_chain(i).model_id,
                                           p_new_root_expl_id     => m.model_ref_expl_id,       -- expl_id of the next "attach point"
                                           p_new_root_level       => m.node_depth,              -- node_depth of the next "attach point"
                                           p_subtree_root_expl_id => p_target_root_expl_id,     -- expl_id=index of subtree array associated
                                                                                                -- with a root node
                                           p_subtree_tbl             => t_subtree_tbl);          -- subtree array
                           END IF;
                      ELSE

                         --
                         -- attach the target subtree to expl_id = m.model_ref_expl_id
                         -- here we don't need to change initial target subtree p_target_subtree_tbl
                         -- we need just attach it to an appropriate expl node
                         --
                         attach_Subtree(p_model_id             => t_chain(i).model_id,
                                        p_new_root_expl_id     => m.model_ref_expl_id,       -- expl_id of the next "attach point"
                                        p_new_root_level       => m.node_depth,              -- node_depth of the next "attach point"
                                        p_subtree_root_expl_id => p_target_root_expl_id,     -- expl_id=index of subtree array associated
                                                                                             -- with a root node
                                        p_subtree_tbl             => p_target_subtree_tbl);     -- subtree array

                      END IF;

                   END IF;
                   --
                   -- put expl_id of branch that we've just handled
                   --
                   t_connect_point_tbl(m.model_ref_expl_id):= t_chain(i).model_id;
                END LOOP; -- end of loop through CZ_MODEL_REF_EXPLS table --

                --
                -- put the current model = t_chain(i).model_id to the hash
                -- of models which already hadnled
                -- this hash is used in order to avoid attaching
                -- the subtree twice ( or more than twice )
                --
                t_hash_models(t_chain(i).model_id):= t_chain(i).model_id;

                --
                -- populate array of models for the next level
                -- models from the current level will be used as base level
                -- on the next itteration
                --
                t_new_models_level(t_chain(i).model_id):=t_chain(i).model_id;

                END IF; -- end of if NOT(t_hash_models.EXISTS(t_chain(i).model_id)) --

             END IF;     -- end of if t_chain(i).parent_model_id=t_models_level(v_ind)

             v_ind:=t_models_level.NEXT(v_ind);

          END LOOP; -- end of loop for t_models_level array

    END LOOP; -- end of loop for i in t_chain.First..t_chain.Last --

    --
    -- now we going to the next itteration
    -- so we need to set t_models_level to array of the models from the just handled level
    --
    t_models_level:=t_new_models_level; t_new_models_level.DELETE;

    --
    -- if there are no connected models to models on the current level then exit
    --
    IF (t_models_level.COUNT = 0) THEN
        EXIT;
    END IF;

END LOOP;

--
-- populate child_model_expl_id's
--
populate_Child_Model_Expl_id();

EXCEPTION
    WHEN OTHERS THEN
         LOG_REPORT('copy_Subtree','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
END Copy_Subtree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE add_Reference
(p_ps_node_id           IN  INTEGER,
 p_to_model_id          IN  INTEGER,               -- reference to p_to_model_id
 p_containing_model_id  IN  INTEGER,               -- current Model where reference is created
 p_virtual_flag         IN  VARCHAR2,
 p_out_err              OUT NOCOPY INTEGER,
 p_ps_type              IN  INTEGER DEFAULT NULL,
 p_expl_node_type       IN  INTEGER                -- DEFAULT MANDATORY_EXPL_TYPE
) IS

     t_subtree_tbl             ArrayId;                                    -- stores subtree array
     t_prev_level_expl_ids_tbl IntArray;                                   -- stores expl_ids of the target subtree
                                                                           -- which will be used as child_expl_ids on the next level
     v_parent_ps_node_id       CZ_PS_NODES.ps_node_id%TYPE;                -- ps_node_id of new subtree root node
     v_parent_expl_id          CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;  -- expl_id of new subtree root node
     v_parent_level            CZ_MODEL_REF_EXPLS.node_depth%TYPE;         -- node_depth of new subtree root node
     v_target_root_expl_id     CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;  -- root expl_id of the target model
     v_next_id                 CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;  -- stores expl_id generated by sequence

BEGIN
     Initialize;
     p_out_err:=0;

     --
     -- find node in Model Ref Expls which can be used as parent node
     -- for Subtree
     --
     get_Node_Up(p_ps_node_id,p_containing_model_id,
                 v_parent_ps_node_id,v_parent_expl_id,v_parent_level);

     --
     -- get the target subtree
     --
     get_Expl_Tree(p_target_model_id    => p_to_model_id,
                   px_root_expl_id      => v_target_root_expl_id,
                   p_target_subtree_tbl => t_subtree_tbl);

     --
     -- create array element associated with the Reference ( ps_node_id = p_ps_node_id) itself
     --
     t_subtree_tbl(v_target_root_expl_id).parent_id      := v_parent_expl_id;      -- <=> model_ref_expl_id of the node to attach subtree
     t_subtree_tbl(v_target_root_expl_id).ps_node_id     := p_ps_node_id;
     t_subtree_tbl(v_target_root_expl_id).ps_node_type   := p_ps_type;
     t_subtree_tbl(v_target_root_expl_id).virtual_flag   := p_virtual_flag;
     t_subtree_tbl(v_target_root_expl_id).current_level  := v_parent_level;      -- node_depth of the node to attach subtree plus 1
     t_subtree_tbl(v_target_root_expl_id).component_id   := p_to_model_id;         -- referenced model ( <=> target model )
     t_subtree_tbl(v_target_root_expl_id).child_model_id := v_target_root_expl_id; -- <=> model_ref_expl_id of the root node of target model
     t_subtree_tbl(v_target_root_expl_id).expl_node_type := p_expl_node_type;

     --
     -- attach Subtree to the containing model --
     -- here we assume that root node of subtree is already populated
     --
     copy_Subtree(p_model_id                => p_containing_model_id,
                  p_target_model_id         => p_to_model_id,
                  p_parent_ps_id            => v_parent_ps_node_id,
                  p_target_root_expl_id     => v_target_root_expl_id,
                  p_target_subtree_tbl      => t_subtree_tbl,
                  p_ps_node_type            => p_ps_type);

EXCEPTION
     WHEN OTHERS THEN
          p_out_err:=m_RUN_ID;
          LOG_REPORT('add_Reference',
          'Error : ps_node_id='||TO_CHAR(p_ps_node_id)||' < '||ERROR_CODE||' > :'||SQLERRM);
END add_Reference;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE add_Ref
(p_ps_node_id           IN  INTEGER,
 p_to_model_id          IN  INTEGER,
 p_containing_model_id  IN  INTEGER) IS

    v_out_err       INTEGER;

BEGIN
    add_Reference(p_ps_node_id,p_to_model_id, p_containing_model_id,
                  NO_FLAG,v_out_err,REFERENCE_TYPE, MANDATORY_EXPL_TYPE);
END;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE add_Connector
(p_ps_node_id           IN  INTEGER,
 p_to_model_id          IN  INTEGER,
 p_containing_model_id  IN  INTEGER) IS

    v_out_err       INTEGER;

BEGIN
    add_Reference(p_ps_node_id,p_to_model_id, p_containing_model_id,
                  NO_FLAG,v_out_err,CONNECTOR_TYPE, MANDATORY_EXPL_TYPE);

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_Expl_Id
(p_ps_node_id     IN     INTEGER,
 p_project_id     IN     INTEGER,
 p_out_expl_id    IN OUT NOCOPY INTEGER,
 p_out_level      IN OUT NOCOPY INTEGER,
 p_ps_node_type   IN      INTEGER DEFAULT NULL ) IS

     ret INTEGER:=NULL_VALUE;

BEGIN
     p_out_expl_id:=NULL_VALUE;
     p_out_level:=NULL_VALUE;


     IF p_ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) THEN
        FOR i IN (SELECT model_ref_expl_id,node_depth FROM CZ_MODEL_REF_EXPLS
                  WHERE model_id=p_project_id AND referring_node_id=p_ps_node_id
                  AND child_model_expl_id IS NULL AND deleted_flag=NO_FLAG)
        LOOP
           p_out_expl_id:=i.model_ref_expl_id;
           p_out_level:=i.node_depth;
        END LOOP;
     ELSE
        FOR i IN (SELECT model_ref_expl_id,node_depth FROM CZ_MODEL_REF_EXPLS
                  WHERE model_id=p_project_id AND referring_node_id IS NULL
                  AND component_id=p_ps_node_id AND child_model_expl_id IS NULL AND
                  deleted_flag=NO_FLAG)
        LOOP
           p_out_expl_id:=i.model_ref_expl_id;
           p_out_level:=i.node_depth;
        END LOOP;
     END IF;

EXCEPTION
     WHEN OTHERS THEN
         LOG_REPORT('get_Expl_Id','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_Node_Up
(p_ps_node_id     IN     INTEGER,
 p_project_id     IN     INTEGER,
 p_out_ps_node_id IN OUT NOCOPY INTEGER,
 p_out_expl_id    IN OUT NOCOPY INTEGER,
 p_out_level      IN OUT NOCOPY INTEGER) IS

     v_expl_id    INTEGER;
     v_temp       INTEGER;

BEGIN
     p_out_ps_node_id:=NULL_VALUE;
     p_out_expl_id:=NULL_VALUE;
     p_out_level:=NULL_VALUE;

     FOR i IN (SELECT ps_node_id,ps_node_type,parent_id FROM CZ_PS_NODES
               WHERE ps_node_id=p_ps_node_id AND deleted_flag=NO_FLAG)
     LOOP
        get_Expl_Id(i.ps_node_id,p_project_id,v_expl_id,p_out_level,i.ps_node_type);

        IF v_expl_id<>NULL_VALUE THEN
           p_out_ps_node_id:=i.ps_node_id;
           p_out_expl_id:=v_expl_id;
           EXIT;
        END IF;

        IF i.ps_node_id<>p_project_id AND v_expl_id=NULL_VALUE THEN
           get_Node_Up(i.parent_id,p_project_id,p_out_ps_node_id,
                       p_out_expl_id,p_out_level);
        ELSE
           p_out_ps_node_id:=p_project_id;
        END IF;
     END LOOP;

EXCEPTION
     WHEN OTHERS THEN
         LOG_REPORT('get_Node_Up','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_Node_Down
(p_ps_node_id     IN     INTEGER,
 p_project_id     IN     INTEGER,
 p_out_ps_node_id IN OUT NOCOPY INTEGER,
 p_out_expl_id    IN OUT NOCOPY INTEGER,
 p_out_level      IN OUT NOCOPY INTEGER) IS

    v_expl_id    CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    NODE_FOUND     EXCEPTION;

BEGIN
     p_out_ps_node_id:=NULL_VALUE;
     p_out_expl_id:=NULL_VALUE;
     p_out_level:=NULL_VALUE;
     get_Expl_Id(p_ps_node_id,p_project_id,v_expl_id,p_out_level);
     IF v_expl_id<>NULL_VALUE THEN
        p_out_ps_node_id:=p_ps_node_id;
        p_out_expl_id:=v_expl_id;
        RAISE NODE_FOUND;
     END IF;

     FOR i IN (SELECT ps_node_id,parent_id FROM CZ_PS_NODES
               WHERE parent_id=p_ps_node_id AND deleted_flag=NO_FLAG)
     LOOP
        get_Expl_Id(i.ps_node_id,p_project_id,v_expl_id,p_out_level);

        IF v_expl_id<>NULL_VALUE THEN
           p_out_ps_node_id:=i.ps_node_id;
           p_out_expl_id:=v_expl_id;
           EXIT;
        END IF;

        IF v_expl_id=NULL_VALUE THEN
           get_Node_Down(i.ps_node_id,p_project_id,p_out_ps_node_id,
                         p_out_expl_id,p_out_level);
        ELSE
           p_out_ps_node_id:=NULL_VALUE;
        END IF;
     END LOOP;

EXCEPTION
     WHEN NODE_FOUND THEN
          NULL;
     WHEN OTHERS THEN
         LOG_REPORT('get_Node_Down','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION get_Next_ExplId
(p_expl_id       IN INTEGER,
 p_child_expl_id IN INTEGER,
 p_mode          IN VARCHAR2 -- default PLUS_MODE
)
RETURN INTEGER IS

    v_ref_id INTEGER;

BEGIN

    IF p_mode=PLUS_MODE THEN

     --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=300;

       SELECT model_ref_expl_id INTO v_ref_id FROM CZ_MODEL_REF_EXPLS
       WHERE parent_expl_node_id=p_expl_id
       AND (child_model_expl_id=p_child_expl_id OR model_ref_expl_id=p_child_expl_id)
       AND deleted_flag=NO_FLAG;

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=301;

    ELSE
       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=302;

       SELECT parent_expl_node_id INTO v_ref_id FROM CZ_MODEL_REF_EXPLS
       WHERE model_ref_expl_id=p_expl_id;

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=303;

    END IF;

    RETURN v_ref_id;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_Expls
(p_project_id      IN INTEGER,
 p_ps_node_id      IN INTEGER,
 p_mode            IN VARCHAR2, -- DEFAULT PLUS_MODE
 p_deleted_expl_id IN INTEGER DEFAULT NULL) IS

    v_model_ref_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE ;
    v_project_id   CZ_MODEL_REF_EXPLS.model_id%TYPE;
    v_ref_id       CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;

BEGIN

    IF p_mode=PLUS_MODE THEN

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=400;

       SELECT model_ref_expl_id INTO v_model_ref_id FROM
       CZ_MODEL_REF_EXPLS WHERE model_id=p_project_id
       AND component_id=p_ps_node_id AND child_model_expl_id IS NULL AND deleted_flag=NO_FLAG;

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=401;

    END IF;
    IF p_mode=MINUS_MODE THEN
       v_model_ref_id:=p_deleted_expl_id;
    END IF;

    FOR i IN (SELECT ps_node_id,ps_node_type,NAME FROM CZ_PS_NODES
              START WITH devl_project_id=p_project_id AND deleted_flag=NO_FLAG AND ps_node_id=p_ps_node_id
              CONNECT BY PRIOR ps_node_id=parent_id AND NVL(virtual_flag,'1')='1' AND deleted_flag=NO_FLAG
              AND PRIOR deleted_flag=NO_FLAG)
    LOOP

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=402;

        FOR m IN(SELECT expr_node_id,rule_id,model_ref_expl_id FROM CZ_EXPRESSION_NODES
                 WHERE ps_node_id=i.ps_node_id AND deleted_flag=NO_FLAG)
        LOOP
           BEGIN

               --
               -- DEBUG ERROR CODE --
               --
               ERROR_CODE:=403;

               v_ref_id:=get_Next_ExplId(m.model_ref_expl_id,v_model_ref_id,p_mode);

               --
               -- DEBUG ERROR CODE --
               --
               ERROR_CODE:=404;

               UPDATE CZ_EXPRESSION_NODES
               SET model_ref_expl_id=v_ref_id
               WHERE expr_node_id=m.expr_node_id AND rule_id=m.rule_id;

               --
               -- DEBUG ERROR CODE --
               --
               ERROR_CODE:=405;

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    NULL;
               WHEN OTHERS THEN
                    LOG_REPORT('set_Expls','CZ_EXPRESSION_NODES ERROR CODE :'||
                    ERROR_CODE||' : '||SQLERRM);
           END;
    END LOOP;

    IF i.ps_node_type IN(PRODUCT_TYPE,COMPONENT_TYPE) THEN

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=406;

       FOR m IN(SELECT func_comp_id,component_id,model_ref_expl_id FROM CZ_FUNC_COMP_SPECS
                WHERE component_id=i.ps_node_id AND deleted_flag=NO_FLAG)
       LOOP
          BEGIN

              --
              -- DEBUG ERROR CODE --
              --
              ERROR_CODE:=407;

              v_ref_id:=get_Next_ExplId(m.model_ref_expl_id,v_model_ref_id,p_mode);

              --
              -- DEBUG ERROR CODE --
              --
              ERROR_CODE:=408;

              UPDATE CZ_FUNC_COMP_SPECS
              SET model_ref_expl_id=v_ref_id
              WHERE func_comp_id=m.func_comp_id AND component_id=m.component_id;

              --
              -- DEBUG ERROR CODE --
              --
              ERROR_CODE:=409;

          EXCEPTION
              WHEN OTHERS THEN
                   LOG_REPORT('set_Expls','CZ_FUNC_COMP_SPECS : func_comp_id='||TO_CHAR(m.func_comp_id));
          END;

       END LOOP;

    END  IF;


    IF i.ps_node_type IN(FEATURE_TYPE) THEN

      --
      -- DEBUG ERROR CODE --
      --
      ERROR_CODE:=410;

      FOR m IN(SELECT rule_id,feature_id,model_ref_expl_id FROM CZ_COMBO_FEATURES
               WHERE feature_id=i.ps_node_id AND deleted_flag=NO_FLAG)
      LOOP
         BEGIN

         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=411;

         v_ref_id:=get_Next_ExplId(m.model_ref_expl_id,v_model_ref_id,p_mode);

         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=412;

         UPDATE CZ_COMBO_FEATURES
         SET model_ref_expl_id=v_ref_id
         WHERE rule_id=m.rule_id AND feature_id=m.feature_id;

         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=413;


         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              LOG_REPORT('set_Expls','CZ_COMBO_FEATURES : feature_id='||TO_CHAR(m.feature_id)||' rule_id='||TO_CHAR(m.rule_id));
         WHEN OTHERS THEN
              LOG_REPORT('set_Expls','CZ_COMBO_FEATURES : feature_id='||TO_CHAR(m.feature_id)||' rule_id='||TO_CHAR(m.rule_id));
         END;

      END LOOP;

      --
      -- DEBUG ERROR CODE --
      --
      ERROR_CODE:=414;

      FOR m IN(SELECT rule_id,feature_id,model_ref_expl_id FROM CZ_DES_CHART_FEATURES
               WHERE feature_id=i.ps_node_id AND deleted_flag=NO_FLAG)
      LOOP
         BEGIN

         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=415;

         v_ref_id:=get_Next_ExplId(m.model_ref_expl_id,v_model_ref_id,p_mode);

         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=416;

         UPDATE CZ_DES_CHART_FEATURES
         SET model_ref_expl_id=v_ref_id
         WHERE rule_id=m.rule_id AND feature_id=m.feature_id;

         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=417;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              LOG_REPORT('set_Expls','CZ_DES_CHART_FEATURES : feature_id='||TO_CHAR(m.feature_id)||' rule_id='||TO_CHAR(m.rule_id));
         WHEN OTHERS THEN
              LOG_REPORT('set_Expls','CZ_DES_CHART_FEATURES : feature_id='||TO_CHAR(m.feature_id)||' rule_id='||TO_CHAR(m.rule_id));
         END;
      END LOOP;

      FOR m IN(SELECT rule_id,primary_opt_id,secondary_opt_id,secondary_feature_id,
               secondary_feat_expl_id FROM CZ_DES_CHART_CELLS
               WHERE secondary_feature_id=i.ps_node_id AND deleted_flag=NO_FLAG)
      LOOP
         BEGIN
         v_ref_id:=get_Next_ExplId(m.secondary_feat_expl_id,v_model_ref_id,p_mode);
         UPDATE CZ_DES_CHART_CELLS
         SET secondary_feat_expl_id=v_ref_id
         WHERE rule_id=m.rule_id AND secondary_feature_id=m.secondary_feature_id AND
         primary_opt_id=m.primary_opt_id AND secondary_opt_id=m.secondary_opt_id;

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
              LOG_REPORT('set_Expls','CZ_DES_CHART_CELLS : secondary_feature_id='||TO_CHAR(m.secondary_feature_id)||' rule_id='||TO_CHAR(m.rule_id));
         WHEN OTHERS THEN
              LOG_REPORT('set_Expls','CZ_DES_CHART_CELLS : secondary_feature_id='||TO_CHAR(m.secondary_feature_id)||' rule_id='||TO_CHAR(m.rule_id));
         END;

      END LOOP;

    END IF;

    IF i.ps_node_type=OPTION_TYPE THEN
       FOR m IN(SELECT rule_id,option_id,model_ref_expl_id FROM CZ_DES_CHART_COLUMNS
                WHERE option_id=i.ps_node_id)
       LOOP
          BEGIN
          v_ref_id:=get_Next_ExplId(m.model_ref_expl_id,v_model_ref_id,p_mode);

          UPDATE CZ_DES_CHART_COLUMNS
          SET model_ref_expl_id=v_ref_id
          WHERE rule_id=m.rule_id AND option_id=m.option_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               LOG_REPORT('set_Expls','CZ_DES_CHART_COLUMNS : option_id='||TO_CHAR(m.option_id)||' rule_id='||TO_CHAR(m.rule_id));
          WHEN OTHERS THEN
               LOG_REPORT('set_Expls','CZ_DES_CHART_COLUMNS : option_id='||TO_CHAR(m.option_id)||' rule_id='||TO_CHAR(m.rule_id));
          END;
       END LOOP;
    END IF;

END LOOP;

EXCEPTION
    WHEN OTHERS THEN
         LOG_REPORT('set_Expls','ERROR CODE : '||TO_CHAR(ERROR_CODE)||' ERROR MESSAGE : '||SQLERRM);
END set_Expls;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE refresh_UI_Expl_Ids(p_ps_node_id   IN NUMBER,
                              p_component_id IN NUMBER,
                              p_model_id     IN NUMBER,
                              p_old_expl_id  IN NUMBER,
                              p_new_expl_id  IN NUMBER) IS

  t_persistent_node_id_tbl IntArray;

  PROCEDURE refresh_It_For_Single_UI(p_current_ui_def_id IN NUMBER) IS
  BEGIN

    FOR k IN t_persistent_node_id_tbl.First..t_persistent_node_id_tbl.Last
    LOOP
      UPDATE CZ_UI_PAGE_ELEMENTS
         SET model_ref_expl_id=p_new_expl_id
       WHERE ui_def_id=p_current_ui_def_id AND
             persistent_node_id=t_persistent_node_id_tbl(k) AND
             model_ref_expl_id=p_old_expl_id AND
             deleted_flag='0';

      UPDATE CZ_UI_PAGES
         SET pagebase_expl_node_id=p_new_expl_id
       WHERE ui_def_id=p_current_ui_def_id AND
             persistent_node_id=t_persistent_node_id_tbl(k) AND
             pagebase_expl_node_id=p_old_expl_id AND
             deleted_flag='0';

      UPDATE CZ_UI_PAGE_REFS
         SET target_expl_node_id=p_new_expl_id
       WHERE ui_def_id=p_current_ui_def_id AND
             target_persistent_node_id=t_persistent_node_id_tbl(k) AND
             target_expl_node_id=p_old_expl_id AND
             deleted_flag='0';

      UPDATE CZ_UI_PAGE_SETS
         SET pagebase_expl_node_id=p_new_expl_id
       WHERE ui_def_id=p_current_ui_def_id AND
             persistent_node_id=t_persistent_node_id_tbl(k) AND
             pagebase_expl_node_id=p_old_expl_id AND
             deleted_flag='0';

      UPDATE CZ_UI_ACTIONS
         SET target_expl_node_id=p_new_expl_id
       WHERE ui_def_id=p_current_ui_def_id AND
             target_persistent_node_id=t_persistent_node_id_tbl(k) AND
             target_expl_node_id=p_old_expl_id AND
             deleted_flag='0';

     END LOOP;

  END refresh_It_For_Single_UI;

  PROCEDURE refresh_It_For_Single_Model(p_current_model_id IN NUMBER) IS
  BEGIN
    FOR i IN (SELECT ui_def_id FROM CZ_UI_DEFS
              WHERE devl_project_id=p_current_model_id AND
                    ui_style='7' AND deleted_flag='0')
    LOOP
      refresh_It_For_Single_UI(i.ui_def_id);
    END LOOP;
  END refresh_It_For_Single_Model;

BEGIN

  SELECT persistent_node_id
  BULK COLLECT INTO t_persistent_node_id_tbl
  FROM CZ_PS_NODES
  START WITH ps_node_id=p_ps_node_id AND deleted_flag='0' AND
   (reference_id IS NULL AND component_id=p_component_id)
  CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag='0' AND
  PRIOR deleted_flag='0' AND (reference_id IS NULL AND component_id=p_component_id);

  refresh_It_For_Single_Model(p_model_id);

  IF t_chain.COUNT>0 THEN
    FOR i IN t_chain.First..t_chain.Last
    LOOP
      refresh_It_For_Single_Model(t_chain(i).model_id);
    END LOOP;
  END IF;

END refresh_UI_Expl_Ids;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_it
(p_expl_id       IN  INTEGER,
 p_del_logically IN  VARCHAR2  -- DEFAULT YES_FLAG
) IS

BEGIN
    IF p_del_logically=YES_FLAG THEN

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=500;

       UPDATE CZ_MODEL_REF_EXPLS SET deleted_flag=YES_FLAG WHERE model_ref_expl_id IN
       (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
        START WITH model_ref_expl_id=p_expl_id AND deleted_flag=NO_FLAG
        CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG);

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=501;

    ELSE
       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=502;

       DELETE FROM CZ_MODEL_REF_EXPLS WHERE model_ref_expl_id IN
       (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
        START WITH model_ref_expl_id=p_expl_id AND deleted_flag=NO_FLAG
        CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG);

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=503;

    END IF;
END;


PROCEDURE delete_Node_
(p_ps_node_id    IN  INTEGER,
 p_ps_node_type  IN  INTEGER,
 p_del_logically IN  VARCHAR2 -- DEFAULT '1'
) IS

    PROCEDURE delete_it_
    (p_expl_id       IN  INTEGER,
     p_del_logically IN  VARCHAR2, -- DEFAULT YES_FLAG
     p_ps_node_type  IN  INTEGER DEFAULT NULL) IS

    BEGIN
        IF p_del_logically=YES_FLAG THEN
           UPDATE CZ_MODEL_REF_EXPLS SET deleted_flag=YES_FLAG
           WHERE model_ref_expl_id=p_expl_id;
        ELSE
           DELETE FROM CZ_MODEL_REF_EXPLS WHERE model_ref_expl_id=p_expl_id;
        END IF;

        IF p_ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) THEN
           IF p_del_logically=YES_FLAG THEN
              UPDATE CZ_MODEL_REF_EXPLS SET deleted_flag=YES_FLAG
              WHERE deleted_flag=NO_FLAG AND  model_ref_expl_id IN
              (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
               START WITH model_ref_expl_id=p_expl_id AND deleted_flag=NO_FLAG
               CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND
              PRIOR deleted_flag=NO_FLAG);
           ELSE
              DELETE FROM CZ_MODEL_REF_EXPLS
              WHERE model_ref_expl_id IN
              (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
               START WITH model_ref_expl_id=p_expl_id AND deleted_flag=NO_FLAG
               CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG);
           END IF;
        END IF;
    END delete_it_;

BEGIN
    IF  p_ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) THEN
        FOR i IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                  WHERE referring_node_id=p_ps_node_id  AND deleted_flag=NO_FLAG)
        LOOP
            delete_it_(i.model_ref_expl_id, YES_FLAG);
        END LOOP;
    ELSE
        FOR i IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                  WHERE component_id=p_ps_node_id AND deleted_flag=NO_FLAG)
        LOOP
           delete_it_(i.model_ref_expl_id, YES_FLAG);
        END LOOP;
    END IF;
END delete_Node_;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

FUNCTION containsBOM(p_model_id IN INTEGER,p_instanciable OUT NOCOPY INTEGER) RETURN NUMBER IS

    v_exist_bom_nodes VARCHAR2(1);
    v_ret             NUMBER:=NULL_VALUE;

BEGIN
    p_instanciable:=0;

    FOR i IN(SELECT model_ref_expl_id,referring_node_id,component_id,expl_node_type FROM CZ_MODEL_REF_EXPLS
             START WITH model_id=p_model_id AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG
             CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND
                              deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG
                              AND ps_node_type IN(BOM_MODEL_TYPE,COMPONENT_TYPE,REFERENCE_TYPE)
                              AND PRIOR ps_node_type IN(BOM_MODEL_TYPE,COMPONENT_TYPE,REFERENCE_TYPE))
    LOOP
       BEGIN
           SELECT '1' INTO v_exist_bom_nodes
           FROM dual WHERE
           EXISTS(SELECT NULL FROM CZ_PS_NODES WHERE devl_project_id=i.component_id
           AND ps_node_type=436 AND deleted_flag=NO_FLAG);

           IF i.referring_node_id IS NOT NULL THEN
              v_ret:=i.referring_node_id;
           ELSE
              v_ret:=i.component_id;
           END IF;
           IF i.expl_node_type=MINMAX_EXPL_TYPE THEN
              p_instanciable:=1;
              RETURN v_ret;
           END IF;
       EXCEPTION
          WHEN OTHERS THEN
               NULL;
       END;
    END LOOP;
    RETURN v_ret;
END containsBOM;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE get_from_Node_Up
(p_ps_node_id     IN     INTEGER,
 p_project_id     IN     INTEGER,
 p_out_ps_node_id IN OUT NOCOPY INTEGER,
 p_out_expl_id    IN OUT NOCOPY INTEGER,
 p_out_level      IN OUT NOCOPY INTEGER) IS

    v_expl_id    CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE:=NULL_VALUE;
    v_parent_id  CZ_PS_NODES.parent_id%TYPE:=NULL_VALUE;

BEGIN

    p_out_ps_node_id:=NULL_VALUE;
    p_out_expl_id:=NULL_VALUE;
    p_out_level:=NULL_VALUE;

    BEGIN
        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=1001;

        SELECT parent_id INTO v_parent_id
        FROM CZ_PS_NODES WHERE ps_node_id=p_ps_node_id;

        IF v_parent_id IS NULL THEN
           p_out_ps_node_id:=p_ps_node_id;
           --
           -- DEBUG ERROR CODE --
           --
           ERROR_CODE:=1002;

           SELECT model_ref_expl_id,node_depth
           INTO p_out_expl_id,p_out_level
           FROM CZ_MODEL_REF_EXPLS WHERE model_id=p_ps_node_id
           AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;

           RETURN;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
             LOG_REPORT('get_from_Node_Up','ERROR CODE : '||TO_CHAR(ERROR_CODE)||' ERROR MESSAGE : '||SQLERRM);
    END;

    FOR i IN (SELECT ps_node_id,parent_id,virtual_flag FROM CZ_PS_NODES
              WHERE ps_node_id=v_parent_id AND deleted_flag=NO_FLAG)
    LOOP

       IF i.virtual_flag=NO_FLAG OR i.parent_id IS NULL THEN
          p_out_ps_node_id:=i.ps_node_id;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=700;

          SELECT model_ref_expl_id,node_depth
          INTO p_out_expl_id,p_out_level
          FROM CZ_MODEL_REF_EXPLS WHERE model_id=p_project_id
          AND component_id=i.ps_node_id AND deleted_flag=NO_FLAG;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=708;

          EXIT;
       ELSE
          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=709;

          get_from_Node_Up(i.ps_node_id,p_project_id,p_out_ps_node_id,p_out_expl_id,p_out_level);

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=710;

       END IF;
END LOOP;

EXCEPTION
    WHEN OTHERS THEN
         LOG_REPORT('get_from_Node_Up','ERROR CODE : '||TO_CHAR(ERROR_CODE)||' ERROR MESSAGE : '||SQLERRM);
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE update_Rules(p_ps_node_id IN INTEGER) IS

    v_old_expl_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_new_expl_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;

BEGIN
    FOR i IN t_old_expl_ids.FIRST..t_old_expl_ids.LAST
    LOOP
       v_old_expl_id:=t_old_expl_ids(i);
       v_new_expl_id:=t_new_expl_ids(i);

       IF v_old_expl_id IS NOT NULL AND  v_new_expl_id IS NOT NULL THEN
          FOR n IN(SELECT ps_node_id FROM CZ_PS_NODES
                   START WITH ps_node_id=p_ps_node_id AND deleted_flag=NO_FLAG
                   CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
          LOOP
             UPDATE CZ_EXPRESSION_NODES SET model_ref_expl_id=v_new_expl_id
             WHERE model_ref_expl_id=v_old_expl_id AND deleted_flag=NO_FLAG
             AND ps_node_id=n.ps_node_id;

             UPDATE CZ_COMBO_FEATURES
             SET model_ref_expl_id=v_new_expl_id
             WHERE model_ref_expl_id=v_old_expl_id AND deleted_flag=NO_FLAG
             AND feature_id=n.ps_node_id;

             UPDATE CZ_DES_CHART_FEATURES
             SET model_ref_expl_id=v_new_expl_id
             WHERE model_ref_expl_id=v_old_expl_id AND deleted_flag=NO_FLAG
             AND feature_id=n.ps_node_id;

             UPDATE CZ_DES_CHART_CELLS
             SET secondary_feat_expl_id=v_new_expl_id
             WHERE secondary_feat_expl_id=v_old_expl_id AND deleted_flag=NO_FLAG
             AND (secondary_feature_id=n.ps_node_id OR
             primary_opt_id=n.ps_node_id OR secondary_opt_id=n.ps_node_id);

             UPDATE CZ_FUNC_COMP_SPECS
             SET model_ref_expl_id=v_new_expl_id
             WHERE model_ref_expl_id=v_old_expl_id AND deleted_flag=NO_FLAG AND
             component_id=n.ps_node_id;

             UPDATE CZ_DES_CHART_COLUMNS
             SET model_ref_expl_id=v_new_expl_id
             WHERE model_ref_expl_id=v_old_expl_id AND
             option_id=n.ps_node_id;
         END LOOP;
       END IF;
    END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE populate_tree
(p_parent_ref_expl_id IN INTEGER, -- model_ref_expl_id of parent node
 p_model_ref_expl_id  IN INTEGER, -- model_ref_expl_id of current node
 p_ps_node_id         IN INTEGER, -- ps_node_id of current node
 p_ps_node_type       IN INTEGER, -- ps_node_type of current node
 p_expl_node_type     IN INTEGER, -- expl_node_type of current node
 p_model_id           IN INTEGER, -- model_id of current model
 p_child_array        IN IntArray -- array of direct childs ( in PS tree )
 ) IS

    t_child_nodes     IntArray;
    v_expl_id         CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_model_id        CZ_MODEL_REF_EXPLS.model_id%TYPE;
    v_ps_node_id      CZ_PS_NODES.ps_node_id%TYPE;

BEGIN
    IF t_chain.COUNT=0 THEN
       RETURN;
    END IF;
    FOR i IN t_chain.FIRST..t_chain.LAST
    LOOP
       IF t_chain(i).parent_model_id=p_model_id THEN
          v_model_id:=t_chain(i).model_id;

          FOR l IN(SELECT model_ref_expl_id,node_depth
                   FROM CZ_MODEL_REF_EXPLS
                   WHERE model_id=t_chain(i).model_id AND
                   child_model_expl_id=p_parent_ref_expl_id
                   AND deleted_flag=NO_FLAG)
          LOOP

             --
             -- generate the next PK for CZ_MODEL_REF_EXPLS table
             --
             v_expl_id:=allocate_Expl_Id;

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=800;

             INSERT INTO CZ_MODEL_REF_EXPLS
                    (model_ref_expl_id,
                     parent_expl_node_id,
                     referring_node_id,
                     model_id,
                     component_id,
                     ps_node_type,
                     virtual_flag,
                     node_depth,
                     expl_node_type,
                     child_model_expl_id,
                     deleted_flag)
             VALUES
                    (v_expl_id,
                     l.model_ref_expl_id,
                     NULL,
                     v_model_id,
                     p_ps_node_id,
                     p_ps_node_type,
                     NO_FLAG,
                     l.node_depth+1,
                     p_expl_node_type,
                     p_model_ref_expl_id,
                     NO_FLAG);

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=801;

             --
             -- reset childs nodes
             --
             IF p_child_array.COUNT>0 THEN
             FOR t IN p_child_array.FIRST..p_child_array.LAST
                 LOOP
                    t_child_nodes.DELETE;
                    v_ps_node_id:=p_child_array(t);

                    --
                    -- DEBUG ERROR CODE --
                    --
                    ERROR_CODE:=802;

                    UPDATE CZ_MODEL_REF_EXPLS
                    SET parent_expl_node_id=v_expl_id
                    WHERE parent_expl_node_id=l.model_ref_expl_id
                    AND model_id=v_model_id AND
                    ((ps_node_type IN(PRODUCT_TYPE,COMPONENT_TYPE,BOM_MODEL_TYPE) AND component_id=v_ps_node_id)
                    OR (ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND referring_node_id=v_ps_node_id))
                    AND deleted_flag=NO_FLAG
                    RETURNING model_ref_expl_id BULK COLLECT INTO t_child_nodes ;

                    --
                    -- DEBUG ERROR CODE --
                    --
                    ERROR_CODE:=803;

                    IF t_child_nodes.COUNT>0 THEN

                       --
                       -- DEBUG ERROR CODE --
                       --
                       ERROR_CODE:=804;

                       FORALL h IN t_child_nodes.FIRST..t_child_nodes.LAST
                              UPDATE CZ_MODEL_REF_EXPLS
                              SET node_depth=node_depth+1
                              WHERE model_ref_expl_id IN
                              (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                               START WITH model_ref_expl_id=t_child_nodes(h) AND deleted_flag=NO_FLAG
                               CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
                               AND PRIOR deleted_flag=NO_FLAG);

                              --
                              -- DEBUG ERROR CODE --
                              --
                              ERROR_CODE:=805;

                    END IF;
                 END LOOP;
             END IF;

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=806;

             populate_tree
             (l.model_ref_expl_id,v_expl_id,p_ps_node_id,
              p_ps_node_type,p_expl_node_type,v_model_id,p_child_array);

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=807;

          END LOOP;

       END IF;
    END LOOP;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=809;

END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE populate_expl_tree_internal(
 p_parent_model_ref_expl_id          IN NUMBER,
 p_model_ref_expl_id          IN NUMBER,
 p_model_id        IN NUMBER
) IS
v_expl_id    NUMBER;
v_model_id   NUMBER;
BEGIN

 IF t_chain.COUNT=0 THEN
       RETURN;
    END IF;
    FOR i IN t_chain.FIRST..t_chain.LAST
    LOOP
       IF t_chain(i).parent_model_id=p_model_id THEN
          v_model_id:=t_chain(i).model_id;

          FOR l IN(SELECT model_ref_expl_id,node_depth
                   FROM CZ_MODEL_REF_EXPLS
                   WHERE model_id=t_chain(i).model_id AND
                   child_model_expl_id=p_parent_model_ref_expl_id
                   AND deleted_flag=NO_FLAG)
          LOOP

              FOR m IN(SELECT *
                   FROM CZ_MODEL_REF_EXPLS
                   WHERE model_ref_expl_id = p_model_ref_expl_id
                   AND deleted_flag=NO_FLAG)
              LOOP
             --
             -- generate the next PK for CZ_MODEL_REF_EXPLS table
             --
             v_expl_id:=allocate_Expl_Id;

               INSERT INTO CZ_MODEL_REF_EXPLS
                      (model_ref_expl_id,
                       parent_expl_node_id,
                       referring_node_id,
                       model_id,
                       component_id,
                       ps_node_type,
                       virtual_flag,
                       node_depth,
                       expl_node_type,
                       child_model_expl_id,
                       deleted_flag)
               VALUES
                      (v_expl_id,
                       l.model_ref_expl_id,
                       m.referring_node_id,
                       v_model_id,
                       m.component_id,
                       m.ps_node_type,
                       m.virtual_flag,
                       l.node_depth+1,
                       m.expl_node_type,
                       p_model_ref_expl_id,
                       NO_FLAG);
              END LOOP;

        populate_expl_tree_internal(l.model_ref_expl_id,v_expl_id,v_model_id);
        END LOOP;
        END IF;
    END LOOP;
END populate_expl_tree_internal;
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
PROCEDURE populate_parent_expl_tree_(
 p_model_id        IN NUMBER,
 p_model_ref_expl_id          IN NUMBER,
 p_parent_model_ref_expl_id          IN NUMBER
) IS
BEGIN

      populate_expl_tree_internal(p_parent_model_ref_expl_id,p_model_ref_expl_id,p_model_id);

      FOR i IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS WHERE parent_expl_node_id = p_model_ref_expl_id AND deleted_flag  = NO_FLAG)
      LOOP
             populate_parent_expl_tree_(p_model_id => p_model_id, p_model_ref_expl_id => i.model_ref_expl_id, p_parent_model_ref_expl_id => p_model_ref_expl_id);
      END LOOP;


END populate_parent_expl_tree_;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
--
-- vsingava bug7831246 02th Mar '09
-- procedure which populates the set of explosions p_ps_node_id of p_model_id
-- to all model referencing it, up the entire model heirarchy. Usually called when a node
-- in structure is being copied
--
PROCEDURE populate_parent_expl_tree(
 p_ps_node_id          IN  NUMBER,  -- ps_node_id of the copied node
 p_model_id        IN NUMBER
) IS


    l_model_id            NUMBER;
    l_component_id        NUMBER;
    l_reference_id        NUMBER;
    l_expl_id             NUMBER;
    l_parent_id           NUMBER;
    v_up_id               INTEGER;
    v_up_expl_id          INTEGER;
    v_up_level            INTEGER;
    l_virtual_flag        VARCHAR2(1);
    l_curr_node_depth      NUMBER;
    l_min_node_depth       NUMBER;
    l_ps_node_type         NUMBER;

BEGIN

    -- get the info from the node to be copied
    SELECT devl_project_id,parent_id,reference_id,component_id,virtual_flag, ps_node_type
    INTO l_model_id,l_parent_id,l_reference_id,l_component_id,l_virtual_flag, l_ps_node_type
    FROM CZ_PS_NODES
    WHERE ps_node_id=p_ps_node_id AND deleted_flag = NO_FLAG;

        -- if not a reference node, get the model_refexpl_id record in model ref expls
    IF l_reference_id IS NULL THEN
       SELECT model_ref_expl_id, node_depth INTO l_expl_id, l_curr_node_depth
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=l_model_id AND component_id=l_component_id AND
       child_model_expl_id IS NULL AND deleted_flag = NO_FLAG;
    ELSE
       SELECT MIN(node_depth) INTO l_min_node_depth
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=l_model_id AND referring_node_id=p_ps_node_id
             AND deleted_flag = NO_FLAG;

       SELECT model_ref_expl_id, node_depth INTO l_expl_id, l_curr_node_depth
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=l_model_id AND referring_node_id=p_ps_node_id AND
       node_depth=l_min_node_depth AND deleted_flag = NO_FLAG;
    END IF;

     t_chain.DELETE;t_projectCache.DELETE;
     populate_chain(p_model_id);

       --
       -- find nearest non-virtual node above the target node --
       --
       get_Node_Up(p_ps_node_id,p_model_id,v_up_id,
                   v_up_expl_id,v_up_level);

       IF v_up_id = p_ps_node_id THEN
          get_Node_Up(l_parent_id,p_model_id,v_up_id,
                   v_up_expl_id,v_up_level);
       END IF;

    IF (l_virtual_flag='1' OR l_virtual_flag IS NULL) AND l_parent_id IS NOT NULL THEN

       FOR i IN(SELECT model_ref_expl_id, node_depth FROM CZ_MODEL_REF_EXPLS
                WHERE parent_expl_node_id=v_up_expl_id AND
                deleted_flag = NO_FLAG AND
                (referring_node_id IS NULL AND component_id IN
                 (SELECT ps_node_id FROM CZ_PS_NODES
                  START WITH ps_node_id=p_ps_node_id
                  CONNECT BY PRIOR ps_node_id=parent_id AND
                  deleted_flag = NO_FLAG AND PRIOR deleted_flag = NO_FLAG)) OR
                (referring_node_id IS NOT NULL AND referring_node_id IN
                 (SELECT ps_node_id FROM CZ_PS_NODES
                  START WITH ps_node_id=p_ps_node_id
                  CONNECT BY PRIOR ps_node_id=parent_id AND
                  deleted_flag = NO_FLAG AND PRIOR deleted_flag = NO_FLAG)))
       LOOP
	populate_parent_expl_tree_(p_model_id    => p_model_id,
	                  p_model_ref_expl_id    => i.model_ref_expl_id,
	                  p_parent_model_ref_expl_id   => v_up_expl_id);
       END LOOP;
     ELSIF l_virtual_flag='0' -- OR l_parent_id IS NULL
                            THEN
        populate_parent_expl_tree_(p_model_id    => p_model_id,
	                  p_model_ref_expl_id    => l_expl_id,
	                  p_parent_model_ref_expl_id   => v_up_expl_id);
     END IF;


END populate_parent_expl_tree;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE update_child_nodes(p_model_id IN NUMBER) IS

  TYPE t_varchar2_tbl_type IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;
  TYPE t_indchar2_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(32000);
  TYPE IntArrayIndexVC2 IS TABLE   OF NUMBER INDEX BY VARCHAR2(15);
  l_model_updated_tbl IntArrayIndexVC2;

  l_num_updated_records  NUMBER := 0;

  PROCEDURE update_layer
  (
  p_current_model_id IN NUMBER
  ) IS

     l_paths_tbl          t_varchar2_tbl_type;
     l_new_paths_tbl      t_varchar2_tbl_type;
     l_expl_path_tbl      t_indchar2_tbl_type;
     l_new_expl_path_tbl  t_indchar2_tbl_type;
     t_model_ref_expl_tbl IntArray;
     t_component_tbl      IntArray;

     l_next_model_level_tbl IntArray;
     l_child_expl_id        NUMBER;
     l_path1                VARCHAR2(32000);
     l_path2                VARCHAR2(32000);
     l_loop_char_id         VARCHAR2(32000);
     l_ref_expl_id          NUMBER;
     l_counter              NUMBER;
     l_loop_ind             NUMBER;

  BEGIN

    IF l_model_updated_tbl.EXISTS(p_current_model_id) THEN
      RETURN;
    ELSE
      l_model_updated_tbl(p_current_model_id) := p_current_model_id;
    END IF;

    FOR i IN(SELECT model_ref_expl_id, referring_node_id, component_id
               FROM CZ_MODEL_REF_EXPLS a
              WHERE a.model_id=p_current_model_id AND a.deleted_flag=NO_FLAG)
    LOOP

      IF i.referring_node_id IS NULL THEN
        l_paths_tbl(i.model_ref_expl_id) := TO_CHAR(i.component_id);
      ELSE
        l_paths_tbl(i.model_ref_expl_id) := TO_CHAR(i.referring_node_id);
      END IF;

      FOR m IN(SELECT model_ref_expl_id,component_id,referring_node_id
                 FROM CZ_MODEL_REF_EXPLS
                 WHERE model_ref_expl_id<>i.model_ref_expl_id
                START WITH model_ref_expl_id=i.model_ref_expl_id
                CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND deleted_flag=NO_FLAG)
      LOOP

        IF m.referring_node_id IS NULL THEN
          l_paths_tbl(i.model_ref_expl_id) := l_paths_tbl(i.model_ref_expl_id) || ':' ||TO_CHAR(m.component_id);
        ELSE
          l_paths_tbl(i.model_ref_expl_id) := l_paths_tbl(i.model_ref_expl_id) || ':' ||TO_CHAR(m.referring_node_id);
        END IF;

      END LOOP;

    END LOOP;

    l_loop_ind := l_paths_tbl.FIRST;
    LOOP
      IF l_loop_ind IS NULL THEN
        EXIT;
      END IF;

      l_expl_path_tbl(l_paths_tbl(l_loop_ind)) := l_loop_ind;

      l_loop_ind := l_paths_tbl.NEXT(l_loop_ind);
    END LOOP;

    FOR n IN (SELECT * FROM CZ_PS_NODES a
               WHERE reference_id=p_current_model_id AND
                     ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND deleted_flag=NO_FLAG AND
                     devl_project_id IN(SELECT object_id FROM CZ_RP_ENTRIES
                                         WHERE object_id=a.devl_project_id AND object_type='PRJ' AND deleted_flag=NO_FLAG)
              )
    LOOP

      l_new_expl_path_tbl.DELETE;

      SELECT model_ref_expl_id INTO l_ref_expl_id FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=n.devl_project_id AND referring_node_id=n.ps_node_id;

      l_new_paths_tbl.DELETE;

      FOR k IN(SELECT model_ref_expl_id,component_id,
                      referring_node_id,ps_node_type,child_model_expl_id,model_id
                 FROM CZ_MODEL_REF_EXPLS
               START WITH model_ref_expl_id=l_ref_expl_id AND deleted_flag=NO_FLAG
               CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND
                          deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
      LOOP

        IF k.referring_node_id IS NULL THEN
          l_new_paths_tbl(k.model_ref_expl_id) := TO_CHAR(k.component_id);
        ELSE
            l_new_paths_tbl(k.model_ref_expl_id) := TO_CHAR(k.referring_node_id);

             IF k.model_ref_expl_id=l_ref_expl_id THEN
               l_new_paths_tbl(k.model_ref_expl_id) := TO_CHAR(k.component_id);
             END IF;

         END IF;

        IF k.model_ref_expl_id <> l_ref_expl_id THEN

          FOR kk IN(SELECT model_ref_expl_id,component_id,referring_node_id
                   FROM CZ_MODEL_REF_EXPLS
                   WHERE model_ref_expl_id<>k.model_ref_expl_id
                   START WITH model_ref_expl_id=k.model_ref_expl_id
                   CONNECT BY PRIOR parent_expl_node_id=model_ref_expl_id AND deleted_flag=NO_FLAG)
          LOOP

            IF kk.referring_node_id IS NULL THEN
              l_new_paths_tbl(k.model_ref_expl_id) := l_new_paths_tbl(k.model_ref_expl_id) || ':' ||TO_CHAR(kk.component_id);

            ELSE

             IF kk.model_ref_expl_id=l_ref_expl_id THEN
               l_new_paths_tbl(k.model_ref_expl_id) := l_new_paths_tbl(k.model_ref_expl_id) || ':' || TO_CHAR(kk.component_id);
               EXIT;
             ELSE
               l_new_paths_tbl(k.model_ref_expl_id) := l_new_paths_tbl(k.model_ref_expl_id) || ':' ||TO_CHAR(kk.referring_node_id);
             END IF;

            END IF;

          END LOOP;

        END IF;

      END LOOP;

      l_loop_ind := l_new_paths_tbl.FIRST;
      LOOP
        IF l_loop_ind IS NULL THEN
          EXIT;
        END IF;

        IF l_expl_path_tbl.EXISTS(l_new_paths_tbl(l_loop_ind)) THEN

          SELECT child_model_expl_id INTO l_child_expl_id FROM CZ_MODEL_REF_EXPLS
           WHERE model_ref_expl_id=l_loop_ind;

          IF l_expl_path_tbl(l_new_paths_tbl(l_loop_ind)) <> l_child_expl_id THEN

            l_num_updated_records := l_num_updated_records + 1;

            UPDATE CZ_MODEL_REF_EXPLS
               SET child_model_expl_id=l_expl_path_tbl(l_new_paths_tbl(l_loop_ind))
             WHERE model_ref_expl_id=l_loop_ind;

          END IF;

        END IF;

        l_loop_ind := l_new_paths_tbl.NEXT(l_loop_ind);
      END LOOP;

      l_next_model_level_tbl(l_next_model_level_tbl.COUNT+1) := n.devl_project_id;

    END LOOP;

    IF l_next_model_level_tbl.COUNT > 0 THEN

      FOR v IN l_next_model_level_tbl.FIRST..l_next_model_level_tbl.LAST
      LOOP
        update_layer(l_next_model_level_tbl(v));
      END LOOP;

    END IF;


  END update_layer;

BEGIN

  --
  -- start with those explosion tree branches which do not have references/connectors to other models
  --
  FOR i IN(SELECT DISTINCT component_id FROM CZ_MODEL_REF_EXPLS a
            WHERE model_id=p_model_id AND deleted_flag=NO_FLAG AND
                  ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND NOT EXISTS
                  (SELECT NULL FROM CZ_MODEL_REF_EXPLS
                   WHERE model_id=a.component_id AND ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND deleted_flag=NO_FLAG))
  LOOP
    update_layer(i.component_id);
  END LOOP;

END update_child_nodes;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_duplicates(p_model_id IN NUMBER) IS

BEGIN
    FOR i IN (SELECT DISTINCT model_id FROM CZ_MODEL_REF_EXPLS
              WHERE component_id=p_model_id AND referring_node_id IS NOT NULL
                    AND deleted_flag=NO_FLAG)
    LOOP
       UPDATE CZ_MODEL_REF_EXPLS a
       SET deleted_flag = '1'
       WHERE model_id=i.model_id AND deleted_flag=NO_FLAG
             AND referring_node_id IS NOT NULL
             AND parent_expl_node_id IN
        (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
         WHERE model_id=i.model_id AND deleted_flag=NO_FLAG
              AND referring_node_id=a.referring_node_id);
    END LOOP;

    FOR i IN (SELECT DISTINCT component_id FROM CZ_MODEL_REF_EXPLS
              WHERE model_id=p_model_id AND referring_node_id IS NOT NULL
                    AND deleted_flag=NO_FLAG)
    LOOP
       UPDATE CZ_MODEL_REF_EXPLS a
       SET deleted_flag = '1'
       WHERE model_id=i.component_id AND deleted_flag=NO_FLAG
             AND referring_node_id IS NOT NULL
             AND parent_expl_node_id IN
        (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
         WHERE model_id=i.component_id AND deleted_flag=NO_FLAG
              AND referring_node_id=a.referring_node_id);
    END LOOP;
END delete_duplicates;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE populate_COMPONENT_ID(p_model_id IN NUMBER) IS

    v_ps_node_id   CZ_PS_NODES.ps_node_id%TYPE;
    v_parent_id    CZ_PS_NODES.parent_id%TYPE;
    v_ps_id        CZ_PS_NODES.ps_node_id%TYPE;

BEGIN
    FND_MSG_PUB.initialize;

    FOR i IN(SELECT ps_node_id,parent_id,ps_node_type,virtual_flag,devl_project_id,reference_id FROM CZ_PS_NODES
             START WITH devl_project_id=p_model_id AND parent_id IS NULL and deleted_flag='0'
             CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag='0' AND PRIOR deleted_flag='0')
    LOOP
       IF i.ps_node_type IN (REFERENCE_TYPE,CONNECTOR_TYPE) THEN
          UPDATE CZ_PS_NODES SET component_id=i.reference_id
          WHERE ps_node_id=i.ps_node_id AND component_id<>i.reference_id;
          GOTO CONTINUE_LOOP;
       END IF;
       IF  i.parent_id IS NULL OR i.virtual_flag='0' THEN
          UPDATE CZ_PS_NODES SET component_id=i.ps_node_id
          WHERE ps_node_id=i.ps_node_id AND component_id<>i.ps_node_id;
          GOTO CONTINUE_LOOP;
       END IF;
       IF NVL(i.virtual_flag,'1')='1' AND i.ps_node_type NOT IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND i.parent_id IS NOT NULL THEN
          SELECT ps_node_id,parent_id INTO v_ps_node_id,v_parent_id FROM CZ_PS_NODES a
          WHERE devl_project_id=i.devl_project_id AND
          EXISTS(SELECT NULL FROM CZ_PS_NODES WHERE ps_node_id=a.parent_id AND
          (virtual_flag='0' OR parent_id IS NULL) AND deleted_flag='0')
          START WITH ps_node_id=i.ps_node_id
          CONNECT BY PRIOR parent_id=ps_node_id AND deleted_flag='0' AND NVL(virtual_flag,'1')='1';

          IF v_parent_id IS NULL THEN
             v_ps_id:=v_ps_node_id;
          ELSE
             v_ps_id:=v_parent_id;
          END IF;

          UPDATE CZ_PS_NODES SET component_id=v_ps_id
          WHERE ps_node_id=i.ps_node_id AND component_id<>v_ps_id;
       END IF;

       <<CONTINUE_LOOP>>
         NULL;
    END LOOP;
END populate_COMPONENT_ID;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE check_Node
(p_ps_node_id       IN  INTEGER,
 p_model_id         IN  INTEGER,
 p_maximum          IN  INTEGER,
 p_minimum          IN  INTEGER,
 p_reference_id     IN  INTEGER,
 p_out_err          OUT NOCOPY INTEGER,
 p_out_virtual_flag OUT NOCOPY INTEGER,
 p_consequent_flag  IN  VARCHAR2 , -- DEFAULT NO_FLAG,
 p_expr_node_id     IN  INTEGER  DEFAULT NULL,
 p_ps_type          IN  INTEGER  DEFAULT NULL,
 p_expr_subtype     IN  INTEGER  DEFAULT NULL,
 p_skip_upd_nod_dep IN  VARCHAR2 DEFAULT NO_FLAG
) IS

    t_child_nodes         IntArray;
    t_childs              IntArray;

    v_expl_id             CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_model_ref_expl_id   CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_expl_node_type      CZ_MODEL_REF_EXPLS.expl_node_type%TYPE;
    v_del_ref_id          CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_up_expl_id          CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_up_level            CZ_MODEL_REF_EXPLS.node_depth%TYPE;
    v_curr_expl_node_type CZ_MODEL_REF_EXPLS.expl_node_type%TYPE;

    v_up_id               CZ_PS_NODES.ps_node_id%TYPE;
    v_virtual_flag        CZ_PS_NODES.virtual_flag%TYPE;
    v_ps_node_type        CZ_PS_NODES.ps_node_type%TYPE;
    v_ps_node_id          CZ_PS_NODES.ps_node_id%TYPE;
    v_minimum             CZ_PS_NODES.MINIMUM%TYPE;
    v_maximum             CZ_PS_NODES.MAXIMUM%TYPE;
    v_instantiable_flag   CZ_PS_NODES.instantiable_flag%TYPE;
    v_parent_expl_node_id NUMBER;
    v_component_id        NUMBER;
    v_comp_expl_id        NUMBER;
    v_ndebug              NUMBER;
    v_node_Exist          BOOLEAN:=FALSE;

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    v_ndebug := 0;
    cz_utils.log_report('CZ_REFS', 'check_Node', v_ndebug,
      'Starting CZ_REFS.check_Node for model node with ps_node_id='||TO_CHAR(p_ps_node_id)||
      ' current time : '||TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),
      fnd_log.LEVEL_PROCEDURE);
    cz_utils.log_report('CZ_REFS', 'check_Node', v_ndebug,
      'Parameters : '||
      'p_ps_node_id = '||TO_CHAR(p_ps_node_id)||
      'p_model_id = '||TO_CHAR(p_model_id)||
      'p_maximum = '||TO_CHAR(p_maximum)||
      'p_minimum = '||TO_CHAR(p_minimum)||
      'p_reference_id = '||TO_CHAR(p_reference_id)||
      'p_consequent_flag = '||p_consequent_flag||
      'p_expr_node_id = '||TO_CHAR(p_expr_node_id)||
      'p_ps_type = '||TO_CHAR(p_ps_type)||
      'p_ps_type = '||TO_CHAR(p_ps_type)
      ,fnd_log.LEVEL_PROCEDURE);
  END IF;

BEGIN
     Initialize;
     p_out_err:=0;
     p_out_virtual_flag:=1;

     SELECT instantiable_flag,ps_node_type,minimum,maximum,component_id
       INTO v_instantiable_flag,v_ps_node_type,v_minimum,v_maximum,v_component_id
       FROM CZ_PS_NODES
      WHERE ps_node_id=p_ps_node_id;

     -- Developer passes max/min
     v_minimum := p_minimum;
     v_maximum := p_maximum;

     IF NOT(v_minimum=1 AND v_maximum=1) AND v_ps_node_type<>BOM_MODEL_TYPE
        AND v_instantiable_flag=MANDATORY_EXPL_TYPE THEN
        p_out_err:=m_RUN_ID;
        LOG_REPORT('check_Node','CZ_PS_NODES.instantiable_flag=2 violates min/max=1/1.');
        RETURN;
     END IF;


     IF v_instantiable_flag NOT IN(OPTIONAL_EXPL_TYPE,MANDATORY_EXPL_TYPE,
        CONNECTOR_EXPL_TYPE,MINMAX_EXPL_TYPE) THEN

        IF v_minimum=1 AND v_maximum=1 AND
          v_ps_node_type<>CONNECTOR_TYPE THEN
           v_instantiable_flag:=MANDATORY_EXPL_TYPE;
        END IF;

        IF v_minimum=0 AND v_maximum=1 AND
          v_ps_node_type<>CONNECTOR_TYPE THEN
           v_instantiable_flag:=OPTIONAL_EXPL_TYPE;
        END IF;

        IF NOT(v_minimum=1 AND v_maximum=1) AND
          v_ps_node_type<>CONNECTOR_TYPE THEN
           v_instantiable_flag:=MINMAX_EXPL_TYPE;
        END IF;

        IF v_ps_node_type=CONNECTOR_TYPE THEN
           v_instantiable_flag:=CONNECTOR_EXPL_TYPE;
        END IF;

        UPDATE CZ_PS_NODES
           SET minimum=p_minimum,
               maximum=p_maximum,
               instantiable_flag=v_instantiable_flag
         WHERE ps_node_id=p_ps_node_id;

     END IF;

     --
     -- DEBUG ERROR CODE --
     --
     ERROR_CODE:=901;

     v_expl_node_type := v_instantiable_flag;

     --
     -- DEBUG ERROR CODE --
     --
     ERROR_CODE:=902;

     --
     -- do check :
     -- does Node with ps_node_id=p_ps_node_id exist ? --
     --
     BEGIN
         v_node_Exist:=FALSE;
         SELECT model_ref_expl_id,parent_expl_node_id,ps_node_type,virtual_flag,expl_node_type
         INTO  v_model_ref_expl_id,v_parent_expl_node_id,v_ps_node_type,v_virtual_flag,v_curr_expl_node_type
         FROM CZ_MODEL_REF_EXPLS
         WHERE ((component_id=p_ps_node_id AND referring_node_id IS NULL) OR
               referring_node_id=p_ps_node_id)
         AND model_id=p_model_id AND deleted_flag=NO_FLAG AND ROWNUM<2;
         v_node_Exist:=TRUE;
     EXCEPTION
         WHEN NO_DATA_FOUND THEN
              NULL;
     END;

     --
     -- this is "Root Node"  case --
     --
     IF p_ps_node_id=p_model_id THEN
        IF v_node_Exist=FALSE THEN
           --
           -- DEBUG ERROR CODE --
           --
           ERROR_CODE:=903;

           --
           -- add root node
           --
           add_root_Model_record(p_ps_node_id,v_ps_node_type);

           UPDATE CZ_PS_NODES
           SET component_id=p_model_id,
               minimum=p_minimum,
               maximum=p_maximum,
               instantiable_flag=MANDATORY_EXPL_TYPE
           WHERE devl_project_id=p_model_id AND
                 parent_id is null AND deleted_flag='0';

           --
           -- DEBUG ERROR CODE --
           --
           ERROR_CODE:=904;

        END IF;
        GOTO FINAL_SECTION;
     END IF;

     --
     -- case when we have Min=1 and Max=1 for not Connectors/References nodes
     -- and this node with ps_node_id=p_ps_node_id does not
     -- exist in CZ_MODEL_REF_EXPLS table
     -- and no Numeric Rules which contribute to  Min/Max are specified
     -- in this case we just need to exit from program
     --
     IF  (v_expl_node_type=MANDATORY_EXPL_TYPE) AND (v_ps_node_type NOT IN(REFERENCE_TYPE,CONNECTOR_TYPE))
         AND v_node_Exist=FALSE THEN
          GOTO FINAL_SECTION;
     END IF;

     IF v_expl_node_type IN(OPTIONAL_EXPL_TYPE,MINMAX_EXPL_TYPE) THEN
        p_out_virtual_flag:=NO_FLAG;
     ELSE
        p_out_virtual_flag:=YES_FLAG;
     END IF;

     UPDATE CZ_PS_NODES
        SET virtual_flag=p_out_virtual_flag,
            minimum=p_minimum,
            maximum=p_maximum
     WHERE ps_node_id=p_ps_node_id;

     IF SQL%ROWCOUNT>0 THEN

        IF (v_ps_node_type NOT IN(REFERENCE_TYPE,CONNECTOR_TYPE)) THEN
           UPDATE CZ_MODEL_REF_EXPLS
           SET virtual_flag=p_out_virtual_flag,
               expl_node_type=v_expl_node_type
           WHERE component_id=p_ps_node_id AND deleted_flag=NO_FLAG;
        ELSE
           UPDATE CZ_MODEL_REF_EXPLS
           SET virtual_flag=p_out_virtual_flag,
               expl_node_type=v_expl_node_type
           WHERE referring_node_id=p_ps_node_id AND deleted_flag=NO_FLAG;
        END IF;

     END IF;

     IF v_ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND v_node_Exist=FALSE THEN
        --
        -- find "Models Chain" that contains
        -- the given model ( CZ_DEVL_PROJECTS.devl_project_id=p_model_id )
        -- t_chain array will store Model Ids of this chain
        --
        t_chain.DELETE;t_projectCache.DELETE;
        populate_chain(p_model_id);

        add_Reference(p_ps_node_id,p_reference_id,p_model_id,
                      p_out_virtual_flag,p_out_err,v_ps_node_type,v_expl_node_type);

        GOTO FINAL_SECTION;
     END IF;

     --
     -- this means UPDATE from (n,m) to (1,1)
     --
     IF p_out_virtual_flag=YES_FLAG  AND
        (v_ps_node_type NOT IN(REFERENCE_TYPE,CONNECTOR_TYPE)) AND v_node_Exist THEN

       FOR x IN (SELECT model_ref_expl_id,parent_expl_node_id,model_id FROM CZ_MODEL_REF_EXPLS a
                 WHERE component_id=p_ps_node_id AND deleted_flag=NO_FLAG AND
                 model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
                 WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG))
       LOOP
          BEGIN
              IF x.model_id=p_model_id THEN
                 v_del_ref_id:=x.model_ref_expl_id;
              END IF;

              --
              -- DEBUG ERROR CODE --
              --
              ERROR_CODE:=905;

              FOR y IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                        START WITH model_ref_expl_id=x.model_ref_expl_id  AND deleted_flag=NO_FLAG
                        CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND
                        PRIOR deleted_flag=NO_FLAG)
              LOOP
                 UPDATE CZ_MODEL_REF_EXPLS SET node_depth=node_depth-1
                 WHERE model_ref_expl_id=y.model_ref_expl_id;
              END LOOP;

              --
              -- DEBUG ERROR CODE --
              --
              ERROR_CODE:=906;

              UPDATE CZ_MODEL_REF_EXPLS SET parent_expl_node_id=x.parent_expl_node_id
              WHERE parent_expl_node_id=x.model_ref_expl_id
              AND model_id=x.model_id AND deleted_flag=NO_FLAG;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   NULL;
          END;
        END LOOP;

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=907;

        delete_Node_(p_ps_node_id,COMPONENT_TYPE, '1');

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=908;

        set_Expls(p_model_id,p_ps_node_id,MINUS_MODE,v_del_ref_id);

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=909;

        refresh_UI_Expl_Ids(p_ps_node_id   => p_ps_node_id,
                            p_component_id => v_component_id,
                            p_model_id     => p_model_id,
                            p_old_expl_id  => v_model_ref_expl_id,
                            p_new_expl_id  => v_parent_expl_node_id);

        GOTO FINAL_SECTION;
    END IF;

    --
    -- this means UPDATE from (1,1) to (n,m)
    --
    IF p_out_virtual_flag=NO_FLAG AND (v_ps_node_type NOT IN(REFERENCE_TYPE,CONNECTOR_TYPE))
       AND v_node_Exist=FALSE THEN

       --
       -- find nearest non-virtual node above the target node --
       --
       get_Node_Up(p_ps_node_id,p_model_id,v_up_id,
                   v_up_expl_id,v_up_level);

       v_expl_id:=allocate_Expl_Id;
       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=910;

       INSERT INTO CZ_MODEL_REF_EXPLS
          (model_ref_expl_id,
           parent_expl_node_id,
           referring_node_id,
           model_id,
           component_id,
           ps_node_type,
           virtual_flag,
           node_depth,
           expl_node_type,
           deleted_flag)
        VALUES
          (v_expl_id,
           v_up_expl_id,
           NULL,
           p_model_id,
           p_ps_node_id,
           v_ps_node_type,
           p_out_virtual_flag,
           v_up_level+1,
           v_expl_node_type,
           NO_FLAG);

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=911;

        --
        -- reset childs nodes
        --
        t_childs.DELETE;

        SELECT ps_node_id BULK COLLECT INTO t_childs FROM CZ_PS_NODES
        WHERE devl_project_id=p_model_id AND ps_node_id<>p_ps_node_id AND
        (
         (ps_node_type in(COMPONENT_TYPE,PRODUCT_TYPE) AND ps_node_id IN  ---- fix for bug #3161931
           (SELECT component_id FROM CZ_MODEL_REF_EXPLS
            WHERE model_id=p_model_id AND deleted_flag=NO_FLAG AND parent_expl_node_id=v_up_expl_id AND
            component_id IN(SELECT ps_node_id FROM CZ_PS_NODES
                            START WITH ps_node_id=p_ps_node_id AND deleted_flag=NO_FLAG
                            CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
           )
         )
        OR
        (ps_node_type in(REFERENCE_TYPE,CONNECTOR_TYPE) AND ps_node_id IN ---- fix for bug #3161931
           (SELECT referring_node_id FROM CZ_MODEL_REF_EXPLS
            WHERE model_id=p_model_id AND deleted_flag=NO_FLAG AND parent_expl_node_id=v_up_expl_id AND
            referring_node_id IN(SELECT ps_node_id FROM CZ_PS_NODES
                                 START WITH ps_node_id=p_ps_node_id AND deleted_flag=NO_FLAG
                                 CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
           )
        )
       ) AND deleted_flag=NO_FLAG;

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=912;

        IF t_childs.COUNT>0 THEN
           FOR t IN t_childs.FIRST..t_childs.LAST
           LOOP
              t_child_nodes.DELETE;
              v_ps_node_id:= t_childs(t);
              UPDATE CZ_MODEL_REF_EXPLS
              SET parent_expl_node_id=v_expl_id
              WHERE parent_expl_node_id=v_up_expl_id
              AND model_id=p_model_id AND
              ((ps_node_type IN(PRODUCT_TYPE,COMPONENT_TYPE,BOM_MODEL_TYPE) AND component_id=v_ps_node_id)
               OR (ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND referring_node_id=v_ps_node_id))
              AND deleted_flag=NO_FLAG
              RETURNING model_ref_expl_id BULK COLLECT INTO t_child_nodes ;

              IF t_child_nodes.COUNT>0 THEN

                 --
                 -- DEBUG ERROR CODE --
                 --
                 ERROR_CODE:=913;

                 FORALL h IN t_child_nodes.FIRST..t_child_nodes.LAST
                        UPDATE CZ_MODEL_REF_EXPLS
                        SET node_depth=node_depth+1
                        WHERE model_ref_expl_id IN
                        (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                         START WITH model_ref_expl_id=t_child_nodes(h) AND deleted_flag=NO_FLAG
                         CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
                         AND PRIOR deleted_flag=NO_FLAG);

                 --
                 -- DEBUG ERROR CODE --
                 --
                 ERROR_CODE:=914;

              END IF;
           END LOOP; -- end of loop for t in t_childs.First..t_childs.Last --
        END IF;  -- end of t_childs.Count>0 case --

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=915;

        --
        -- find "Models Chain" that contains
        -- the given model ( CZ_DEVL_PROJECTS.devl_project_id=v_ref_model_id )
        -- t_chain array will store Model Ids of this chain
        --
        t_chain.DELETE;t_projectCache.DELETE;
        populate_chain(p_model_id);

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=916;

        populate_tree
        (v_up_expl_id,v_expl_id,p_ps_node_id,v_ps_node_type,
         v_expl_node_type,p_model_id,t_childs);

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=917;

        set_Expls(p_model_id,p_ps_node_id, PLUS_MODE);

        SELECT MIN(model_ref_expl_id) INTO v_comp_expl_id
        FROM CZ_MODEL_REF_EXPLS
        WHERE model_id=p_model_id AND component_id=v_component_id AND
              deleted_flag='0';

        refresh_UI_Expl_Ids(p_ps_node_id   => p_ps_node_id,
                            p_component_id => v_component_id,
                            p_model_id     => p_model_id,
                            p_old_expl_id  => v_comp_expl_id,
                            p_new_expl_id  => v_expl_id);

    END IF;

EXCEPTION
WHEN OTHERS THEN
     p_out_err:=m_RUN_ID;
     LOG_REPORT('check_Node','Error : ps_node_id='||
     TO_CHAR(p_ps_node_id)||' < '||ERROR_CODE||' > : '||SQLERRM);
END;


<<FINAL_SECTION>>
    --
    -- fix child_model_expl_id's if they are wrong
    -- ( recursion is used )
    -- this code was commented out because of
    -- perfomance problem
    --
    --update_child_nodes(p_model_id);

    --
    -- fix node_depth's if they are wrong
    -- ( recursion is used )
    --
    --
    -- Due to BOM Refresh performance problem reported in bug 9446997
    -- conditionalize call update_Node_Depth. update_Node_Depth need to
    -- be called explicitly at then end of check_node call
    -- if p_skip_upd_nod_dep = YES_FLAG

    IF p_skip_upd_nod_dep = YES_FLAG THEN
       t_upd_node_depth_models(p_model_id) := p_model_id;
    ELSE
       update_Node_Depth(p_model_id);
    END IF;


    --
    -- delete duplicates
    -- like
    --  Reference-n
    --     |---------Reference-n
    --
    --delete_duplicates(p_model_id);

    populate_COMPONENT_ID(p_model_id);

  NULL;
END check_Node;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_Node
(p_ps_node_id    IN  INTEGER,
 p_ps_node_type  IN  INTEGER,
 p_out_err       OUT NOCOPY INTEGER,
 p_del_logically IN  VARCHAR2 -- DEFAULT '1'
) IS

  v_component_id  CZ_PS_NODES.component_id%TYPE;
  v_virtual_flag  CZ_PS_NODES.virtual_flag%TYPE;
  v_ps_node_type  CZ_PS_NODES.ps_node_type%TYPE;

BEGIN
    Initialize;
    p_out_err:=0;

    IF  p_ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) THEN

        FOR i IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS a
                  WHERE referring_node_id=p_ps_node_id  AND deleted_flag=NO_FLAG AND
                  model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
                  WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG))
        LOOP
           --
           -- DEBUG ERROR CODE --
           --
           ERROR_CODE:=1001;

           delete_it(i.model_ref_expl_id, YES_FLAG);

           --
           -- DEBUG ERROR CODE --
           --
           ERROR_CODE:=1002;

        END LOOP;
    ELSE
        SELECT component_id,NVL(virtual_flag,'1') INTO v_component_id,v_virtual_flag FROM CZ_PS_NODES
        WHERE ps_node_id=p_ps_node_id;

        IF v_virtual_flag='0' THEN
           FOR i IN (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS a
                     WHERE component_id=p_ps_node_id AND deleted_flag=NO_FLAG AND
                           model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
                           WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG))
           LOOP
             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=1003;

             delete_it(i.model_ref_expl_id, YES_FLAG);

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=1004;

          END LOOP;

        ELSE

          FOR i IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS a
                   WHERE parent_expl_node_id IN
                        (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                         WHERE model_id=a.model_id AND component_id=v_component_id AND deleted_flag='0')
                         AND (component_id IN
                                           (SELECT ps_node_id FROM CZ_PS_NODES
                                            START WITH ps_node_id=p_ps_node_id
                                            CONNECT BY PRIOR ps_node_id=parent_id)
                              OR
                              referring_node_id IN
                                                (SELECT ps_node_id FROM cz_ps_nodes
                                                 START WITH ps_node_id=p_ps_node_id
                                                 CONNECT BY PRIOR ps_node_id=parent_id)
                             )
                  )
          LOOP
            --
            -- DEBUG ERROR CODE --
            --
            ERROR_CODE:=1005;

            delete_it(i.model_ref_expl_id, YES_FLAG);

            --
            -- DEBUG ERROR CODE --
            --
            ERROR_CODE:=1006;
          END LOOP;

          END IF;

        END IF;

EXCEPTION
    WHEN OTHERS THEN
         p_out_err:=m_RUN_ID;
         LOG_REPORT('delete_Node',
         'Error : ps_node_id='||TO_CHAR(p_ps_node_id)||' < '||ERROR_CODE||' > : '||SQLERRM);
END delete_Node;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE update_levels
(p_expl_id    IN INTEGER,
 p_level      IN INTEGER,
 p_tree_level IN INTEGER) IS

BEGIN
    FOR i IN(SELECT model_ref_expl_id,parent_expl_node_id FROM CZ_MODEL_REF_EXPLS
             WHERE parent_expl_node_id=p_expl_id AND deleted_flag=NO_FLAG)
    LOOP
       UPDATE CZ_MODEL_REF_EXPLS SET node_depth=p_level+p_tree_level
       WHERE model_ref_expl_id=i.model_ref_expl_id;

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1100;

       update_levels(i.model_ref_expl_id,p_level+p_tree_level,p_tree_level+1);

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1101;

    END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

--
-- this is general recursive procedure to reconstruct Parent/Childs
--
PROCEDURE reConstruct
(p_project_id     IN INTEGER,
 p_expl_root_id   IN INTEGER,
 p_from_expl_id   IN INTEGER,
 p_up_expl_id     IN INTEGER,
 p_model_ref_expl IN IntArray,
 p_levels         IN IntArray) IS

    t_levels            IntArray;
    t_levels_           IntArray;
    t_refs              IntArray;
    t_models            IntArray;
    t_model_ref_expl    IntArray;
    t_model_ref_expl_   IntArray;
    v_expl_root_id    CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_from_up_expl_id CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_up_expl_id      CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_from_expl_id    CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_up_level        CZ_MODEL_REF_EXPLS.node_depth%TYPE;
    STOP_IT             EXCEPTION;

BEGIN

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1200;

    --
    -- find nodes of parent Models which corresponds with
    -- a moved node in source Model
    --
    SELECT model_ref_expl_id,model_id
    BULK COLLECT INTO t_refs,t_models
    FROM CZ_MODEL_REF_EXPLS a
    WHERE child_model_expl_id=p_expl_root_id
    AND ps_node_type IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND deleted_flag=NO_FLAG AND
    model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
    WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG);

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1201;

    IF t_refs.COUNT=0 THEN
       RAISE STOP_IT;
    END IF;

    FOR i IN t_refs.FIRST..t_refs.LAST
    LOOP
       --
       -- find a root node of subtree in the current parent Model
       -- associated with a child referenced Model
       --
       v_expl_root_id:=t_refs(i);

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1202;

       SELECT model_ref_expl_id INTO v_from_up_expl_id FROM CZ_MODEL_REF_EXPLS a
       WHERE child_model_expl_id=p_from_expl_id AND model_ref_expl_id
       IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
          START WITH model_ref_expl_id=t_refs(i) AND deleted_flag=NO_FLAG
          CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND
                           deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
       AND
       model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
       WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG);

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1203;

       SELECT model_ref_expl_id,node_depth
       INTO v_up_expl_id,v_up_level FROM CZ_MODEL_REF_EXPLS a
       WHERE child_model_expl_id=p_up_expl_id AND model_ref_expl_id
       IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
          START WITH model_ref_expl_id=t_refs(i) AND deleted_flag=NO_FLAG
          CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND PRIOR deleted_flag=NO_FLAG)
       AND
       model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
       WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG);

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1204;

       FOR k IN p_model_ref_expl.FIRST..p_model_ref_expl.LAST
       LOOP
          UPDATE CZ_MODEL_REF_EXPLS
          SET parent_expl_node_id=v_up_expl_id
          WHERE model_ref_expl_id
          IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
          WHERE (parent_expl_node_id=v_from_up_expl_id OR model_ref_expl_id=v_from_up_expl_id)
          AND child_model_expl_id=p_model_ref_expl(k)
          AND deleted_flag=NO_FLAG);

       END LOOP;

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1205;

       t_old_expl_ids(t_old_expl_ids.COUNT+1):=v_from_up_expl_id;
       t_new_expl_ids(t_new_expl_ids.COUNT+1):=v_up_expl_id;

       FOR k IN p_model_ref_expl.FIRST..p_model_ref_expl.LAST
       LOOP

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1206;

          --
          -- recreate array of child_model_expl_id-s --
          --
          SELECT model_ref_expl_id,node_depth
          BULK COLLECT INTO t_model_ref_expl_,t_levels_
          FROM CZ_MODEL_REF_EXPLS
          WHERE parent_expl_node_id=v_up_expl_id
          AND child_model_expl_id=p_model_ref_expl(k)
          AND deleted_flag=NO_FLAG;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1207;

       END LOOP;


      IF t_model_ref_expl_.COUNT>0 THEN
         --
         -- DEBUG ERROR CODE --
         --
         ERROR_CODE:=1208;

         update_levels(v_up_expl_id,v_up_level,1);
         reConstruct(p_project_id    =>p_project_id,
                     p_expl_root_id  =>v_expl_root_id,
                     p_from_expl_id  =>v_from_up_expl_id,
                     p_up_expl_id    =>v_up_expl_id,
                     p_model_ref_expl=>t_model_ref_expl_,
                     p_levels        =>t_levels_ );

        --
        -- DEBUG ERROR CODE --
        --
        ERROR_CODE:=1209;

      END IF;
    END LOOP;

EXCEPTION
    WHEN STOP_IT THEN
         NULL;
    WHEN OTHERS THEN
         LOG_REPORT('reConstruct','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
END reConstruct;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE move_Node
(p_from_ps_node_id IN  INTEGER,
 p_to_ps_node_id   IN  INTEGER,
 p_project_id      IN  INTEGER,
 p_out_err         OUT NOCOPY INTEGER) IS

    t_levels              IntArray;
    t_refs                IntArray;
    t_models              IntArray;
    t_model_ref_expl      IntArray;
    v_up_id               INTEGER;
    v_down_id             INTEGER;
    v_up_expl_id          INTEGER;
    v_expr_node_id        INTEGER;
    v_down_expl_id        INTEGER;
    v_level               INTEGER;
    v_up_level            INTEGER;
    v_from_up_id          INTEGER;
    v_from_up_expl_id     INTEGER;
    v_from_up_level       INTEGER;
    v_down_level          INTEGER;
    v_delta_level         INTEGER;
    v_expl_root_id        INTEGER;
    var_subroot_id        INTEGER;
    var_subroot_level     INTEGER;
    v_temp                INTEGER;
    err                   INTEGER;
    v_ps_node_type        CZ_PS_NODES.ps_node_type%TYPE;
    v_virtual_flag        CZ_PS_NODES.virtual_flag%TYPE;

    v_ref_up_expl_id      CZ_MODEL_REF_EXPLS.model_ref_expl_id%TYPE;
    v_ref_up_level        CZ_MODEL_REF_EXPLS.node_depth%TYPE;
    v_contains_non_virt   BOOLEAN:=FALSE;
    v_circularity_exists  BOOLEAN:=FALSE;
    v_comp_expl_id        NUMBER;
    v_model_ref_expl_id   NUMBER;
    v_component_id        NUMBER;
    v_parent_id           NUMBER;
    v_ndebug              NUMBER;

BEGIN

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    v_ndebug := 0;
    cz_utils.log_report('CZ_REFS', 'move_Node', v_ndebug,
      'Starting CZ_REFS.move_Node for model node with ps_node_id='||TO_CHAR(p_from_ps_node_id)||
      ' current time : '||TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS'),
      fnd_log.LEVEL_PROCEDURE);
    cz_utils.log_report('CZ_REFS', 'move_Node', v_ndebug,
      'Parameters : '||
      'p_from_ps_node_id = '||TO_CHAR(p_from_ps_node_id)||
      'p_to_ps_node_id = '||TO_CHAR(p_to_ps_node_id)||
      'p_project_id = '||TO_CHAR(p_project_id)
      ,fnd_log.LEVEL_PROCEDURE);
 END IF;

 BEGIN -- main try/catch block --
    Initialize;
    p_out_err:=0;
    t_old_expl_ids.DELETE;
    t_new_expl_ids.DELETE;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1300;

    SELECT ps_node_type,NVL(virtual_flag,YES_FLAG),parent_id,component_id
    INTO v_ps_node_type,v_virtual_flag,v_parent_id,v_component_id
    FROM CZ_PS_NODES
    WHERE ps_node_id=p_from_ps_node_id;

LOG_REPORT('*','p_from_ps_node_id='||to_char(p_from_ps_node_id)||
' v_parent_id='||to_char(v_parent_id));

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1301;

    --
    -- find nearest non-virtual node above the target node --
    --
    get_Node_Up(p_to_ps_node_id,p_project_id,v_up_id,
                v_up_expl_id,v_up_level);


    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1302;

    IF v_ps_node_type IN (REFERENCE_TYPE,CONNECTOR_TYPE) THEN

       v_from_up_id:=p_from_ps_node_id;
       SELECT model_ref_expl_id,node_depth
       INTO v_from_up_expl_id,v_from_up_level
       FROM CZ_MODEL_REF_EXPLS
       WHERE model_id=p_project_id AND referring_node_id=p_from_ps_node_id
       AND deleted_flag=NO_FLAG;

       BEGIN
           SELECT model_ref_expl_id,node_depth
           INTO v_ref_up_expl_id,v_ref_up_level
           FROM CZ_MODEL_REF_EXPLS
           WHERE component_id=v_up_id
           AND model_id=p_project_id AND deleted_flag=NO_FLAG;

           UPDATE CZ_MODEL_REF_EXPLS
           SET parent_expl_node_id=v_ref_up_expl_id
           WHERE model_ref_expl_id=v_from_up_expl_id
           AND deleted_flag=NO_FLAG;

           UPDATE CZ_MODEL_REF_EXPLS SET node_depth=node_depth-v_from_up_level+v_ref_up_level+1
           WHERE model_ref_expl_id IN
           (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
            START WITH model_ref_expl_id=v_from_up_expl_id AND deleted_flag=NO_FLAG
            CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
            AND PRIOR deleted_flag=NO_FLAG);
       EXCEPTION
           WHEN OTHERS THEN
                p_out_err:=m_RUN_ID;
                LOG_REPORT('move_Node','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
                GOTO FINAL_SECTION;
       END;

       t_chain.DELETE;t_projectCache.DELETE;
       populate_chain(p_project_id);

       IF t_chain.COUNT>0 THEN
          FOR i IN t_chain.FIRST..t_chain.LAST
          LOOP
             FOR k IN(SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS WHERE
                      model_id=t_chain(i).model_id AND ps_node_type IN(REFERENCE_TYPE,264)
                     AND component_id=p_project_id AND deleted_flag=NO_FLAG)
             LOOP
                BEGIN
                    SELECT model_ref_expl_id,node_depth
                    INTO v_ref_up_expl_id,v_ref_up_level
                    FROM CZ_MODEL_REF_EXPLS
                    WHERE component_id=v_up_id
                    AND model_ref_expl_id IN
                    (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                     START WITH model_ref_expl_id=k.model_ref_expl_id AND deleted_flag=NO_FLAG
                     CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
                     AND PRIOR deleted_flag=NO_FLAG);


                    UPDATE CZ_MODEL_REF_EXPLS
                    SET parent_expl_node_id=v_ref_up_expl_id
                    WHERE model_ref_expl_id IN
                    (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS a
                    WHERE referring_node_id=p_from_ps_node_id
                    AND model_ref_expl_id IN
                    (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                     START WITH model_ref_expl_id=k.model_ref_expl_id AND deleted_flag=NO_FLAG
                     CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
                                      AND PRIOR deleted_flag=NO_FLAG) AND
                     model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
                    WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG))
                    RETURNING model_ref_expl_id,node_depth INTO var_subroot_id,var_subroot_level ;

                     UPDATE CZ_MODEL_REF_EXPLS SET node_depth=node_depth-var_subroot_level+v_ref_up_level+1
                     WHERE model_ref_expl_id IN
                     (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
                     START WITH model_ref_expl_id=var_subroot_id AND deleted_flag=NO_FLAG
                     CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND
                     PRIOR deleted_flag=NO_FLAG);

                EXCEPTION
                    WHEN OTHERS THEN
                         p_out_err:=m_RUN_ID;
                         LOG_REPORT('move_Node','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
                         GOTO FINAL_SECTION;
                END;
             END LOOP;
          END LOOP;
       END IF;

       GOTO FINAL_SECTION;

    ELSE

       IF v_virtual_flag='1' THEN

          get_from_Node_Up(p_from_ps_node_id,p_project_id,v_from_up_id,
                           v_from_up_expl_id,v_from_up_level);

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1303;

          SELECT model_ref_expl_id
          BULK COLLECT INTO t_model_ref_expl
          FROM CZ_MODEL_REF_EXPLS
          WHERE parent_expl_node_id=v_from_up_expl_id AND model_id=p_project_id AND
          component_id IN(SELECT ps_node_id FROM CZ_PS_NODES
                          START WITH ps_node_id=p_from_ps_node_id AND deleted_flag=NO_FLAG
                          CONNECT BY PRIOR ps_node_id=parent_id AND deleted_flag=NO_FLAG
                          AND PRIOR deleted_flag=NO_FLAG);

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1304;

       ELSE

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1305;

          v_from_up_id:=p_from_ps_node_id;
          SELECT model_ref_expl_id,node_depth
          INTO v_from_up_expl_id,v_from_up_level
          FROM CZ_MODEL_REF_EXPLS
          WHERE model_id=p_project_id AND component_id=v_from_up_id
          AND ps_node_type NOT IN(REFERENCE_TYPE,CONNECTOR_TYPE) AND child_model_expl_id IS NULL AND
          deleted_flag=NO_FLAG;
          t_model_ref_expl(1):=v_from_up_expl_id;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1306;

       END IF;
    END IF;

    IF t_model_ref_expl.COUNT>0 THEN

       FOR i IN t_model_ref_expl.FIRST..t_model_ref_expl.LAST
       LOOP

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1307;

          UPDATE CZ_MODEL_REF_EXPLS SET parent_expl_node_id=v_up_expl_id
          WHERE model_ref_expl_id=t_model_ref_expl(i)
          AND model_id=p_project_id;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1308;

          UPDATE CZ_MODEL_REF_EXPLS SET node_depth=node_depth-v_from_up_level+v_up_level+1
          WHERE model_ref_expl_id IN
          (SELECT model_ref_expl_id FROM CZ_MODEL_REF_EXPLS
           START WITH model_ref_expl_id=t_model_ref_expl(i) AND deleted_flag=NO_FLAG
           CONNECT BY PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG AND
           PRIOR deleted_flag=NO_FLAG);

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1309;

       END LOOP;

    END IF;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1310;

    SELECT model_ref_expl_id INTO v_expl_root_id
    FROM CZ_MODEL_REF_EXPLS WHERE model_id=p_project_id AND component_id=p_project_id
    AND parent_expl_node_id IS NULL AND deleted_flag=NO_FLAG;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1311;

    IF t_model_ref_expl.COUNT>0 THEN
       FOR t IN  t_model_ref_expl.FIRST..t_model_ref_expl.LAST
       LOOP

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1312;

          SELECT node_depth INTO v_temp FROM CZ_MODEL_REF_EXPLS
          WHERE model_id=p_project_id AND model_ref_expl_id=t_model_ref_expl(t);
          t_levels(t_levels.COUNT+1):=v_temp;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1313;

       END LOOP;
    END IF;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1314;

    t_old_expl_ids(t_old_expl_ids.COUNT+1):=v_from_up_expl_id;

    t_new_expl_ids(t_new_expl_ids.COUNT+1):=v_up_expl_id;

    reConstruct(p_project_id    =>p_project_id,
                p_expl_root_id  =>v_expl_root_id,
                p_from_expl_id  =>v_from_up_expl_id,
                p_up_expl_id    =>v_up_expl_id,
                p_model_ref_expl=>t_model_ref_expl,
                p_levels        =>t_levels);

    IF v_virtual_flag=YES_FLAG THEN
       update_Rules(p_from_ps_node_id);

        SELECT MIN(model_ref_expl_id) INTO v_comp_expl_id
        FROM CZ_MODEL_REF_EXPLS
        WHERE model_id=p_project_id AND component_id=v_component_id AND
              deleted_flag='0';

        SELECT MIN(model_ref_expl_id) INTO v_comp_expl_id
        FROM CZ_MODEL_REF_EXPLS
        WHERE model_id=p_project_id AND component_id=
              (SELECT component_id FROM CZ_PS_NODES WHERE ps_node_id=p_to_ps_node_id) AND
              deleted_flag='0';

        refresh_UI_Expl_Ids(p_ps_node_id   => p_from_ps_node_id,
                            p_component_id => v_component_id,
                            p_model_id     => p_project_id,
                            p_old_expl_id  => v_model_ref_expl_id,
                            p_new_expl_id  => v_comp_expl_id);

    END IF;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1315;

 EXCEPTION
     WHEN OTHERS THEN
          p_out_err:=m_RUN_ID;
          LOG_REPORT('move_Node','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
 END;

<<FINAL_SECTION>>
    --
    -- fix child_model_expl_id's if they are wrong
    -- ( recursion is used )
    -- this code was commented out because of
    -- perfomance problem
    --
    update_child_nodes(p_project_id);

    --
    -- fix node_depth's if they are wrong
    -- ( recursion is used )
    --
    update_Node_Depth(p_project_id);

    --
    -- delete duplicates
    -- like
    --  Reference-n
    --     |---------Reference-n
    --
    -- delete_duplicates(p_project_id);

    populate_COMPONENT_ID(p_project_id);

END move_Node;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE CHECK_REF_REQUEST
(p_refroot_model_id    IN  INTEGER,
 p_ref_parent_node_id  IN  INTEGER,
 p_ref_target_model_id IN  INTEGER,
 p_out_status_code     OUT NOCOPY INTEGER) IS

    v_BOM_node1    CZ_PS_NODES.ps_node_id%TYPE;
    v_BOM_node2    CZ_PS_NODES.ps_node_id%TYPE;
    v_instanciable INTEGER;

BEGIN
    p_out_status_code:=0;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1400;

    BEGIN
        SELECT ps_node_id INTO v_BOM_node1 FROM CZ_PS_NODES
        WHERE devl_project_id=p_refroot_model_id AND ps_node_type=BOM_MODEL_TYPE
        AND deleted_flag=NO_FLAG AND rownum<2;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             v_BOM_node1:=containsBOM(p_refroot_model_id,v_instanciable);
    END;

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1401;

    v_BOM_node2:=containsBOM(p_ref_target_model_id,v_instanciable);

    --
    -- DEBUG ERROR CODE --
    --
    ERROR_CODE:=1402;

    IF v_BOM_node1>0 AND v_BOM_node2>0 THEN
       IF v_instanciable=1 THEN
          p_out_status_code:=1;
       ELSE
          p_out_status_code:=2;
       END IF;
       RETURN;
    END IF;

    IF v_BOM_node2>0 THEN
      -- check models that reference the current model ( p_refroot_model_id )
      FOR n IN(SELECT DISTINCT model_id FROM CZ_MODEL_REF_EXPLS a
               WHERE component_id=p_refroot_model_id AND ps_node_type=REFERENCE_TYPE AND
                     deleted_flag='0' AND
                     EXISTS(SELECT NULL FROM CZ_RP_ENTRIES WHERE object_id=a.model_id AND
                            object_type='PRJ' AND deleted_flag='0'))
      LOOP
        IF containsBOM(n.model_id, v_instanciable) > 0 THEN
          p_out_status_code:=1;
          RETURN;
        END IF;
      END LOOP;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;
    WHEN TOO_MANY_ROWS THEN
         p_out_status_code:=1;
         LOG_REPORT('CHECK_REF_REQUEST',
         'Wrong PS Tree : there are more than one BOM model in PS Tree');
    WHEN OTHERS THEN
         LOG_REPORT('CHECK_REF_REQUEST','ERROR CODE :'||ERROR_CODE||' : '||SQLERRM);
END CHECK_REF_REQUEST;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE SolutionBasedModelcheck
(p_model_id     IN  INTEGER,
 p_instanciable OUT NOCOPY INTEGER) IS

    v_bom_node_id CZ_PS_NODES.ps_node_id%TYPE;

BEGIN
    p_instanciable:=0;
    v_bom_node_id:=containsBOM(p_model_id,p_instanciable);
END SolutionBasedModelcheck;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_childs(t_arr IN IntArray) IS
    temp_arr  IntArray;
    v_arr     IntArray;
BEGIN
    IF t_arr.COUNT>0 THEN
       FOR i IN t_arr.FIRST..t_arr.LAST
       LOOP
          temp_arr.DELETE;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1500;

          UPDATE CZ_MODEL_REF_EXPLS a SET deleted_flag=YES_FLAG
          WHERE child_model_expl_id=t_arr(i) AND
          model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
          WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG)
          RETURNING model_ref_expl_id BULK COLLECT INTO temp_arr;

          --
          -- DEBUG ERROR CODE --
          --
          ERROR_CODE:=1501;

          IF temp_arr.COUNT>0 THEN
             FOR j IN temp_arr.FIRST..temp_arr.LAST
             LOOP
                v_arr(v_arr.COUNT+1):=temp_arr(j);
             END LOOP;
          END IF;
       END LOOP;

       --
       -- DEBUG ERROR CODE --
       --
       ERROR_CODE:=1502;

       delete_childs(v_arr);
    END IF;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE delete_subtree(p_model_id IN INTEGER,p_model_ref_expl_id IN INTEGER) IS
    t_arr IntArray;
BEGIN
       FOR j IN(SELECT model_ref_expl_id,ps_node_type,component_id FROM CZ_MODEL_REF_EXPLS
             WHERE model_id=p_model_id AND parent_expl_node_id=p_model_ref_expl_id AND deleted_flag=NO_FLAG)
       LOOP
          IF j.ps_node_type=CONNECTOR_TYPE THEN
             t_arr.DELETE;

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=1600;

             UPDATE CZ_MODEL_REF_EXPLS SET deleted_flag=YES_FLAG
             WHERE model_ref_expl_id IN(
             SELECT model_ref_expl_id FROM cz_model_ref_expls
             START WITH model_ref_expl_id=j.model_ref_expl_id AND deleted_flag=NO_FLAG
             CONNECT by PRIOR model_ref_expl_id=parent_expl_node_id AND deleted_flag=NO_FLAG
             AND PRIOR deleted_flag=NO_FLAG);

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=1601;
          ELSE
             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=1602;

             delete_subtree(p_model_id,j.model_ref_expl_id);

             --
             -- DEBUG ERROR CODE --
             --
             ERROR_CODE:=1603;

          END IF;
       END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/


PROCEDURE change_structure_(p_model_id IN INTEGER) IS

BEGIN
    FOR i IN(SELECT model_ref_expl_id,ps_node_type FROM CZ_MODEL_REF_EXPLS
             WHERE model_id=p_model_id AND component_id=p_model_id AND
             ps_node_type IN(CONNECTOR_TYPE,REFERENCE_TYPE) AND deleted_flag=NO_FLAG)
    LOOP
       delete_subtree(p_model_id,i.model_ref_expl_id);
    END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE change_structure(p_model_id IN INTEGER) IS

BEGIN
    FOR i IN(SELECT DISTINCT model_id FROM CZ_MODEL_REF_EXPLS
             WHERE component_id=p_model_id AND
             ps_node_type IN(CONNECTOR_TYPE,REFERENCE_TYPE) AND deleted_flag=NO_FLAG)
    LOOP
       change_structure_(i.model_id);
    END LOOP;
END;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

PROCEDURE set_Trackable_Children_Flag(p_model_id IN NUMBER) IS

    t_m_chain_tbl  IntArray;
    t_trk_tbl      IntArray;
    t_nontrk_tbl   IntArray;
    v_ib_trackable CZ_PS_NODES.ib_trackable%TYPE;

BEGIN

    SELECT DISTINCT model_id BULK COLLECT INTO t_m_chain_tbl FROM
    (SELECT DISTINCT component_id AS model_id
     FROM CZ_MODEL_REF_EXPLS WHERE model_id=p_model_id AND ps_node_type=REFERENCE_TYPE
     AND deleted_flag=NO_FLAG
     UNION
     SELECT DISTINCT model_id FROM CZ_MODEL_REF_EXPLS a
     WHERE component_id=p_model_id AND ps_node_type=REFERENCE_TYPE AND deleted_flag=NO_FLAG AND
          model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
          WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG));

     t_m_chain_tbl(t_m_chain_tbl.COUNT+1):=p_model_id;

     FOR i IN t_m_chain_tbl.First..t_m_chain_tbl.Last
     LOOP
          --
          -- set has_trackable_children to '1' for those references in explosion tree of t_m_chain_tbl(i) model
          -- which points to models which have CZ_PS_NODES.ib_trackable='1'. So here we assume
          -- that CZ_PS_NODES.ib_trackable is populated correctly by Import
          --
          UPDATE cz_model_ref_expls
          SET has_trackable_children='1'
          WHERE model_id=t_m_chain_tbl(i) AND component_id=t_m_chain_tbl(i) AND deleted_flag=NO_FLAG AND
          EXISTS(SELECT NULL FROM CZ_MODEL_REF_EXPLS m WHERE model_id=t_m_chain_tbl(i) AND ps_node_type=REFERENCE_TYPE
          AND deleted_flag=NO_FLAG AND
          EXISTS(SELECT NULL FROM CZ_PS_NODES
                 WHERE devl_project_id = m.component_id AND
                       ib_trackable = '1' AND deleted_flag = NO_FLAG));

          IF SQL%ROWCOUNT=0 THEN
             BEGIN
                 v_ib_trackable:=NO_FLAG;
                 SELECT '1' INTO v_ib_trackable FROM dual
                 WHERE EXISTS(SELECT NULL FROM CZ_PS_NODES WHERE devl_project_id=t_m_chain_tbl(i)
                 AND deleted_flag=NO_FLAG AND ib_trackable='1');
                 v_ib_trackable:='1';
                 t_trk_tbl(t_trk_tbl.COUNT+1):=t_m_chain_tbl(i);
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                     NULL;
             END;
          ELSE
             v_ib_trackable:='1';
             t_trk_tbl(t_trk_tbl.COUNT+1):=t_m_chain_tbl(i);
          END IF;

          IF v_ib_trackable=NO_FLAG THEN
             t_nontrk_tbl(t_nontrk_tbl.COUNT+1):=t_m_chain_tbl(i);
          END IF;

          UPDATE CZ_MODEL_REF_EXPLS SET has_trackable_children=v_ib_trackable
          WHERE model_id=t_m_chain_tbl(i) AND component_id=t_m_chain_tbl(i) AND deleted_flag=NO_FLAG;

    END LOOP;

    IF t_trk_tbl.COUNT>0 THEN
       FORALL i IN t_trk_tbl.First..t_trk_tbl.Last
          UPDATE CZ_MODEL_REF_EXPLS a SET has_trackable_children='1'
          WHERE component_id=t_trk_tbl(i) AND ps_node_type=REFERENCE_TYPE AND deleted_flag=NO_FLAG AND
          model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
          WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG);
    END IF;

    IF t_nontrk_tbl.COUNT>0 THEN
       FORALL i IN t_nontrk_tbl.First..t_nontrk_tbl.Last
          UPDATE CZ_MODEL_REF_EXPLS a SET has_trackable_children=NO_FLAG
          WHERE component_id=t_nontrk_tbl(i) AND ps_node_type=REFERENCE_TYPE AND deleted_flag=NO_FLAG AND
          model_id IN(SELECT object_id FROM CZ_RP_ENTRIES
          WHERE object_id=a.model_id AND object_type='PRJ' AND deleted_flag=NO_FLAG);
    END IF;


END set_Trackable_Children_Flag;

FUNCTION check_Rules_For_Ps_Node(p_ps_node_id IN  NUMBER)
  RETURN NUMBER IS

  l_template_id         NUMBER;
  l_contribute_min_flag VARCHAR2(1);
  l_contribute_max_flag VARCHAR2(1);

BEGIN

  FND_MSG_PUB.initialize;

  FOR i IN(SELECT expr_node_id,rule_id
             FROM CZ_EXPRESSION_NODES
             WHERE rule_id IN(SELECT rule_id FROM CZ_RULES
                   WHERE devl_project_id IN(SELECT devl_project_id FROM CZ_PS_NODES
                   WHERE ps_node_id=p_ps_node_id) AND deleted_flag=NO_FLAG AND disabled_flag=NO_FLAG) AND
                   ps_node_id=p_ps_node_id AND expr_type=205 AND deleted_flag=NO_FLAG)
  LOOP
    BEGIN
      SELECT template_id INTO l_template_id
        FROM CZ_EXPRESSION_NODES
       WHERE rule_id=i.rule_id AND expr_parent_id=i.expr_node_id AND
             expr_type=210 AND
             template_id in(43,44) AND deleted_flag=NO_FLAG;

      IF l_template_id=43 THEN
         l_contribute_min_flag := YES_FLAG;
      END IF;

      IF l_template_id=44 THEN
         l_contribute_max_flag := YES_FLAG;
      END IF;

      IF l_contribute_min_flag=YES_FLAG AND l_contribute_max_flag=YES_FLAG THEN
         RETURN CONTRIBUTE_TO_MINMAX;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;

  IF l_contribute_max_flag=YES_FLAG THEN
     RETURN CONTRIBUTE_TO_MAX;
  ELSIF  l_contribute_min_flag=YES_FLAG THEN
     RETURN CONTRIBUTE_TO_MIN;
  ELSE
     RETURN 0;
  END IF;

END check_Rules_For_Ps_Node;


PROCEDURE validate_Inst_Flag
(
 p_ps_node_id        IN  NUMBER,
 p_instantiable_flag IN  NUMBER,
 x_validation_flag   OUT NOCOPY VARCHAR2,
 x_run_id            OUT NOCOPY NUMBER) IS

    l_contribute        NUMBER;
    l_instantiable_flag NUMBER;

BEGIN

  FND_MSG_PUB.initialize;

  x_run_id := 0; x_validation_flag := NO_FLAG;

  SELECT instantiable_flag INTO l_instantiable_flag
    FROM CZ_PS_NODES
   WHERE ps_node_id=p_ps_node_id;

  l_contribute := check_Rules_For_Ps_Node(p_ps_node_id);

  IF l_instantiable_flag=MINMAX_EXPL_TYPE AND p_instantiable_flag=MANDATORY_EXPL_TYPE THEN
    IF l_contribute IN(CONTRIBUTE_TO_MIN,CONTRIBUTE_TO_MAX,CONTRIBUTE_TO_MINMAX) THEN
      x_validation_flag := YES_FLAG;
    END IF;
  ELSIF l_instantiable_flag=MINMAX_EXPL_TYPE AND p_instantiable_flag=OPTIONAL_EXPL_TYPE THEN
    IF l_contribute IN(CONTRIBUTE_TO_MAX) THEN
      x_validation_flag := YES_FLAG;
    END IF;
  ELSIF l_instantiable_flag=OPTIONAL_EXPL_TYPE AND p_instantiable_flag=MANDATORY_EXPL_TYPE THEN
    IF l_contribute IN(CONTRIBUTE_TO_MIN) THEN
      x_validation_flag := YES_FLAG;
    END IF;
  ELSE
    null;
 END IF;

END validate_Inst_Flag;

PROCEDURE check_Inst_Rule
(
 p_rule_id          IN  NUMBER,
 x_inst_flag        OUT NOCOPY NUMBER,
 x_sys_prop         OUT NOCOPY NUMBER,
 x_validation_flag  OUT NOCOPY VARCHAR2) IS

TYPE tExprNodeTbl IS TABLE OF cz_expression_nodes%ROWTYPE INDEX BY BINARY_INTEGER; --Not Used Anywhere, we should remove this.
TYPE tNumber IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE tNumArrayVc2 IS TABLE OF NUMBER INDEX BY VARCHAR2(15); -- New Array defined
TYPE tExprType IS TABLE OF cz_expression_nodes.expr_type%TYPE INDEX BY BINARY_INTEGER;

l_children_index tNumArrayVc2;
l_number_of_children tNumArrayVc2;
l_index_by_expr_node_id tNumArrayVc2;
l_param_index tNumber;
l_seq_nbr tNumber;
l_expr_node_id tNumber;
l_expr_parent_id tNumber;
l_expr_type tExprType;
l_template_id tNumber;
l_ps_node_id tNumber;

l_children number;

CURSOR C1 IS
SELECT param_index, seq_nbr, expr_type, expr_node_id,
expr_parent_id,template_id, ps_node_id
FROM cz_expression_nodes
WHERE rule_id = p_rule_id
AND deleted_flag = '0'
ORDER BY expr_parent_id, seq_nbr;

BEGIN

  FND_MSG_PUB.initialize;

  x_inst_flag := NULL;
  x_sys_prop := NULL;
  x_validation_flag := YES_FLAG;

  OPEN C1;
  FETCH C1 BULK COLLECT INTO l_param_index, l_seq_nbr,l_expr_type,
  l_expr_node_id, l_expr_parent_id, l_template_id, l_ps_node_id;
  CLOSE C1;
  IF (l_expr_node_id.COUNT = 0) THEN
   RETURN;
  END IF;

  FOR i IN l_expr_parent_id.FIRST..l_expr_parent_id.LAST LOOP
       IF(l_expr_parent_id(i) IS NOT NULL) THEN
         IF(l_number_of_children.EXISTS(l_expr_parent_id(i))) THEN
           l_number_of_children(l_expr_parent_id(i)) := l_number_of_children(l_expr_parent_id(i)) + 1;
         ELSE
           l_number_of_children(l_expr_parent_id(i)) := 1;
         END IF;
         IF(NOT l_children_index.EXISTS(l_expr_parent_id(i)))THEN
           l_children_index(l_expr_parent_id(i)) := i;
         END IF;
       END IF;
       --Add the indexing option.
       l_index_by_expr_node_id(l_expr_node_id(i)) := i;
  END LOOP;

  IF (l_template_id(l_expr_node_id.COUNT) = 22) THEN /* simple numeric rule */
    FOR i IN 1..l_expr_node_id.COUNT lOOP
      IF (l_param_index(i)=5) THEN
        IF (l_children_index.EXISTS(l_expr_node_id(i))) THEN
          l_children := l_number_of_children(l_expr_node_id(i));
          FOR j IN l_children_index(l_expr_node_id(i))..l_children_index(l_expr_node_id(i)) + l_children LOOP
            IF (l_expr_type(j) IN (207,210) AND l_template_id(j) IN (43,44)) THEN
              FOR k IN (SELECT instantiable_flag FROM cz_ps_nodes
                        WHERE ps_node_id = l_ps_node_id(i)
                        AND deleted_flag = NO_FLAG) LOOP
                 IF (k.instantiable_flag = '2') THEN
                    IF (l_template_id(j) = 43) THEN
                      x_sys_prop := MIN_RULE;
                    ELSE
                      x_sys_prop := MAX_RULE;
                    END IF;
                    x_inst_flag := TO_NUMBER(k.instantiable_flag);
                    x_validation_flag := NO_FLAG;
                 ELSIF (l_template_id(j) = 44 AND k.instantiable_flag = '1') THEN
                    x_sys_prop := MAX_RULE;
                    x_inst_flag := TO_NUMBER(k.instantiable_flag);
                    x_validation_flag := NO_FLAG;
                 END IF;
              END LOOP;
            END IF;
               IF (x_validation_flag = NO_FLAG) THEN
                 EXIT;
               END IF;
          END LOOP;
        END IF;
      END IF;
         IF (x_validation_flag = NO_FLAG) THEN
            EXIT;
         END IF;
    END LOOP;
  ELSIF (l_template_id(l_expr_node_id.COUNT) IS NULL) THEN  /* statement rule, Developer must call parser */
    x_validation_flag := NULL;
  END IF;
END check_Inst_Rule;

END;

/
