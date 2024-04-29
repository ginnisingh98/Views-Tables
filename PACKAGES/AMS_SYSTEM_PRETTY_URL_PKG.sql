--------------------------------------------------------
--  DDL for Package AMS_SYSTEM_PRETTY_URL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_SYSTEM_PRETTY_URL_PKG" AUTHID CURRENT_USER AS
/* $Header: amstspus.pls 120.0 2005/07/01 03:59:39 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_SYSTEM_PRETTY_URL_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_system_url_id   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_pretty_url_id    NUMBER,
          p_additional_url_param    VARCHAR2,
          p_system_url    VARCHAR2,
          p_ctd_id    NUMBER,
          p_track_url    VARCHAR2);

PROCEDURE Update_Row(
          p_system_url_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_pretty_url_id    NUMBER,
          p_additional_url_param    VARCHAR2,
          p_system_url    VARCHAR2,
          p_ctd_id    NUMBER,
          p_track_url    VARCHAR2);

PROCEDURE Delete_Row(
    p_SYSTEM_URL_ID  NUMBER);
PROCEDURE Lock_Row(
          p_system_url_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_pretty_url_id    NUMBER,
          p_additional_url_param    VARCHAR2,
          p_system_url    VARCHAR2,
          p_ctd_id    NUMBER,
          p_track_url    VARCHAR2);

END AMS_SYSTEM_PRETTY_URL_PKG;

 

/
