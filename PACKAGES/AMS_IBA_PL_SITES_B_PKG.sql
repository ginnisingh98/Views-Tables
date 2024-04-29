--------------------------------------------------------
--  DDL for Package AMS_IBA_PL_SITES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PL_SITES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstsits.pls 115.12 2003/03/12 00:28:52 ryedator ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_SITES_B_PKG
-- Purpose
--   	Table api to insert/update/delete iMarketing sites.
-- History
--		17-APR-2001    sodixit     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================


-- ===============================================================
-- Start of Comments
-- Procedure name
--      Insert_Row
-- Purpose
--      Table api to insert iMarketing Sites.
-- History
--      17-APR-2001    sodixit     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_site_id   IN OUT NOCOPY NUMBER,
          p_site_ref_code    VARCHAR2,
          p_site_category_type    VARCHAR2,
          p_site_category_object_id    NUMBER,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
		p_name in VARCHAR2,
		p_description in VARCHAR2);

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Update_Row
-- Purpose
--      Table api to update iMarketing Sites.
-- History
--      17-APR-2001    sodixit     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Update_Row(
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_site_category_type    VARCHAR2,
          p_site_category_object_id    NUMBER,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
		p_name in VARCHAR2,
		p_description in VARCHAR2);

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Delete_Row
-- Purpose
--      Table api to delete iMarketing Sites.
-- History
--      17-APR-2001    sodixit     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Delete_Row(
    p_site_id  NUMBER,
    p_object_version_number NUMBER);

procedure ADD_LANGUAGE;

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Lock_Row
-- Purpose
--      Table api to lock iMarketing Sites.
-- History
--      17-APR-2001    sodixit     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Lock_Row(
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_site_category_type    VARCHAR2,
          p_site_category_object_id    NUMBER,
          p_status_code    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
		p_name in VARCHAR2,
		p_description in VARCHAR2);

PROCEDURE translate_row (
   x_site_id IN NUMBER,
   x_name IN VARCHAR2,
   x_description IN VARCHAR2,
   x_owner IN VARCHAR2,
   x_custom_mode IN VARCHAR2
  );

PROCEDURE load_row (
   x_site_id           IN NUMBER,
   x_site_ref_code     IN VARCHAR2,
   x_site_ctgy_type    IN VARCHAR2,
   x_site_ctgy_obj_id       IN NUMBER,
   x_status_code       IN VARCHAR2,
   x_name         IN VARCHAR2,
   x_description  IN VARCHAR2,
   x_owner               IN VARCHAR2,
   x_custom_mode IN VARCHAR2
  );

END AMS_IBA_PL_SITES_B_PKG;

 

/
