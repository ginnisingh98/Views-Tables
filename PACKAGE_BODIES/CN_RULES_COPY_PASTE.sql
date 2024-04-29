--------------------------------------------------------
--  DDL for Package Body CN_RULES_COPY_PASTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULES_COPY_PASTE" AS
-- $Header: cncaprhb.pls 120.1.12010000.2 2019/04/15 06:30:28 tpodila ship $
-- Package Body Name
--   cn_rules_copy_paste
-- Purpose
--   This package is used by Oracle Sales Compensation to copy and paste
--   rules between rulesets or between different branches of the same ruleset
-- History
--   05/05/1998				Ramkarthik Kalyanasundaram


-----------------------------------------------------------------------+
--Procedure Name: find_descendant_rules				     --+
--Purpose							     --+
--To find all the rules that are under this rule in a given rule set --+
-----------------------------------------------------------------------+

PROCEDURE find_descendant_rules(x_start_rule_id    IN	  NUMBER,
                                x_from_ruleset_id  IN	  NUMBER,
                                x_rules_to_paste   IN OUT NOCOPY rules_to_paste_type,
                                x_rtp_index        IN OUT NOCOPY NUMBER,
				x_parent_rule      IN OUT NOCOPY parent_rule_type) IS

  l_dummy NUMBER;

  CURSOR rules IS
    SELECT rule_id
      FROM cn_rules_hierarchy crh
     WHERE crh.parent_rule_id = x_start_rule_id
       AND ruleset_id = x_from_ruleset_id;

BEGIN

  FOR each_rule IN rules LOOP
    EXIT WHEN rules%NOTFOUND;
    x_rtp_index := x_rtp_index + 1;
    SELECT *
      INTO x_rules_to_paste(x_rtp_index)
      FROM cn_rules
     WHERE rule_id = each_rule.rule_id;

    SELECT *
      INTO x_parent_rule(x_rtp_index)
      FROM cn_rules_hierarchy
     WHERE rule_id = each_rule.rule_id;

    SELECT count(*)
      INTO l_dummy
      FROM cn_rules_hierarchy
     WHERE parent_rule_id = each_rule.rule_id;
    IF l_dummy > 0 THEN
      find_descendant_rules(each_rule.rule_id, x_from_ruleset_id,
			    x_rules_to_paste, x_rtp_index,
			    x_parent_rule);
    END IF;
  END LOOP;

END;

-----------------------------------------------------------------------+
--Procedure Name: paste_rules					     --+
--Purpose							     --+
--To copy all the given rules to another ruleset or another branch   --+
--of the same ruleset						     --+
-----------------------------------------------------------------------+

PROCEDURE paste_rules( x_rules_to_paste IN	rules_to_paste_type,
                       x_new_rule_id    IN OUT NOCOPY new_rule_id_type,
                       x_to_ruleset_id	IN	NUMBER,
                       x_rtp_index	IN	NUMBER,
		       x_parent_rule	IN OUT NOCOPY parent_rule_type) IS

  l_dummy NUMBER;
BEGIN

  SELECT count(*)
    INTO l_dummy
    FROM cn_rules_hierarchy crh
   WHERE parent_rule_id = x_parent_rule(1).parent_rule_id;

  x_parent_rule(1).sequence_number := l_dummy + 1;
  FOR v_counter IN 1 .. x_rtp_index LOOP
    cn_syin_rules_pkg.default_row(l_dummy);
    x_new_rule_id(v_counter) := l_dummy;
    cn_syin_rules_pkg.insert_row(x_new_rule_id(v_counter),
				x_rules_to_paste(v_counter).name,
				x_to_ruleset_id,
				x_rules_to_paste(v_counter).revenue_class_id,
				x_rules_to_paste(v_counter).expense_ccid,
				x_rules_to_paste(v_counter).liability_ccid,
				x_parent_rule(v_counter).parent_rule_id,
				x_parent_rule(v_counter).sequence_number);

    FOR inner_counter IN 1 .. x_rtp_index LOOP
      IF x_parent_rule(inner_counter).parent_rule_id = x_rules_to_paste(v_counter).rule_id THEN
       x_parent_rule(inner_counter).parent_rule_id := x_new_rule_id(v_counter);
      END IF;
    END LOOP;

  END LOOP;
  x_parent_rule.DELETE;

