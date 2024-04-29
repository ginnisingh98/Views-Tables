--------------------------------------------------------
--  DDL for Package AMS_IBA_PL_PLACEMENTS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IBA_PL_PLACEMENTS_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstplcs.pls 120.0 2005/06/01 02:56:49 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_IBA_PL_PLACEMENTS_B_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_placement_id   IN OUT NOCOPY NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_id    NUMBER,
          p_page_ref_code    VARCHAR2,
          p_location_code    VARCHAR2,
          p_param1    VARCHAR2,
          p_param2    VARCHAR2,
          p_param3    VARCHAR2,
          p_param4    VARCHAR2,
          p_param5    VARCHAR2,
          p_stylesheet_id    NUMBER,
          p_posting_id    NUMBER,
          p_status_code    VARCHAR2,
          p_track_events_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_name in VARCHAR2,
          p_description in VARCHAR2);

PROCEDURE Update_Row(
          p_placement_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_id    NUMBER,
          p_page_ref_code    VARCHAR2,
          p_location_code    VARCHAR2,
          p_param1    VARCHAR2,
          p_param2    VARCHAR2,
          p_param3    VARCHAR2,
          p_param4    VARCHAR2,
          p_param5    VARCHAR2,
          p_stylesheet_id    NUMBER,
          p_posting_id    NUMBER,
          p_status_code    VARCHAR2,
          p_track_events_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_name in VARCHAR2,
          p_description in VARCHAR2);

PROCEDURE Delete_Row(
    p_PLACEMENT_ID  NUMBER);

procedure ADD_LANGUAGE;

PROCEDURE Lock_Row(
          p_placement_id    NUMBER,
          p_site_id    NUMBER,
          p_site_ref_code    VARCHAR2,
          p_page_id    NUMBER,
          p_page_ref_code    VARCHAR2,
          p_location_code    VARCHAR2,
          p_param1    VARCHAR2,
          p_param2    VARCHAR2,
          p_param3    VARCHAR2,
          p_param4    VARCHAR2,
          p_param5    VARCHAR2,
          p_stylesheet_id    NUMBER,
          p_posting_id    NUMBER,
          p_status_code    VARCHAR2,
          p_track_events_flag    VARCHAR2,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_update_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER);

END AMS_IBA_PL_PLACEMENTS_B_PKG;

 

/
