--------------------------------------------------------
--  DDL for Package CN_RULE_ATTR_EXPR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULE_ATTR_EXPR" AUTHID CURRENT_USER AS
-- $Header: cnraeths.pls 115.2 99/07/16 07:13:12 porting shi $
  --------------------------------------------------------------------------
  -- Procedure Name:	delete_expr				        --
  -- Purpose								--
  --------------------------------------------------------------------------
  PROCEDURE delete_expr
              (x_rule_id    IN  cn_rule_attr_expression.rule_id%TYPE);


END cn_rule_attr_expr;

 

/