EXCEPTION
WHEN NO_DATA_FOUND THEN
null;

END paste_rules;

-----------------------------------------------------------------------+
--Procedure Name: find_rule_attributes				     --+
--Purpose							     --+
--To find the rule attributes corresponding to a particular rule     --+
-----------------------------------------------------------------------+

PROCEDURE find_rule_attributes( x_corr_rule_id  IN        NUMBER,
				x_rar_index     IN OUT NOCOPY    NUMBER,
				x_rule_attr_row IN OUT NOCOPY    rule_attr_row_type) IS
  CURSOR rule_attr_cursor IS
    SELECT *
      FROM cn_attribute_rules
     WHERE rule_id = x_corr_rule_id;

BEGIN
  x_rar_index := 0;
  FOR ra IN rule_attr_cursor LOOP
  EXIT WHEN rule_attr_cursor%NOTFOUND;
  x_rar_index := x_rar_index + 1;
  x_rule_attr_row(x_rar_index) := ra;
  END LOOP;

END find_rule_attributes;

-----------------------------------------------------------------------+
--Procedure Name: find_rule_attribute_hierarchy       	       	     --+
--Purpose							     --+
--To find  the rule attributes expression corresponding to a parti-  --+
--cular rule                                                         --+
-----------------------------------------------------------------------+
PROCEDURE find_rule_attribute_expression(
                           x_rule_attr_expr IN OUT NOCOPY rule_attr_expr_type,
			   x_rae_index      IN OUT NOCOPY NUMBER,
			   x_old_rule_id    IN     NUMBER) IS
  CURSOR rule_attr_expr IS
    SELECT *
      FROM cn_rule_attr_expression
     WHERE rule_id = x_old_rule_id
  ORDER BY rule_attr_expression_id;

BEGIN

  x_rae_index := 0;
  FOR rae IN rule_attr_expr LOOP
    EXIT WHEN rule_attr_expr%NOTFOUND;
    x_rae_index := x_rae_index + 1;
    x_rule_attr_expr(x_rae_index) := rae;
  END LOOP;

END find_rule_attribute_expression;

-----------------------------------------------------------------------+
--Procedure Name: paste_rule_attribute_expr      	       	     --+
--Purpose							     --+
--To paste the rule attributes expression corresponding to a parti- --+
--cular rule                                                         --+
-----------------------------------------------------------------------+

PROCEDURE paste_rule_attribute_expr(
		       x_old_rule_id   IN      NUMBER,
                       x_new_rule_id   IN      NUMBER,
                       x_new_rule_attr IN      rule_attr_row_type,
                       x_rule_attr_row IN      rule_attr_row_type,
                       x_rar_index     IN      NUMBER) IS

  l_rule_attr_expr rule_attr_expr_type;
  l_rae_index NUMBER;
  TYPE new_rae_type IS TABLE OF
       cn_rule_attr_expression.rule_attr_expression_id%TYPE
       INDEX BY BINARY_INTEGER;
  l_new_rae_ids new_rae_type;
  f_h utl_file.file_type;

  /** code changes done by tpodila
    *   Bug 29583055 - 19C DB DE-SUPPORTING UTL_FILE
    */
 CURSOR c_get_utl_file_dir IS
 	SELECT VALUE
 	 FROM V$PARAMETER
  	WHERE NAME = 'utl_file_dir';

  	l_output_dir	v$parameter.value%TYPE;

