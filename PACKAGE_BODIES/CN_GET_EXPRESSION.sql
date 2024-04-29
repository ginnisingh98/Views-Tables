--------------------------------------------------------
--  DDL for Package Body CN_GET_EXPRESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_EXPRESSION" AS
-- $Header: cngtexpb.pls 120.1 2005/07/18 03:28:31 rramakri noship $
--==========================================================================
  -- Procedure Name:    BUILD_TABLE
  -- Purpose
--==========================================================================
 PROCEDURE build_table (x_rule_id IN cn_rule_attr_expression.rule_id%TYPE,
                         x_usage   IN VARCHAR2,
			 x_org_id  IN cn_rule_attr_expression.org_id%TYPE) IS


    CURSOR get_rae (x_rule_id NUMBER,x_org_id NUMBER) IS
      SELECT operand1, operand1_ra_rae_flag,
             operand2, operand2_ra_rae_flag,
             operator
      FROM   cn_rule_attr_expression
      WHERE  rule_id = x_rule_id and org_id=x_org_id
      ORDER BY operand_expression_id;

    CURSOR get_ra_descriptive (x_ra_id NUMBER,x_org_id NUMBER) IS
      SELECT descriptive_rule_attribute
      FROM   cn_rule_attributes_desc_v
      WHERE  attribute_rule_id = x_ra_id
      and org_id=x_org_id;

    get_ra_descriptive_rec get_ra_descriptive%ROWTYPE;

    l_lexpr              VARCHAR2(16000);
    l_rexpr              VARCHAR2(16000);
    l_operator           cn_lookups.meaning%TYPE;
  BEGIN

    g_intermediate_expr := 0;
    FOR i IN get_rae(x_rule_id,x_org_id)
    LOOP
      IF i.operand1_ra_rae_flag = 'RA'
      THEN
	OPEN get_ra_descriptive(i.operand1,x_org_id);
        FETCH get_ra_descriptive INTO get_ra_descriptive_rec;
        l_lexpr := '('||get_ra_descriptive_rec.descriptive_rule_attribute||')';
        CLOSE get_ra_descriptive;
      ELSIF i.operand1_ra_rae_flag = 'RAE'
      THEN
        l_lexpr := g_rae(i.operand1);
      END IF;

      IF i.operand2_ra_rae_flag = 'RA'
      THEN
        OPEN get_ra_descriptive(i.operand2,x_org_id);
        FETCH get_ra_descriptive INTO get_ra_descriptive_rec;
        l_rexpr := '('||get_ra_descriptive_rec.descriptive_rule_attribute||')';
        CLOSE get_ra_descriptive;
      ELSIF i.operand2_ra_rae_flag = 'RAE'
      THEN
        l_rexpr := g_rae(i.operand2);
      END IF;

      IF x_usage = 'Code Generation'
      THEN
        IF i.operator = 1
        THEN
          l_operator := 'OR';
        ELSIF i.operator = 0
        THEN
          l_operator := 'AND';
        END IF;
      ELSIF x_usage = 'Expression Display'
      THEN
        IF i.operator = 1
        THEN
          l_operator := cn_api.get_lkup_meaning('OR', 'Expression Messages');
        ELSIF i.operator = 0
        THEN
          l_operator := cn_api.get_lkup_meaning('AND', 'Expression Messages');
        END IF;
      END IF;

      g_intermediate_expr := g_intermediate_expr + 1;
      --g_rae(g_intermediate_expr) := '('||l_lexpr||' '||l_operator||' '||l_rexpr||')';
      g_rae(g_intermediate_expr) :=  substr('('||l_lexpr||' '||l_operator||' '||l_rexpr||')', 1, 1900);
      ----------problem is out here bcos of the length of the expression.
    END LOOP;

  END;

 --=======================================================================
  -- Procedure Name:    MAIN
  -- Purpose
 --=======================================================================
  PROCEDURE main(x_rule_id    IN  cn_rule_attr_expression.rule_id%TYPE,
                 x_org_id     IN  cn_rule_attr_expression.org_id%TYPE,
                 x_usage      IN  VARCHAR2,
		 x_expression OUT NOCOPY VARCHAR2) IS
  BEGIN
  --Call build_table procedure to build a PL/SQL table of intermediate
  --results or rule attribute expressions.
    build_table ( x_rule_id, x_usage,x_org_id );

    -- Added by Kumar.S
    if g_rae.count > 0 then
          x_expression := substr(g_rae(g_intermediate_expr),1,1900);
    end if;


    UPDATE cn_attribute_rules
       SET expression = substr(x_expression, 1, 1900)
     WHERE rule_id = x_rule_id and org_id=x_org_id;
    commit;

EXCEPTION
    when no_data_found then
     null;
  END main;

PROCEDURE deleteExpression(x_rule_id    IN  cn_attribute_rules.rule_id%TYPE,
                           x_org_id     IN  cn_attribute_rules.org_id%TYPE) IS
BEGIN
  UPDATE cn_attribute_rules set expression = ' '  WHERE rule_id = x_rule_id and org_id=x_org_id;
  commit;
END deleteExpression;

END cn_get_expression;

/
