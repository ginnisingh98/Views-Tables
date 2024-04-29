--------------------------------------------------------
--  DDL for Package AMS_DM_PERFORMANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_PERFORMANCE_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdpfs.pls 120.1 2005/06/15 23:58:13 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_PERFORMANCE_PKG
-- Purpose
--
-- History
-- 07-Jan-2002 choang   Removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_performance_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_predicted_value    VARCHAR2,
          p_actual_value    VARCHAR2,
          p_evaluated_records    NUMBER,
          p_total_records_predicted    NUMBER,
          p_model_id    NUMBER);

PROCEDURE Update_Row(
          p_performance_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_predicted_value    VARCHAR2,
          p_actual_value    VARCHAR2,
          p_evaluated_records    NUMBER,
          p_total_records_predicted    NUMBER,
          p_model_id    NUMBER);

PROCEDURE Delete_Row(
    p_PERFORMANCE_ID  NUMBER);
PROCEDURE Lock_Row(
          p_performance_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_predicted_value    VARCHAR2,
          p_actual_value    VARCHAR2,
          p_evaluated_records    NUMBER,
          p_total_records_predicted    NUMBER,
          p_model_id    NUMBER);

END AMS_DM_PERFORMANCE_PKG;

 

/