BEGIN
 -- f_h := utl_file.fopen('/sqlcom/outbound', 'debug.log', 'w');
  /** code changes done by tpodila
    *   Bug 29583055 - 19C DB DE-SUPPORTING UTL_FILE
    */
	OPEN c_get_utl_file_dir;
	FETCH c_get_utl_file_dir INTO l_output_dir;

		IF c_get_utl_file_dir%FOUND THEN
			IF INSTR(l_output_dir,',') <> 0 THEN
				l_output_dir := SUBSTR(l_output_dir, 1, INSTR(l_output_dir, ',') - 1);
			END IF;
				 f_h := utl_file.fopen(l_output_dir, 'debug.log', 'w');
		END IF;
	CLOSE c_get_utl_file_dir;

  find_rule_attribute_expression(l_rule_attr_expr, l_rae_index, x_old_rule_id);

  FOR v_counter_1 IN 1 .. l_rae_index LOOP
  SELECT cn_rule_attr_expression_s.NEXTVAL
      INTO l_new_rae_ids(v_counter_1)
      FROM dual;
    l_rule_attr_expr(v_counter_1).rule_id := x_new_rule_id;
/*    FOR v_counter_2 IN v_counter_1 .. l_rae_index LOOP
      IF v_rule_attr_expr(v_counter_2).operand1 =
         v_rule_attr_expr(v_counter_1).rule_attr_expression_id THEN
        v_rule_attr_expr(v_counter_2).operand1 := new_rae_ids(v_counter_1);
      ELSIF v_rule_attr_expr(v_counter_2).operand2 =
         v_rule_attr_expr(v_counter_1).rule_attr_expression_id THEN
        v_rule_attr_expr(v_counter_2).operand2 := new_rae_ids(v_counter_1);
      END IF;
    END LOOP; */
    l_rule_attr_expr(v_counter_1).rule_attr_expression_id :=
       l_new_rae_ids(v_counter_1);
/*    FOR v_counter_2 IN 1 .. v_rar_index LOOP
      IF v_rule_attr_expr(v_counter_1).operand1 =
         v_rule_attr_row(v_counter_2).attribute_rule_id THEN
        v_rule_attr_expr(v_counter_1).operand1 := v_new_rule_attr(v_counter_2).attribute_rule_id;
      ELSIF v_rule_attr_expr(v_counter_1).operand2 =
         v_rule_attr_row(v_counter_2).attribute_rule_id THEN
        v_rule_attr_expr(v_counter_1).operand2 := v_new_rule_attr(v_counter_2).attribute_rule_id;
      END IF;
    END LOOP; */
    INSERT INTO cn_rule_attr_expression (rule_attr_expression_id,
                                         operand1,
                                         operand2,
                                         operator,
                                         rule_id,
                                         operand_expression_id,
                                         operand1_ra_rae_flag,
                                         operand2_ra_rae_flag,
                                         last_update_date,
                                         last_updated_by,
                                         creation_date,
                                         created_by,
                                         last_update_login,
                                         org_id)
    VALUES( l_rule_attr_expr(v_counter_1).rule_attr_expression_id,
	  l_rule_attr_expr(v_counter_1).operand1,
	  l_rule_attr_expr(v_counter_1).operand2,
	  l_rule_attr_expr(v_counter_1).operator,
	  l_rule_attr_expr(v_counter_1).rule_id,
	  l_rule_attr_expr(v_counter_1).operand_expression_id,
	  l_rule_attr_expr(v_counter_1).operand1_ra_rae_flag,
	  l_rule_attr_expr(v_counter_1).operand2_ra_rae_flag,
	  l_rule_attr_expr(v_counter_1).last_update_date,
	  l_rule_attr_expr(v_counter_1).last_updated_by,
	  l_rule_attr_expr(v_counter_1).creation_date,
	  l_rule_attr_expr(v_counter_1).created_by,
	  l_rule_attr_expr(v_counter_1).last_update_login,
	  l_rule_attr_expr(v_counter_1).org_id );
  END LOOP;
 utl_file.fclose(f_h);
END paste_rule_attribute_expr;


PROCEDURE paste_rule_attributes( x_to_ruleset_id  IN    NUMBER,
                                 x_new_rule_id    IN	new_rule_id_type,
				 x_rules_to_paste IN	rules_to_paste_type,
				 x_rtp_index      IN	NUMBER) IS

  l_new_rule_attr rule_attr_row_type;
  l_rule_attr_row rule_attr_row_type;
  l_rar_index NUMBER;

