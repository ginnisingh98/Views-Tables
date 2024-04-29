--------------------------------------------------------
--  DDL for Package PV_PEC_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PEC_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtecrs.pls 115.2 2002/12/10 10:26:59 swkulkar ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pec_Rules_PKG
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
          px_enrl_change_rule_id   IN OUT NOCOPY NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_change_from_program_id    NUMBER,
          p_change_to_program_id    NUMBER,
          p_change_direction_code    VARCHAR2,
          p_effective_from_date    DATE,
          p_effective_to_date    DATE,
          p_active_flag    VARCHAR2,
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
          p_enrl_change_rule_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_change_from_program_id NUMBER,
          p_change_to_program_id NUMBER,
          p_change_direction_code VARCHAR2,
          p_effective_from_date DATE,
          p_effective_to_date  DATE,
          p_active_flag  VARCHAR2,
          p_last_updated_by  NUMBER,
          p_last_update_date   DATE,
          p_last_update_login   NUMBER);





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
    p_enrl_change_rule_id  NUMBER,
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
    p_enrl_change_rule_id  NUMBER,
    p_object_version_number  NUMBER);


END PV_Pec_Rules_PKG;

 

/
