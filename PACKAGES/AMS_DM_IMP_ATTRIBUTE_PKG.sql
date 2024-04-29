--------------------------------------------------------
--  DDL for Package AMS_DM_IMP_ATTRIBUTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_IMP_ATTRIBUTE_PKG" AUTHID CURRENT_USER AS
/* $Header: amstdias.pls 115.2 2002/12/09 11:04:59 choang noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Dm_Imp_Attribute_PKG
-- Purpose
--
-- History
--
-- NOTE
--
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
          px_Dm_Imp_Attribute_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_model_id    NUMBER,
          p_source_field_id    NUMBER,
          p_rank    NUMBER,
          p_value    NUMBER
);





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
          p_Dm_Imp_Attribute_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_model_id    NUMBER,
          p_source_field_id    NUMBER,
          p_rank    NUMBER,
          p_value    NUMBER
);





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
    p_Dm_Imp_Attribute_id  NUMBER,
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
    p_Dm_Imp_Attribute_id  NUMBER);

END AMS_Dm_Imp_Attribute_PKG;

 

/
