--------------------------------------------------------
--  DDL for Package Body CZ_RULE_TEXT_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_RULE_TEXT_GEN" AS
/* $Header: czruletxtb.pls 120.3.12010000.4 2010/05/18 20:43:01 smanna ship $ */



PROCEDURE parse_rules(p_devl_project_id IN NUMBER, p_rule_id IN NUMBER DEFAULT NULL) IS
  schema_version NUMBER;
  EXPR_OPERATOR          CONSTANT PLS_INTEGER := 200;
  EXPR_LITERAL           CONSTANT PLS_INTEGER := 201;
  EXPR_PSNODE            CONSTANT PLS_INTEGER := 205;
  EXPR_PROP              CONSTANT PLS_INTEGER := 207;
  EXPR_SYS_PROP          CONSTANT PLS_INTEGER := 210;
  EXPR_CONSTANT          CONSTANT PLS_INTEGER := 211;
  EXPR_ARGUMENT          CONSTANT PLS_INTEGER := 221;
  EXPR_TEMPLATE          CONSTANT PLS_INTEGER := 222;
  EXPR_FORALL            CONSTANT PLS_INTEGER := 223;
  EXPR_ITERATOR          CONSTANT PLS_INTEGER := 224;
  EXPR_WHERE             CONSTANT PLS_INTEGER := 225;
  EXPR_COMPATIBLE        CONSTANT PLS_INTEGER := 226;

  OPERATOR_CONTRIBUTE    CONSTANT PLS_INTEGER := 708;

  DATA_TYPE_INTEGER      CONSTANT PLS_INTEGER := 1;
  DATA_TYPE_DECIMAL      CONSTANT PLS_INTEGER := 2;
  DATA_TYPE_BOOLEAN      CONSTANT PLS_INTEGER := 3;
  DATA_TYPE_TEXT         CONSTANT PLS_INTEGER := 4;

  PS_NODE_TYPE_REFERENCE CONSTANT PLS_INTEGER := 263;
  PS_NODE_TYPE_CONNECTOR CONSTANT PLS_INTEGER := 264;

  EXPR_CONSTANT_E        CONSTANT PLS_INTEGER := 0;
  EXPR_CONSTANT_PI       CONSTANT PLS_INTEGER := 1;

  CONSTANT_PI            CONSTANT VARCHAR2(3) := 'pi';
  CONSTANT_E             CONSTANT VARCHAR2(3) := 'e';

  NewLine                CONSTANT VARCHAR2(25) := FND_GLOBAL.NEWLINE;

  CZ_UPRT_MULTIPLE_ROOTS EXCEPTION;
  CZ_UPRT_UNKNOWN_TYPE   EXCEPTION;
  CZ_UPRT_INCORRECT_PROP EXCEPTION;
  CZ_UPRT_INCORRECT_NODE EXCEPTION;

  TYPE tStringTable      IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(15);
  TYPE tStringTableIBI   IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
  TYPE tIntegerTable     IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(15);
  TYPE tIntegerTableIBI  IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
  TYPE tNumberTable      IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE tNumberTable_idx_vc2      IS TABLE OF NUMBER INDEX BY VARCHAR2(15); -- New Array defined.

  TYPE tRuleId           IS TABLE OF cz_rules.rule_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tRuleName         IS TABLE OF cz_rules.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tTemplateToken    IS TABLE OF cz_rules.template_token%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPsNodeName       IS TABLE OF cz_ps_nodes.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tPropertyName     IS TABLE OF cz_properties.name%TYPE INDEX BY BINARY_INTEGER;
  TYPE tNodeId           IS TABLE OF cz_model_ref_expls.model_ref_expl_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tParentId         IS TABLE OF cz_model_ref_expls.parent_expl_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tComponentId      IS TABLE OF cz_model_ref_expls.component_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tReferringId      IS TABLE OF cz_model_ref_expls.referring_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tNodeType         IS TABLE OF cz_model_ref_expls.ps_node_type%TYPE INDEX BY BINARY_INTEGER;

  v_RuleId               tRuleId;
  v_RuleName             tRuleName;
  v_TemplateToken        tTemplateToken;
  h_RuleName             tRuleName;
  h_TemplateToken        tTemplateToken;
  h_PsNodeName           tPsNodeName;
  h_PropertyName         tPropertyName;
  h_FullName             tIntegerTable;

  v_NodeId               tNodeId;
  v_ParentId             tParentId;
  v_ComponentId          tComponentId;
  v_ReferringId          tReferringId;
  v_NodeType             tNodeType;
  h_ParentId             tParentId;
  h_NodeType             tNodeType;
  h_ReferringId          tReferringId;
  h_ComponentId          tComponentId;
  h_ContextPath          tStringTable;
  h_ModelPath            tStringTable;
  h_NodeName             tStringTable;

  xError                 BOOLEAN;
  nDebug                 PLS_INTEGER;
