--------------------------------------------------------
--  DDL for Package AMS_DM_SCORE_RESULTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_SCORE_RESULTS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdrss.pls 120.1 2005/06/15 23:58:20 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_DM_SCORE_RESULTS_PKG
-- Purpose
--
-- History
-- 24-Jan-2001 choang   Created.
-- 26-Jan-2001 choang   1) Changed response to score and model_score_id
--                      to score_id.
-- 10-Jul-2001 choang   Replaced tree_node with decile.
-- 07-Jan-2002 choang   Removed security group id
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_score_result_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_score_id    NUMBER,
          p_decile    VARCHAR2,
          p_num_records    NUMBER,
          p_score    VARCHAR2,
          p_confidence    NUMBER);

PROCEDURE Update_Row(
          p_score_result_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_score_id    NUMBER,
          p_decile    VARCHAR2,
          p_num_records    NUMBER,
          p_score    VARCHAR2,
          p_confidence    NUMBER);

PROCEDURE Delete_Row(
    p_SCORE_RESULT_ID  NUMBER);
PROCEDURE Lock_Row(
          p_score_result_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_score_id    NUMBER,
          p_decile    VARCHAR2,
          p_num_records    NUMBER,
          p_score    VARCHAR2,
          p_confidence    NUMBER);

END AMS_DM_SCORE_RESULTS_PKG;

 

/
