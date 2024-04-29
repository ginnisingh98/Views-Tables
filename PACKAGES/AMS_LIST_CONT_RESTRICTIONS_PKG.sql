--------------------------------------------------------
--  DDL for Package AMS_LIST_CONT_RESTRICTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_CONT_RESTRICTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstascs.pls 120.0 2005/05/31 16:58:03 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_CONT_RESTRICTIONS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_list_cont_restrictions_id   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER
          );

PROCEDURE Update_Row(
          p_list_cont_restrictions_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER
          );

PROCEDURE Delete_Row(
    p_list_cont_restrictions_id  NUMBER);
PROCEDURE Lock_Row(
          p_list_cont_restrictions_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER
          );

PROCEDURE LOAD_ROW(
          p_owner    VARCHAR2,
          p_list_cont_restrictions_id    NUMBER,
          p_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_do_not_contact_flag    VARCHAR2,
          p_media_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_used_by_id    NUMBER,
          p_custom_mode    VARCHAR2

          );

END AMS_LIST_CONT_RESTRICTIONS_PKG;

 

/
