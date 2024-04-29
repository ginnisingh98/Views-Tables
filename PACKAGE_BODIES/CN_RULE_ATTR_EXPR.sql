--------------------------------------------------------
--  DDL for Package Body CN_RULE_ATTR_EXPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULE_ATTR_EXPR" AS
-- $Header: cnraethb.pls 115.1 99/07/16 07:13:07 porting shi $
  --------------------------------------------------------------------------
  -- Procedure Name:    delete_expr				        --
  -- Purpose								--
  --------------------------------------------------------------------------
  PROCEDURE delete_expr
               (x_rule_id IN cn_rule_attr_expression.rule_id%TYPE) IS
  BEGIN

    UPDATE cn_attribute_rules
    SET expression = ''
    WHERE rule_id = x_rule_id;

    DELETE FROM cn_rule_attr_expression
    WHERE  rule_id = x_rule_id;

    commit;

  END;


END cn_rule_attr_expr;

/
