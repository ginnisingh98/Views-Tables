--------------------------------------------------------
--  DDL for Package AMS_CTD_PARAM_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CTD_PARAM_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: amstcpvs.pls 120.0 2005/07/01 03:54:55 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CTD_PARAM_VALUES_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_action_param_value_id   IN OUT NOCOPY NUMBER,
          p_action_param_value    VARCHAR2,
          p_ctd_id    NUMBER,
          p_action_param_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Update_Row(
          p_action_param_value_id    NUMBER,
          p_action_param_value    VARCHAR2,
          p_ctd_id    NUMBER,
          p_action_param_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_security_group_id    NUMBER);

PROCEDURE Delete_Row(
    p_ACTION_PARAM_VALUE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_action_param_value_id    NUMBER,
          p_action_param_value    VARCHAR2,
          p_ctd_id    NUMBER,
          p_action_param_id    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_security_group_id    NUMBER);

END AMS_CTD_PARAM_VALUES_PKG;

 

/
