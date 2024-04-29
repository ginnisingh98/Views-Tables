--------------------------------------------------------
--  DDL for Package PV_PG_MMBR_TRANSITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PG_MMBR_TRANSITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxtmbts.pls 115.1 2002/12/10 20:59:06 pukken ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          pv_pg_mmbr_transitions_PKG
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
          px_mmbr_transition_id   IN OUT NOCOPY NUMBER,
          p_from_membership_id    NUMBER,
          p_to_membership_id    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
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
          p_mmbr_transition_id    NUMBER,
          p_from_membership_id    NUMBER,
          p_to_membership_id    NUMBER,
          p_object_version_number   IN NUMBER,
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
    p_mmbr_transition_id  NUMBER,
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
    p_mmbr_transition_id  NUMBER,
    p_object_version_number  NUMBER);


END pv_pg_mmbr_transitions_PKG;

 

/
