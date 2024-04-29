--------------------------------------------------------
--  DDL for Package AMS_IBA_PS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PS_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: amstruls.pls 120.0 2005/05/31 16:01:37 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_RULES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          px_rule_id   IN OUT NOCOPY NUMBER,
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_id    NUMBER,
	  p_exec_priority  NUMBER,
          p_bus_priority_code    VARCHAR2,
          p_bus_priority_disp_order    VARCHAR2,
          p_clausevalue1    VARCHAR2,
          p_clausevalue2    NUMBER,
          p_clausevalue3    VARCHAR2,
          p_clausevalue4    VARCHAR2,
          p_clausevalue5    NUMBER,
          p_clausevalue6    VARCHAR2,
          p_clausevalue7    VARCHAR2,
          p_clausevalue8    VARCHAR2,
          p_clausevalue9    VARCHAR2,
          p_clausevalue10    VARCHAR2,
	  p_use_clause6	     VARCHAR2,
	  p_use_clause7	     VARCHAR2,
	  p_use_clause8	     VARCHAR2,
	  p_use_clause9	     VARCHAR2,
	  p_use_clause10     VARCHAR2);

PROCEDURE Update_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_rule_id    NUMBER,
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_id    NUMBER,
	  p_exec_priority  NUMBER,
          p_bus_priority_code    VARCHAR2,
          p_bus_priority_disp_order    VARCHAR2,
          p_clausevalue1    VARCHAR2,
          p_clausevalue2    NUMBER,
          p_clausevalue3    VARCHAR2,
          p_clausevalue4    VARCHAR2,
          p_clausevalue5    NUMBER,
          p_clausevalue6    VARCHAR2,
          p_clausevalue7    VARCHAR2,
          p_clausevalue8    VARCHAR2,
          p_clausevalue9    VARCHAR2,
          p_clausevalue10    VARCHAR2,
          p_use_clause6      VARCHAR2,
          p_use_clause7      VARCHAR2,
          p_use_clause8      VARCHAR2,
          p_use_clause9      VARCHAR2,
          p_use_clause10     VARCHAR2);

PROCEDURE Delete_Row(
    p_RULE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_rule_id    NUMBER,
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_id    NUMBER,
          p_bus_priority_code    VARCHAR2,
          p_bus_priority_disp_order    VARCHAR2,
          p_clausevalue1    VARCHAR2,
          p_clausevalue2    NUMBER,
          p_clausevalue3    VARCHAR2,
          p_clausevalue4    VARCHAR2,
          p_clausevalue5    NUMBER,
          p_clausevalue6    VARCHAR2,
          p_clausevalue7    VARCHAR2,
          p_clausevalue8    VARCHAR2,
          p_clausevalue9    VARCHAR2,
          p_clausevalue10    VARCHAR2);

END AMS_IBA_PS_RULES_PKG;

 

/
