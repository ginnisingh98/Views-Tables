--------------------------------------------------------
--  DDL for Package CN_GET_EXPRESSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_EXPRESSION" AUTHID CURRENT_USER AS
-- $Header: cngtexps.pls 120.1 2005/07/18 03:28:48 rramakri noship $
--=========================================================================
  -- Procedure Name:	MAIN
  -- Purpose
--=========================================================================
  PROCEDURE main(x_rule_id    IN  cn_rule_attr_expression.rule_id%TYPE,
                 x_org_id     IN  cn_rule_attr_expression.org_id%TYPE,
                 x_usage      IN  VARCHAR2,
                 x_expression OUT NOCOPY VARCHAR2);

  PROCEDURE deleteExpression(x_rule_id    IN  cn_attribute_rules.rule_id%TYPE,
                x_org_id     IN  cn_attribute_rules.org_id%TYPE
                );

  TYPE rae_type IS TABLE OF VARCHAR(32700) INDEX BY BINARY_INTEGER;
  g_rae                   rae_type;
  g_intermediate_expr	NUMBER := 1;

END cn_get_expression;

 

/
