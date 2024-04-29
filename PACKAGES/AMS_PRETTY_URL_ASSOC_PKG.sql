--------------------------------------------------------
--  DDL for Package AMS_PRETTY_URL_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PRETTY_URL_ASSOC_PKG" AUTHID CURRENT_USER AS
/* $Header: amstpuas.pls 120.0 2005/07/01 03:52:58 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_PRETTY_URL_ASSOC_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_assoc_id   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_system_url_id    NUMBER,
          p_used_by_obj_type    VARCHAR2,
          p_used_by_obj_id    NUMBER);

PROCEDURE Update_Row(
          p_assoc_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_system_url_id    NUMBER,
          p_used_by_obj_type    VARCHAR2,
          p_used_by_obj_id    NUMBER);

PROCEDURE Delete_Row(
    p_ASSOC_ID  NUMBER);
PROCEDURE Lock_Row(
          p_assoc_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_system_url_id    NUMBER,
          p_used_by_obj_type    VARCHAR2,
          p_used_by_obj_id    NUMBER);

END AMS_PRETTY_URL_ASSOC_PKG;

 

/
