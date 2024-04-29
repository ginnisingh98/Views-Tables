--------------------------------------------------------
--  DDL for Package AMS_WEB_CITEM_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WEB_CITEM_ASSOC_PKG" AUTHID CURRENT_USER AS
/* $Header: amstwmps.pls 120.0 2005/07/01 03:54:21 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_WEB_CITEM_ASSOC_PKG
-- Purpose
--   	Table api to insert/update/delete WebPlanner Citems Associations.
-- History
--		10-May-2005    sikalyan     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================


-- ===============================================================
-- Start of Comments
-- Procedure name
--      Insert_Row
-- Purpose
--      Table api to insert WebPlanner Citems Associations.
-- History
--      10-May-2005    sikalyan     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_placement_citem_id   IN OUT NOCOPY NUMBER,
          p_placement_mp_id    NUMBER,
          p_content_item_id    NUMBER,
          p_citem_version_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
	  p_return_status          OUT NOCOPY VARCHAR2,
	  p_msg_count             OUT  NOCOPY  NUMBER,
	  p_msg_data                OUT  NOCOPY  VARCHAR2
	  );

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Update_Row
-- Purpose
--      Table api to update WebPlanner Citems Associations.
-- History
--      10-May-2005    sikalyan     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Update_Row (
	  p_placement_citem_id   NUMBER,
          p_placement_mp_id    NUMBER,
          p_content_item_id    NUMBER,
          p_citem_version_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number   NUMBER);

-- ===============================================================
-- Start of Comments
-- Procedure name
--      Delete_Row
-- Purpose
--      Table api to Delete WebPlanner Citems Associations..
-- History
--      10-May-2005    sikalyan     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Delete_Row(
    p_placement_citem_id  NUMBER,
    p_object_version_number NUMBER);


-- ===============================================================
-- Start of Comments
-- Procedure name
--      Lock_Row
-- Purpose
--   Table api to lock  WebPlanner Citems Associations..
-- History
--   10-May-2005    sikalyan     Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Lock_Row(
          p_placement_citem_id   NUMBER,
          p_placement_mp_id    NUMBER,
          p_content_item_id    NUMBER,
          p_citem_version_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number   NUMBER);


PROCEDURE load_row (
         x_placement_citem_id   IN NUMBER,
         x_placement_mp_id  IN  NUMBER,
         x_content_item_id  IN  NUMBER,
         x_citem_version_id  IN  NUMBER,
         x_p_created_by   IN NUMBER,
         x_p_creation_date  IN  DATE,
         x_p_last_updated_by  IN  NUMBER,
         x_p_last_update_date  IN  DATE,
         x_p_last_update_login  IN  NUMBER,
         x_p_object_version_number   IN NUMBER,
	 x_owner               IN VARCHAR2,
	 x_custom_mode IN VARCHAR2
);


END AMS_WEB_CITEM_ASSOC_PKG;

 

/
