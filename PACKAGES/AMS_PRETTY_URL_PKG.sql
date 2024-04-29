--------------------------------------------------------
--  DDL for Package AMS_PRETTY_URL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PRETTY_URL_PKG" AUTHID CURRENT_USER AS
/* $Header: amstpurs.pls 120.0 2005/07/01 03:58:19 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_PRETTY_URL_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_pretty_url_id   IN OUT NOCOPY NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_landing_page_url    VARCHAR2);

PROCEDURE Update_Row(
          p_pretty_url_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_landing_page_url    VARCHAR2);

PROCEDURE Delete_Row(
    p_PRETTY_URL_ID  NUMBER);
PROCEDURE Lock_Row(
          p_pretty_url_id    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_landing_page_url    VARCHAR2);

END AMS_PRETTY_URL_PKG;

 

/
