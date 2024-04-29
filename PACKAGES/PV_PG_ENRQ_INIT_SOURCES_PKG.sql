--------------------------------------------------------
--  DDL for Package PV_PG_ENRQ_INIT_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_ENRQ_INIT_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtpeis.pls 115.2 2002/12/10 20:36:32 jkylee ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrq_Init_Sources_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================




--  ========================================================
--
--  NAME
--  Insert_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Insert_Row(
          px_initiation_source_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_enrl_request_id    NUMBER,
          p_prev_membership_id    NUMBER,
          p_enrl_change_rule_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER);





--  ========================================================
--
--  NAME
--  Update_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Update_Row(
          p_initiation_source_id    NUMBER,
          p_object_version_number   IN NUMBER,
          p_enrl_request_id    NUMBER,
          p_prev_membership_id    NUMBER,
          p_enrl_change_rule_id    NUMBER,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER);





--  ========================================================
--
--  NAME
--  Delete_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Delete_Row(
    p_initiation_source_id  NUMBER,
    p_object_version_number  NUMBER);




--  ========================================================
--
--  NAME
--  Lock_Row
--
--  PURPOSE
--
--  NOTES
--
--  HISTORY
--
--  ========================================================
PROCEDURE Lock_Row(
    p_initiation_source_id  NUMBER,
    p_object_version_number  NUMBER);


END PV_Pg_Enrq_Init_Sources_PKG;

 

/