---------------------------------------------------------------------------------------
PROCEDURE populate_rule_text(p_rule_id IN NUMBER) IS

  TYPE tExprId           IS TABLE OF cz_expression_nodes.expr_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParentId     IS TABLE OF cz_expression_nodes.expr_parent_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprType         IS TABLE OF cz_expression_nodes.expr_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprTemplateId   IS TABLE OF cz_expression_nodes.template_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprPsNodeId     IS TABLE OF cz_expression_nodes.ps_node_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExplNodeId       IS TABLE OF cz_expression_nodes.model_ref_expl_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprPropertyId   IS TABLE OF cz_expression_nodes.property_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataType     IS TABLE OF cz_expression_nodes.data_type%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataValue    IS TABLE OF cz_expression_nodes.data_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprDataNumValue IS TABLE OF cz_expression_nodes.data_num_value%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprParamIndex   IS TABLE OF cz_expression_nodes.param_index%TYPE INDEX BY BINARY_INTEGER;
  TYPE tExprArgumentName IS TABLE OF cz_expression_nodes.argument_name%TYPE INDEX BY BINARY_INTEGER;

  TYPE tCDLIndex         IS TABLE OF NUMBER INDEX BY BINARY_INTEGER; -- Added for Bug 9650435
  v_CDLIndex             tCDLIndex;                                  -- Added for Bug 9650435

  v_ExprId               tExprId;
  v_ExprParentId         tExprParentId;
  v_ExprType             tExprType;
  v_ExprTemplateId       tExprTemplateId;
  v_ExprPsNodeId         tExprPsNodeId;
  v_ExplNodeId           tExplNodeId;
  v_ExprPropertyId       tExprPropertyId;
  v_ExprDataType         tExprDataType;
  v_ExprDataValue        tExprDataValue;
  v_ExprDataNumValue     tExprDataNumValue;
  v_ExprParamIndex       tExprParamIndex;
  v_ExprArgumentName     tExprArgumentName;

  vi_ExprId              tExprId;
  vi_Name                tStringTableIBI;
  vi_Depth               tIntegerTableIBI;
  vi_Occurrence          tIntegerTable;
  vi_Pos                 tIntegerTableIBI;

  v_ChildrenIndex        tNumberTable_idx_vc2;
  v_NumberOfChildren     tNumberTable_idx_vc2;
  v_RuleText             VARCHAR2(32767);
  errmsg1                VARCHAR2(2000);
  errmsg2                VARCHAR2(2000);
  rootIndex              PLS_INTEGER;
  isCompatible           PLS_INTEGER := 0;
  isForall               PLS_INTEGER := 0;
  currentLevel           PLS_INTEGER := 0;
  v_pres_flag            number;
---------------------------------------------------------------------------------------
  FUNCTION parse_expr_node(j IN PLS_INTEGER) RETURN VARCHAR2 IS

    v_RuleText           VARCHAR2(32767);
    v_Name               VARCHAR2(2000);
    v_Index              PLS_INTEGER;
    v_aux                PLS_INTEGER;
    v_token              cz_rules.template_token%TYPE;
