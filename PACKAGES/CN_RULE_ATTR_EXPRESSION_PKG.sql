--------------------------------------------------------
--  DDL for Package CN_RULE_ATTR_EXPRESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULE_ATTR_EXPRESSION_PKG" AUTHID CURRENT_USER AS
/* $Header: cntraes.pls 115.3 2002/11/21 21:10:21 hlchen ship $ */
--
-- Package Name
-- CN_RULE_ATTR_EXPRESSION_PKG
-- Purpose
--  Table Handler for CN_RULE_ATTR_EXPRESSION
--
-- History
-- 02-feb-01	Kumar Sivasankaran	Created

--==========================================================================
-- Procedure Name
--	Insert_row
-- Purpose
--    Main insert procedure
--==========================================================================

PROCEDURE insert_row
   ( p_rule_attr_expression_id   IN OUT NOCOPY NUMBER
    ,p_operand1                   NUMBER
    ,p_operand2                   NUMBER
    ,p_operator                   NUMBER          := NULL
    ,p_rule_id                    NUMBER          := NULL
    ,p_operand_expression_id	NUMBER		:= NULL
    ,p_operand1_ra_rae_flag       VARCHAR2        := NULL
    ,p_operand2_ra_rae_flag       VARCHAR2        := NULL
    ,p_Created_By               NUMBER
    ,p_Creation_Date            DATE
    ,p_Last_Updated_By          NUMBER
    ,p_Last_Update_Date         DATE
    ,p_Last_Update_Login        NUMBER
  );

-- /*-------------------------------------------------------------------------*
-- Procedure Name
--	Lock_row
-- Purpose
--    Lock db row after form record is changed
-- Notes
-- *-------------------------------------------------------------------------*/
-- Procedure Name
--	Delete_row
-- Purpose
--    Delete the  Expression
--*-------------------------------------------------------------------------*/
PROCEDURE Delete_row( p_rule_id     NUMBER );

END CN_RULE_ATTR_EXPRESSION_PKG;

 

/
