--------------------------------------------------------
--  DDL for Package AMS_IBA_PS_RULEGRPS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PS_RULEGRPS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstrgps.pls 120.0 2005/05/31 19:58:05 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PS_RULEGRPS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_rulegroup_id   IN OUT NOCOPY NUMBER,
          p_posting_id    NUMBER,
          p_strategy_type    VARCHAR2,
          p_exec_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_RULE_NAME   IN VARCHAR2,
          p_RULE_DESCRIPTION    IN VARCHAR2);


PROCEDURE Update_Row(
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_type    VARCHAR2,
          p_exec_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER,
          p_RULE_NAME   IN VARCHAR2,
          p_RULE_DESCRIPTION    IN VARCHAR2);


PROCEDURE Delete_Row(
    p_RULEGROUP_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Lock_Row(
          p_rulegroup_id    NUMBER,
          p_posting_id    NUMBER,
          p_strategy_type    VARCHAR2,
          p_exec_priority    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_object_version_number    NUMBER);

END AMS_IBA_PS_RULEGRPS_B_PKG;

 

/