---------------------------------------------------------------------------------------
    FUNCTION generate_model_path(p_ps_node_id IN NUMBER) RETURN VARCHAR2 IS
      v_Name             VARCHAR2(32767);
    BEGIN

      IF(h_ModelPath.EXISTS(p_ps_node_id))THEN RETURN h_ModelPath(p_ps_node_id); END IF;

      FOR c_name IN (SELECT name, parent_id FROM cz_ps_nodes
                      START WITH ps_node_id = p_ps_node_id
                    CONNECT BY PRIOR parent_id = ps_node_id) LOOP

        IF(v_Name IS NULL)THEN

          v_Name := '''' || c_name.name || '''';
          h_NodeName(p_ps_node_id) := v_Name;

          FOR c_node IN (SELECT NULL FROM cz_ps_nodes WHERE deleted_flag = '0'
                            AND devl_project_id = p_devl_project_id
                            AND name = c_name.name
                            AND ps_node_id <> p_ps_node_id)LOOP
            h_FullName(p_ps_node_id) := 1;
            EXIT;
          END LOOP;
          FOR c_node IN (SELECT NULL FROM cz_ps_nodes WHERE deleted_flag = '0'
                            AND devl_project_id IN
                              (SELECT component_id FROM cz_model_ref_expls
                                WHERE deleted_flag = '0'
                                  AND model_id = p_devl_project_id
                                  AND ps_node_type IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))
                            AND name = c_name.name)LOOP
            h_FullName(p_ps_node_id) := 1;
            EXIT;
          END LOOP;
        ELSIF(c_name.parent_id IS NOT NULL)THEN -- This is to exclude the root model name from the path.
          v_Name := '''' || c_name.name || '''' || FND_GLOBAL.LOCAL_CHR(8) || v_Name;
        END IF;
      END LOOP;

      h_ModelPath(p_ps_node_id) := v_Name;
     RETURN v_Name;
    END generate_model_path;
---------------------------------------------------------------------------------------
    FUNCTION generate_context_path(p_expl_id IN NUMBER) RETURN VARCHAR2 IS
      v_Node             NUMBER;
      v_Name             VARCHAR2(32767);
      v_ModelName        VARCHAR2(32767);
    BEGIN

      --The path cashing is disabled because now it depends not only on expl_id, but also on the
      --participating node (see comment below).

      --IF(h_ContextPath.EXISTS(p_expl_id))THEN RETURN h_ContextPath(p_expl_id); END IF;

      v_Node := p_expl_id;

      WHILE(v_Node IS NOT NULL)LOOP

        IF(h_NodeType(v_Node) IN (PS_NODE_TYPE_REFERENCE, PS_NODE_TYPE_CONNECTOR))THEN

          v_ModelName := NULL;

          IF(h_NodeType(v_Node) = PS_NODE_TYPE_CONNECTOR AND

             --We do not need to add the connected model name if the participating node is the model
             --itself, otherwise it will be twice in the path.

             h_ComponentId(v_Node) <> v_ExprPsNodeId(j))THEN

            BEGIN

              SELECT name INTO v_ModelName FROM cz_ps_nodes
               WHERE ps_node_id = h_ComponentId(v_Node);
            EXCEPTION
              WHEN OTHERS THEN
                NULL;
            END;
          END IF;

          IF(v_ModelName IS NOT NULL)THEN v_ModelName := FND_GLOBAL.LOCAL_CHR(7) || '''' || v_ModelName || ''''; END IF;

          IF(v_Name IS NULL)THEN v_Name := generate_model_path(h_ReferringId(v_Node)) || v_ModelName;
          ELSE v_Name := generate_model_path(h_ReferringId(v_Node)) || v_ModelName || FND_GLOBAL.LOCAL_CHR(8) || v_Name;
          END IF;
        END IF;

        v_Node := h_ParentId(v_Node);
      END LOOP;

      --h_ContextPath(p_expl_id) := v_Name;
     RETURN v_Name;
    END generate_context_path;
