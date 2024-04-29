--------------------------------------------------------
--  DDL for Package PV_TAP_ACCESS_TERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_TAP_ACCESS_TERRS_PKG" AUTHID CURRENT_USER AS
/* $Header: pvxttras.pls 115.0 2003/10/15 04:19:38 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_ACCESS_TERRS_PKG
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
          p_partner_access_id    NUMBER,
          p_terr_id              NUMBER,
          p_last_update_date     DATE,
          p_last_updated_by      NUMBER,
          p_creation_date        DATE,
          p_created_by           NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number NUMBER,
          p_request_id           NUMBER,
          p_program_application_id    NUMBER,
          p_program_id           NUMBER,
          p_program_update_date  DATE,
	  x_return_status IN OUT NOCOPY VARCHAR2);

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
          p_partner_access_id     NUMBER,
          p_terr_id               NUMBER,
          p_last_update_date      DATE,
          p_last_updated_by       NUMBER,
          p_last_update_login     NUMBER,
          p_object_version_number NUMBER,
          p_request_id            NUMBER,
          p_program_application_id NUMBER,
          p_program_id            NUMBER,
          p_program_update_date   DATE,
	  x_return_status IN OUT NOCOPY VARCHAR2);





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
    p_partner_access_id      NUMBER,
    p_terr_id                NUMBER,
    p_object_version_number  NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2);




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
    p_partner_access_id      NUMBER,
    p_terr_id                NUMBER,
    p_object_version_number  NUMBER,
    x_return_status  IN OUT NOCOPY VARCHAR2);


END PV_TAP_ACCESS_TERRS_PKG;

 

/