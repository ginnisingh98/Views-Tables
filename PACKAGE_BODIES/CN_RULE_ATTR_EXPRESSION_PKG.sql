--------------------------------------------------------
--  DDL for Package Body CN_RULE_ATTR_EXPRESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULE_ATTR_EXPRESSION_PKG" AS
/* $Header: cntraeb.pls 115.4 2002/11/21 21:10:19 hlchen ship $ */
--
-- Package Name
-- CN_RULE_ATTR_EXPRESSION
-- Purpose
--  Table Handler for CN_RULE_ATTR_EXPRESSION
--
-- History
-- 02-feb-01	Kumar Sivasankaran
-- ==========================================================================
-- |
-- |                             PRIVATE VARIABLES
-- |
-- ==========================================================================
  g_program_type     VARCHAR2(30) := NULL;
-- ==========================================================================
-- |
-- |                             PRIVATE ROUTINES
-- |
-- ==========================================================================

-- ==========================================================================
--  |                             Custom Validation
-- ==========================================================================

-- ==========================================================================
  -- Procedure Name
  --	Insert_row
  -- Purpose
  --    Main insert procedure
-- ==========================================================================
PROCEDURE insert_row
   (p_rule_attr_expression_id   IN OUT NOCOPY NUMBER
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
  )  IS
      l_dummy NUMBER;

   BEGIN

     INSERT INTO cn_rule_attr_expression
   (	rule_attr_expression_id
    	,operand1
    	,operand2
    	,operator
    	,rule_id
    	,operand_expression_id
    	,operand1_ra_rae_flag
    	,operand2_ra_rae_flag
    	,Created_By
    	,Creation_Date
    	,Last_Updated_By
    	,Last_Update_Date
    	,Last_Update_Login)
   VALUES
    (	p_rule_attr_expression_id
     	,p_operand1
     	,p_operand2
     	,p_operator
     	,p_rule_id
    	,p_operand_expression_id
     	,p_operand1_ra_rae_flag
     	,p_operand2_ra_rae_flag
     	,p_Created_By
     	,p_Creation_Date
	,p_Last_Updated_By
	,p_Last_Update_Date
	,p_Last_Update_Login
	);

   END Insert_row;

-- ==========================================================================
  -- Procedure Name
  --	Delete_row
  -- Purpose
  --    Delete the Rule Attr Expression
-- ==========================================================================

  PROCEDURE Delete_row( p_rule_id     NUMBER ) IS
  BEGIN

     DELETE FROM cn_rule_attr_expression
       WHERE  rule_id = p_rule_id;

  END Delete_row;

END CN_RULE_ATTR_EXPRESSION_PKG;

/