---------------------------------------------------------------------------------------
    FUNCTION generate_name RETURN VARCHAR2 IS
      v_expl_id          NUMBER := v_ExplNodeId(j);
      v_this             VARCHAR2(32767);
      v_that             VARCHAR2(32767);
      v_subthis          VARCHAR2(32767);
      v_subthat          VARCHAR2(32767);
      v_name             VARCHAR2(32767);
      v_level            PLS_INTEGER;
      v_depth            PLS_INTEGER := 0;
    BEGIN

      IF(v_ExprPsNodeId(j) = h_ReferringId(v_expl_id))THEN
        v_expl_id := h_ParentId(v_expl_id);
      END IF;

      IF(v_expl_id IS NOT NULL)THEN v_this := generate_context_path(v_expl_id); END IF;
      v_name := generate_model_path(v_ExprPsNodeId(j));

      IF(v_this IS NULL)THEN
        IF(NOT h_FullName.EXISTS(v_ExprPsNodeId(j)))THEN v_name := h_NodeName(v_ExprPsNodeId(j)); END IF;
      ELSE

        FOR i IN 1..v_NodeId.COUNT LOOP

          IF(h_ComponentId(v_NodeId(i)) = h_ComponentId(v_expl_id) AND v_NodeId(i) <> v_expl_id)THEN

            v_that := generate_context_path(v_NodeId(i));
            v_level := 1;

            LOOP

              v_subthis := SUBSTR(v_this, INSTR(v_this, FND_GLOBAL.LOCAL_CHR(8), -1, v_level) + 1);
              v_subthat := SUBSTR(v_that, INSTR(v_that, FND_GLOBAL.LOCAL_CHR(8), -1, v_level) + 1);

              IF(v_subthis = v_this)THEN EXIT; END IF;
              IF(v_subthat = v_that)THEN v_Level := v_Level + 1; EXIT; END IF;
              IF(v_subthis <> v_subthat)THEN EXIT; END IF;

              v_level := v_level + 1;
            END LOOP;

            IF(v_level > v_depth)THEN v_depth := v_level; END IF;
          END IF;
        END LOOP;

        IF(v_depth = 0)THEN

          --Bug #4590481 - in this case we also need to concatenate the path. If the full path is not
          --required, the second line will reset it to just the node name.

          v_name := v_this || FND_GLOBAL.LOCAL_CHR(8) || v_name;
          IF(NOT h_FullName.EXISTS(v_ExprPsNodeId(j)))THEN v_name := h_NodeName(v_ExprPsNodeId(j)); END IF;
        ELSE v_name := SUBSTR(v_this, INSTR(v_this, FND_GLOBAL.LOCAL_CHR(8), -1, v_depth) + 1) || FND_GLOBAL.LOCAL_CHR(8) || v_name;
        END IF;
      END IF;

      v_Index := vi_ExprId.COUNT + 1;
      vi_ExprId(v_Index) := v_ExprId(j);

      v_Level := 1;
      WHILE(INSTR(v_name, FND_GLOBAL.LOCAL_CHR(8), 1, v_Level) <> 0)LOOP v_Level := v_Level + 1; END LOOP;
      vi_Depth(v_Index) := v_Level;

      v_name := REPLACE(v_name, '''' || FND_GLOBAL.LOCAL_CHR(7) || '''', '''.''');
      v_name := REPLACE(v_name, '''' || FND_GLOBAL.LOCAL_CHR(8) || '''', '''.''');

      v_aux := 1;

      FOR i IN 1..vi_Name.COUNT LOOP
        IF(v_name = vi_Name(i))THEN v_aux := v_aux + 1; END IF;
      END LOOP;

      vi_Occurrence(v_Index) := v_aux;
      vi_Name(v_Index) := v_name;

     RETURN v_name;
    END generate_name;
---------------------------------------------------------------------------------------
  BEGIN

    currentLevel := currentLevel + 1;

    IF(v_ExprType(j) = EXPR_OPERATOR)THEN

nDebug := 1000;

      --First correct a data_type upgrade problem from czrules1.sql. This is an operator, its children
      --has not been generated into text yet. We will update data_type and data_num_value for children
      --in memory, if necessary, so that children will or will not be enclosed in quotes correctly. At
      --the end, we physically update the columns in cz_expression_nodes.

      IF(v_ExprTemplateId(j) IN
          (318,320,321,322,323,350,351,352,353,399,401,402,403,
           404,405,406,407,408,409,410,411,412,413,414,415,416,
           417,418,430,431,432,433,434,435,436,437,438,439,551)
         AND v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        --This is one of the operators with only numeric operands or = or <>.

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          IF(v_ExprType(v_Index) = EXPR_LITERAL AND v_ExprDataType(v_Index) IS NULL AND
             v_ExprDataNumValue(v_Index) IS NULL)THEN

            --This is a literal child of the operator with undefined data_type and data_num_value.
            --Here we fix data only for such operands.

            BEGIN

              v_ExprDataNumValue(v_Index) := TO_NUMBER(v_ExprDataValue(v_Index));
              v_ExprDataType(v_Index) := DATA_TYPE_DECIMAL;
              IF(v_ExprTemplateId(j) = 551)THEN v_ExprDataType(v_Index) := DATA_TYPE_INTEGER; END IF;

            EXCEPTION
              WHEN OTHERS THEN
                v_ExprDataType(v_Index) := DATA_TYPE_TEXT;
            END;
          END IF;

          v_Index := v_Index + 1;
          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                     (v_ExprParentId(v_Index) IS NULL) OR
                     (v_ExprParentId(v_Index) <> v_ExprId(j));
        END LOOP;
      END IF;

      --Done with the data fix for data_type, data_num_value population after czrules1.sql.

      v_token := h_TemplateToken(v_ExprTemplateId(j));

      IF((v_token IS NULL AND UPPER(h_RuleName(v_ExprTemplateId(j))) NOT IN ('CONTRIBUTESTO', 'CONSUMESFROM', 'ADDSTO')) OR
          v_NumberOfChildren(v_ExprId(j)) > 2)THEN

        v_RuleText := NVL(h_RuleName(v_ExprTemplateId(j)), v_token) || '(';

        IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

          v_Index := v_ChildrenIndex(v_ExprId(j));

          LOOP

            v_RuleText := v_RuleText || parse_expr_node(v_Index);
            v_Index := v_Index + 1;

            EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                      (v_ExprParentId(v_Index) IS NULL) OR
                      (v_ExprParentId(v_Index) <> v_ExprId(j));

            v_RuleText := v_RuleText || ', ';
          END LOOP;
        END IF;

        v_RuleText := v_RuleText || ')';
      ELSE

        IF(v_token IS NULL)THEN v_token := h_RuleName(v_ExprTemplateId(j)); END IF;

        IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

          v_Index := v_ChildrenIndex(v_ExprId(j));

          IF(v_NumberOfChildren(v_ExprId(j)) = 2)THEN
            IF(UPPER(v_token) = 'CONTRIBUTESTO')THEN

              v_RuleText := 'Contribute ' || parse_expr_node(v_Index) || ' TO';
              v_token := NULL;
            ELSIF(UPPER(v_token) = 'ADDSTO')THEN

              v_RuleText := 'ADD ' || parse_expr_node(v_Index) || ' TO';
              v_token := NULL;
            ELSE

              v_RuleText := parse_expr_node(v_Index) || ' ';
            END IF;

            v_Index := v_Index + 1;
          END IF;

          v_RuleText := v_RuleText || v_token || ' ' || parse_expr_node(v_Index);
        ELSE

          v_RuleText := v_token;
        END IF;

        IF((isForall = 0 AND currentLevel > 1) OR (isForall = 1 AND currentLevel > 2))THEN

            v_RuleText := '(' || v_RuleText || ')';
        END IF;
      END IF;
    ELSIF(v_ExprType(j) = EXPR_LITERAL)THEN

nDebug := 1001;

      IF(v_ExprDataType(j) IN (DATA_TYPE_INTEGER, DATA_TYPE_DECIMAL))THEN

        v_RuleText := v_ExprDataNumValue(j);
      ELSIF(v_ExprDataType(j) = DATA_TYPE_TEXT OR (v_ExprDataType(j) IS NULL AND v_ExprDataNumValue(j) IS NULL))THEN

        v_RuleText := '"' || v_ExprDataValue(j) || '"';
      ELSIF(v_ExprDataType(j) = DATA_TYPE_BOOLEAN) THEN
        IF(v_ExprDataValue(j)=1) THEN
	    v_RuleText := 'TRUE ' ;
        ELSE
	    v_RuleText := 'FALSE ';

	END IF;
      ELSE

        v_RuleText := v_ExprDataValue(j);
      END IF;

    ELSIF(v_ExprType(j) = EXPR_PSNODE)THEN

nDebug := 1002;

      v_RuleText := generate_name;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        WHILE(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j))LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;
        END LOOP;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_PROP)THEN

nDebug := 1003;

      IF(NOT h_PropertyName.EXISTS(v_ExprPropertyId(j)))THEN

        --We don't want to account for deleted_flag in this query because we want to parse a rule even
        --if it refers to a deleted property instead of ignoring the rule.

        BEGIN
          SELECT name INTO v_Name FROM cz_properties
           WHERE property_id = v_ExprPropertyId(j);

          h_PropertyName(v_ExprPropertyId(j)) := v_Name;

        EXCEPTION
          WHEN OTHERS THEN
            errmsg1 := TO_CHAR(v_ExprId(j));
            errmsg2 := TO_CHAR(v_ExprPropertyId(j));
            RAISE CZ_UPRT_INCORRECT_PROP;
        END;
      ELSE

        v_Name := h_PropertyName(v_ExprPropertyId(j));
      END IF;

      v_Name := '"' || v_Name || '"';
      v_RuleText := '.Property(' || v_Name || ')';
      v_aux := 1;

      FOR i IN 1..vi_Name.COUNT LOOP
        IF(v_Name = vi_Name(i))THEN v_aux := v_aux + 1; END IF;
      END LOOP;

      v_Index := vi_ExprId.COUNT + 1;
      vi_ExprId(v_Index) := v_ExprId(j);
      vi_Occurrence(v_Index) := v_aux;
      vi_Depth(v_Index) := 0;
      vi_Name(v_Index) := v_Name;

    ELSIF(v_ExprType(j) = EXPR_SYS_PROP)THEN

nDebug := 1004;

      IF(isCompatible = 0)THEN v_RuleText := '.' || h_RuleName(v_ExprTemplateId(j)) || '()'; END IF;

    ELSIF(v_ExprType(j) = EXPR_ARGUMENT)THEN

nDebug := 1005;

      v_RuleText := v_ExprArgumentName(j);

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        WHILE(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j))LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;
        END LOOP;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_TEMPLATE)THEN

nDebug := 1006;

      v_RuleText := '@' || h_RuleName(v_ExprTemplateId(j));

    ELSIF(v_ExprType(j) = EXPR_FORALL)THEN

nDebug := 1007;

      isForall := 1;
      v_RuleText := ' FOR ALL' || NewLine;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j)) + v_NumberOfChildren(v_ExprId(j)) - 1;

        IF(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j) AND
           v_ExprType(v_Index) NOT IN (EXPR_ITERATOR, EXPR_WHERE))THEN

          v_RuleText := parse_expr_node(v_Index) || v_RuleText;
        END IF;

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;

          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                    (v_ExprType(v_Index) NOT IN (EXPR_ITERATOR, EXPR_WHERE)) OR
                    (v_ExprParentId(v_Index) IS NULL) OR
                    (v_ExprParentId(v_Index) <> v_ExprId(j));

          IF(v_ExprType(v_Index - 1) = EXPR_ITERATOR AND v_ExprType(v_Index) = EXPR_ITERATOR)THEN
            v_RuleText := v_RuleText || ',';
          END IF;
          v_RuleText := v_RuleText || NewLine;
        END LOOP;
      END IF;
      isForall := 0;

    ELSIF(v_ExprType(j) = EXPR_ITERATOR)THEN

nDebug := 1008;

      IF(isCompatible = 1)THEN v_RuleText := v_ExprArgumentName(j) || ' OF ';
      ELSE v_RuleText := v_ExprArgumentName(j) || ' IN {'; END IF;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;

          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                    (v_ExprParentId(v_Index) IS NULL) OR
                    (v_ExprParentId(v_Index) <> v_ExprId(j));

          v_RuleText := v_RuleText || ', ';
        END LOOP;
      END IF;

      IF(isCompatible = 0)THEN v_RuleText := v_RuleText || '}'; END IF;

    ELSIF(v_ExprType(j) = EXPR_WHERE)THEN

nDebug := 1009;

      v_RuleText := ' WHERE' || NewLine;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        WHILE(v_ExprParentId.EXISTS(v_Index) AND v_ExprParentId(v_Index) = v_ExprId(j))LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;
        END LOOP;
      END IF;

    ELSIF(v_ExprType(j) = EXPR_COMPATIBLE)THEN

nDebug := 1010;

      isCompatible := 1;
      v_RuleText := 'COMPATIBLE' || NewLine;

      IF(v_ChildrenIndex.EXISTS(v_ExprId(j)))THEN

        v_Index := v_ChildrenIndex(v_ExprId(j));

        LOOP

          v_RuleText := v_RuleText || parse_expr_node(v_Index);
          v_Index := v_Index + 1;

          EXIT WHEN (NOT v_ExprParentId.EXISTS(v_Index)) OR
                    (v_ExprParentId(v_Index) IS NULL) OR
                    (v_ExprParentId(v_Index) <> v_ExprId(j));

          IF(v_ExprType(v_Index - 1) = EXPR_ITERATOR AND v_ExprType(v_Index) = EXPR_ITERATOR)THEN
            v_RuleText := v_RuleText || ',';
          END IF;
          v_RuleText := v_RuleText || NewLine;
        END LOOP;
      END IF;
      isCompatible := 0;
    ELSIF(v_ExprType(j) = EXPR_CONSTANT)THEN

      IF(v_ExprTemplateId(j) =  EXPR_CONSTANT_E)THEN

        v_RuleText := CONSTANT_E;
      ELSE

        v_RuleText := CONSTANT_PI;
      END IF;
    ELSE
      errmsg1 := TO_CHAR(v_ExprId(j));
      errmsg2 := TO_CHAR(v_ExprType(j));
      RAISE CZ_UPRT_UNKNOWN_TYPE;
    END IF;

   currentLevel := currentLevel - 1;
   RETURN v_RuleText;
  END parse_expr_node;
---------------------------------------------------------------------------------------


BEGIN

nDebug := 2;

   v_pres_flag:=1;

   SELECT presentation_flag
      INTO v_pres_flag
   FROM cz_rules ru
   WHERE rule_id = p_rule_id
   AND(rule_text IS NULL
     OR EXISTS
      (SELECT 1
       FROM cz_expression_nodes
       WHERE rule_id = ru.rule_id
       AND template_id IN(712,    714 , 552 , 2))
     );

   if v_pres_flag=1  then
	return;
   end if;
   --Read the expression into memory.

   SELECT expr_node_id, expr_parent_id, expr_type, template_id,
          ps_node_id, model_ref_expl_id, property_id, data_type, data_value, data_num_value,
          param_index, argument_name
     BULK COLLECT INTO v_ExprId, v_ExprParentId, v_ExprType, v_ExprTemplateId,
                       v_ExprPsNodeId, v_ExplNodeId, v_ExprPropertyId, v_ExprDataType, v_ExprDataValue, v_ExprDataNumValue,
                       v_ExprParamIndex, v_ExprArgumentName
     FROM cz_expression_nodes
    WHERE rule_id = p_rule_id
      AND expr_type <> 208
      AND deleted_flag = '0'
    ORDER BY expr_parent_id, seq_nbr;

   rootIndex := 0;

   FOR i IN 1..v_ExprId.COUNT LOOP

     IF(NOT v_NumberOfChildren.EXISTS(v_ExprId(i)))THEN v_NumberOfChildren(v_ExprId(i)) := 0; END IF;

     IF(v_ExprParentId(i) IS NOT NULL)THEN

       IF(v_NumberOfChildren.EXISTS(v_ExprParentId(i)))THEN
         v_NumberOfChildren(v_ExprParentId(i)) := v_NumberOfChildren(v_ExprParentId(i)) + 1;
       ELSE
         v_NumberOfChildren(v_ExprParentId(i)) := 1;
       END IF;

       IF(NOT v_ChildrenIndex.EXISTS(v_ExprParentId(i)))THEN
         v_ChildrenIndex(v_ExprParentId(i)) := i;
       END IF;
     ELSE

       --IF(rootIndex = 0)THEN rootIndex := i; ELSE RAISE CZ_UPRT_MULTIPLE_ROOTS; END IF;
       -- Bug 9650435 - Fix - Start
       rootIndex := rootIndex + 1;
       v_CDLIndex(rootIndex) := i;
       -- Bug 9650435 - Fix - End
     END IF;
   END LOOP;

nDebug := 3;

   -- v_RuleText := parse_expr_node(rootIndex);
   -- Bug 9650435 Fix  - Start
   v_RuleText := '';
   FOR i IN 1..v_CDLIndex.COUNT LOOP
      IF (i <> v_CDLIndex.COUNT) THEN
         v_RuleText := v_RuleText || parse_expr_node(v_CDLIndex(i)) || ';' || NewLine;
      ELSE
         v_RuleText := v_RuleText || parse_expr_node(v_CDLIndex(i)) || ';';
      END IF;
   END LOOP;
   -- Bug 9650435 Fix 1 - End
   FOR i IN 1..vi_ExprId.COUNT LOOP

     --We are trying to find the position of an occurence of the name in the text. We need to
     --handle the situation when the name can be a part of another name. For example, if both
     --'A'.'B'.'C' and 'A'.'B' are in the text, we should skip 'A'.'B' found as a part of
     --'A'.'B'.'C'. So, when an occurence of 'A'.'B' is found, we check the next symbol, and
     --if it is '.''', we need to keep looking. Note, that we can't check for just '.' as
     --there may be a property following the name.

     currentLevel := 0;

     FOR j IN 1..vi_Occurrence(i) LOOP

       currentLevel := INSTR(v_RuleText, vi_Name(i), currentLevel + 1);

       WHILE(SUBSTR(v_RuleText, currentLevel + LENGTH(vi_Name(i)), 2) = '.''')LOOP

         currentLevel := INSTR(v_RuleText, vi_Name(i), currentLevel + 1);
       END LOOP;
     END LOOP;

     vi_Pos(i) := currentLevel;
   END LOOP;

   FORALL i IN 1..vi_ExprId.COUNT
     UPDATE cz_expression_nodes SET
       display_node_depth = vi_Depth(i),
       source_offset = vi_Pos(i),
       source_length = LENGTH(vi_Name(i))
     WHERE expr_node_id = vi_ExprId(i);

   --We need to update these columns as they may have been corrected in parse_expr_node procedure.

   FORALL i IN 1..v_ExprId.COUNT
     UPDATE cz_expression_nodes SET
       data_type = v_ExprDataType(i),
       data_num_value = v_ExprDataNumValue(i)
     WHERE expr_node_id = v_ExprId(i);

   UPDATE cz_rules SET rule_text = v_RuleText WHERE rule_id = p_rule_id;

EXCEPTION
  WHEN CZ_UPRT_MULTIPLE_ROOTS THEN
    xError := cz_utils.report('rule_id = ' || p_rule_id || ': more than one record with null expr_parent_id', 1, 'CDL Rule Upgrade', 13000);
  WHEN CZ_UPRT_UNKNOWN_TYPE THEN
    xError := cz_utils.report('rule_id = ' || p_rule_id || ', expr_node_id = ' || errmsg1 || ': unknown expression type, expr_type = ' || errmsg2, 1, 'CDL Rule Upgrade', 13000);
  WHEN CZ_UPRT_INCORRECT_PROP THEN
    xError := cz_utils.report('rule_id = ' || p_rule_id || ', expr_node_id = ' || errmsg1 || ': no such property, property_id = ' || errmsg2, 1, 'CDL Rule Upgrade', 13000);
  WHEN CZ_UPRT_INCORRECT_NODE THEN
    xError := cz_utils.report('rule_id = ' || p_rule_id || ', expr_node_id = ' || errmsg1 || ': no such node, ps_node_id = ' || errmsg2, 1, 'CDL Rule Upgrade', 13000);
  WHEN OTHERS THEN
    errmsg1 := SQLERRM;
    xError := cz_utils.report('rule_id = ' || p_rule_id || ' at ' || nDebug || ': ' || errmsg1, 1, 'CDL Rule Upgrade', 13000);
END populate_rule_text;
---------------------------------------------------------------------------------------
BEGIN


DECLARE
  xERROR  BOOLEAN;
BEGIN

  SELECT TO_NUMBER(value) INTO schema_version
    FROM cz_db_settings
   WHERE setting_id = 'MAJOR_VERSION'
     AND section_name = 'SCHEMA';

EXCEPTION
  WHEN OTHERS THEN
    xERROR:=CZ_UTILS.REPORT('Unable to resolve schema version: ' || SQLERRM, 1, 'czrules2.sql' , 13000);
    RAISE;
END;


nDebug := 1;

   --Initialize the rule data for resolving token names.

   SELECT rule_id, name, template_token BULK COLLECT INTO v_RuleId, v_RuleName, v_TemplateToken
     FROM cz_rules
    WHERE deleted_flag = '0'
      AND disabled_flag = '0'
      AND rule_id < 1000;

   FOR i IN 1..v_RuleId.COUNT LOOP

     h_RuleName(v_RuleId(i)) := v_RuleName(i);
     h_TemplateToken(v_RuleId(i)) := v_TemplateToken(i);
   END LOOP;

   --Intitialize the explosion data.

   SELECT model_ref_expl_id, parent_expl_node_id, component_id, referring_node_id, ps_node_type
     BULK COLLECT INTO v_NodeId, v_ParentId, v_ComponentId, v_ReferringId, v_NodeType
     FROM cz_model_ref_expls
    WHERE model_id = p_devl_project_id
      AND deleted_flag = '0';

   FOR i IN 1..v_NodeId.COUNT LOOP

     h_ParentId(v_NodeId(i)) := v_ParentId(i);
     h_NodeType(v_NodeId(i)) := v_NodeType(i);
     h_ReferringId(v_NodeId(i)) := v_ReferringId(i);
     h_ComponentId(v_NodeId(i)) := v_ComponentId(i);
   END LOOP;

   IF(p_rule_id IS NOT NULL)THEN

     populate_rule_text(p_rule_id);
   ELSE

     FOR c_rule IN (SELECT rule_id FROM cz_rules
                     WHERE deleted_flag = '0'
                       AND devl_project_id = p_devl_project_id
                       AND rule_type IN (100, 200)) LOOP
       populate_rule_text(c_rule.rule_id);
     END LOOP;
   END IF;
END parse_rules;

END cz_rule_text_gen ;

/
