--------------------------------------------------------
--  DDL for Package AMS_CUSTOM_SETUP_PURPOSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CUSTOM_SETUP_PURPOSE_PKG" AUTHID CURRENT_USER AS
 /* $Header: amslcsps.pls 115.2 2004/04/08 22:51:33 asaha noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_Custom_Setup_Purpose_PKG
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
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
           px_setup_purpose_id        IN OUT NOCOPY NUMBER,
           p_custom_setup_id          NUMBER,
           p_last_update_date         DATE,
           p_last_updated_by          NUMBER,
           p_creation_date            DATE,
           p_created_by               NUMBER,
           p_last_update_login        NUMBER,
           p_activity_purpose_code    VARCHAR2,
           p_enabled_flag             VARCHAR2,
           p_def_list_template_id     NUMBER,
           px_object_version_number   IN OUT NOCOPY NUMBER);





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
           p_setup_purpose_id      NUMBER,
           p_custom_setup_id       NUMBER,
           p_last_update_date      DATE,
           p_last_updated_by       NUMBER,
           p_last_update_login     NUMBER,
           p_activity_purpose_code VARCHAR2,
           p_enabled_flag          VARCHAR2,
           p_def_list_template_id  NUMBER,
           p_object_version_number NUMBER);

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
     p_setup_purpose_id  NUMBER,
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
     p_setup_purpose_id  NUMBER,
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
PROCEDURE Load_Row(
  p_setup_purpose_id        NUMBER,
  p_custom_setup_id          NUMBER,
  p_activity_purpose_code    VARCHAR2,
  p_enabled_flag             VARCHAR2,
  p_def_list_template_id     NUMBER,
  p_owner                    VARCHAR2,
  p_custom_mode              VARCHAR2,
  X_LAST_UPDATE_DATE   in DATE
);

 END AMS_Custom_Setup_Purpose_PKG;

 

/