BEGIN

  FOR v_counter_1 IN 1 .. x_rtp_index LOOP

    find_rule_attributes(x_rules_to_paste(v_counter_1).rule_id,
                         l_rar_index, l_rule_attr_row);

    FOR v_counter_2 IN 1 .. l_rar_index LOOP
      l_new_rule_attr(v_counter_2) := l_rule_attr_row(v_counter_2);
      l_new_rule_attr(v_counter_2).attribute_rule_id := null;
      cn_syin_attr_rules_pkg.default_row(
                    l_new_rule_attr(v_counter_2).attribute_rule_id);

      l_new_rule_attr(v_counter_2).rule_id := x_new_rule_id(v_counter_1);
      INSERT INTO cn_attribute_rules(
		attribute_rule_id,
		column_id,
		column_value,
		not_flag,
		high_value,
		low_value,
		expression,
		dimension_hierarchy_id,
		slice_module_id,
		rule_id,
                ruleset_id,
		attribute_category,
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		attribute11,
	        attribute12,
		attribute13,
		attribute14,
		attribute15)
        VALUES( l_new_rule_attr(v_counter_2).attribute_rule_id,
		l_new_rule_attr(v_counter_2).column_id,
		l_new_rule_attr(v_counter_2).column_value,
		l_new_rule_attr(v_counter_2).not_flag,
		l_new_rule_attr(v_counter_2).high_value,
		l_new_rule_attr(v_counter_2).low_value,
		l_new_rule_attr(v_counter_2).expression,
		l_new_rule_attr(v_counter_2).dimension_hierarchy_id,
		l_new_rule_attr(v_counter_2).slice_module_id,
		l_new_rule_attr(v_counter_2).rule_id,
                x_to_ruleset_id,
		l_new_rule_attr(v_counter_2).attribute_category,
		l_new_rule_attr(v_counter_2).attribute1,
		l_new_rule_attr(v_counter_2).attribute2,
		l_new_rule_attr(v_counter_2).attribute3,
		l_new_rule_attr(v_counter_2).attribute4,
		l_new_rule_attr(v_counter_2).attribute5,
		l_new_rule_attr(v_counter_2).attribute6,
		l_new_rule_attr(v_counter_2).attribute7,
		l_new_rule_attr(v_counter_2).attribute8,
		l_new_rule_attr(v_counter_2).attribute9,
		l_new_rule_attr(v_counter_2).attribute10,
		l_new_rule_attr(v_counter_2).attribute11,
		l_new_rule_attr(v_counter_2).attribute12,
		l_new_rule_attr(v_counter_2).attribute13,
		l_new_rule_attr(v_counter_2).attribute14,
		l_new_rule_attr(v_counter_2).attribute15);

    END LOOP;
    paste_rule_attribute_expr(x_rules_to_paste(v_counter_1).rule_id,
                              x_new_rule_id(v_counter_1), l_new_rule_attr,
                              l_rule_attr_row, l_rar_index);
    l_rar_index := 1;
    l_rule_attr_row.DELETE;
    l_new_rule_attr.DELETE;
  END LOOP;

END paste_rule_attributes;



-----------------------------------------------------------------------+
--Procedure Name: is_descendant_of				     --+
--Purpose							     --+
--To verify if a given node is a child of another		     --+
-----------------------------------------------------------------------+

FUNCTION is_descendant_of(x_to_parent_id IN	   NUMBER,
			  x_start_rule_id IN	   NUMBER,
                          x_rtp_index IN OUT NOCOPY       NUMBER,
                          x_rules_to_paste IN OUT NOCOPY  rules_to_paste_type,
			  x_from_ruleset_id IN       NUMBER,
			  x_parent_rule IN OUT NOCOPY     parent_rule_type)
RETURN BOOLEAN IS


BEGIN
  SELECT *
    INTO x_rules_to_paste(x_rtp_index)
    FROM cn_rules
   WHERE rule_id = x_start_rule_id;
  x_parent_rule(x_rtp_index).parent_rule_id := x_to_parent_id;
  x_parent_rule(x_rtp_index).rule_id := x_start_rule_id;
  find_descendant_rules(x_start_rule_id, x_from_ruleset_id,
			x_rules_to_paste, x_rtp_index,
			x_parent_rule);

  FOR v_counter IN 1..x_rtp_index LOOP
    IF x_rules_to_paste(v_counter).rule_id = x_to_parent_id THEN
      return TRUE;
    END IF;
  END LOOP;
  return FALSE;

EXCEPTION
WHEN no_data_found THEN
return FALSE;

END is_descendant_of;

-----------------------------------------------------------------------+
--Procedure Name: check_restrictions				     --+
--Purpose							     --+
--To check if the user is trying to paste the rule under itself or   --+
--a subtree/trying to paste the rule to the same parent		     --+
-----------------------------------------------------------------------+

FUNCTION check_restrictions ( x_from_parent_id IN		NUMBER,
			x_to_parent_id IN		NUMBER,
			x_start_rule_id IN		NUMBER,
                        x_rules_to_paste IN OUT NOCOPY   rules_to_paste_type,
			x_from_ruleset_id IN        NUMBER,
			x_parent_rule IN OUT NOCOPY      parent_rule_type,
			x_rtp_index IN OUT NOCOPY 	NUMBER)
RETURN BOOLEAN IS

l_dummy BOOLEAN;

BEGIN

l_dummy := TRUE;
  l_dummy :=
  is_descendant_of( x_to_parent_id, x_start_rule_id, x_rtp_index,
                  x_rules_to_paste, x_from_ruleset_id, x_parent_rule);

  IF x_from_parent_id = x_to_parent_id THEN
    return FALSE;
  ELSIF l_dummy  THEN
    return FALSE;
  ELSE
    return TRUE;
  END IF;

END check_restrictions;

-----------------------------------------------------------------------+
-- Function Name:	Paste_into_Hierarchy		--+
-- Purpose						--+
-- This function is used to create a copy of the rules
-- in the same rule --+
-- set or in a different rule set with new rule ids	--+
------------------------------------------------------------------------+

FUNCTION paste_into_hierarchy( x_start_rule_id 	        NUMBER,
                               x_to_parent_id	        NUMBER,
                               x_from_ruleset_id 	NUMBER,
                               x_to_ruleset_id 	        NUMBER,
                               x_from_parent_id           NUMBER)
RETURN BOOLEAN IS

  l_parent_rule parent_rule_type;
  l_rules_to_paste rules_to_paste_type;
  l_new_rule_id new_rule_id_type;
  l_rtp_index NUMBER;

BEGIN
  l_rtp_index := 1;
  IF x_from_ruleset_id = x_to_ruleset_id THEN
    IF check_restrictions(x_from_parent_id, x_to_parent_id, x_start_rule_id, l_rules_to_paste, x_from_ruleset_id, l_parent_rule, l_rtp_index) THEN
      paste_rules(l_rules_to_paste, l_new_rule_id,
	      x_to_ruleset_id, l_rtp_index,
	      l_parent_rule);
      paste_rule_attributes(x_to_ruleset_id, l_new_rule_id, l_rules_to_paste, l_rtp_index);
      return TRUE;
    ELSE
      return FALSE;
    end if;

  else

    SELECT *
      INTO l_rules_to_paste(l_rtp_index)
      FROM cn_rules
     WHERE rule_id = x_start_rule_id;

  l_parent_rule(l_rtp_index).parent_rule_id := x_to_parent_id;
  l_parent_rule(l_rtp_index).rule_id := x_start_rule_id;
  find_descendant_rules(x_start_rule_id, x_from_ruleset_id,
			l_rules_to_paste, l_rtp_index,
			l_parent_rule);
  paste_rules(l_rules_to_paste, l_new_rule_id,
	      x_to_ruleset_id, l_rtp_index,
	      l_parent_rule);
  paste_rule_attributes(x_to_ruleset_id, l_new_rule_id, l_rules_to_paste, l_rtp_index);
  return TRUE;
end if;
END paste_into_hierarchy;

BEGIN

null;

END cn_rules_copy_paste;

/
