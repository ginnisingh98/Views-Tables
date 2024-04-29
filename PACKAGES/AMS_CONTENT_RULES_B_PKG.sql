--------------------------------------------------------
--  DDL for Package AMS_CONTENT_RULES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CONTENT_RULES_B_PKG" AUTHID CURRENT_USER AS
/* $Header: amstctrs.pls 120.2 2006/05/30 11:10:43 prageorg noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_CONTENT_RULES_B_PKG
-- Purpose
--
-- History
--      28-mar-2003   soagrawa    Added add_language. Bug# 2876033
--      29-May-2005   prageorg    Added column delivery_mode.
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_content_rule_id   IN OUT NOCOPY NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_updated_date    DATE,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_sender    VARCHAR2,
          p_reply_to    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_table_of_content_flag    VARCHAR2,
          p_trigger_code    VARCHAR2,
          p_enabled_flag    VARCHAR2,
	  p_subject         VARCHAR2,
	  p_sender_display_name    VARCHAR2,--anchaudh
	  p_delivery_mode  VARCHAR2); --prageorg

PROCEDURE Update_Row(
          p_content_rule_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_updated_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_sender    VARCHAR2,
          p_reply_to    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_table_of_content_flag    VARCHAR2,
          p_trigger_code    VARCHAR2,
          p_enabled_flag    VARCHAR2,
	  p_subject         VARCHAR2,
	  p_sender_display_name    VARCHAR2,--anchaudh
	  p_delivery_mode  VARCHAR2);--prageorg

PROCEDURE Delete_Row(
    p_CONTENT_RULE_ID  NUMBER);

PROCEDURE Lock_Row(
          p_content_rule_id    NUMBER,
          p_created_by    NUMBER,
          p_creation_date    DATE,
          p_last_updated_by    NUMBER,
          p_last_updated_date    DATE,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_object_type    VARCHAR2,
          p_object_id    NUMBER,
          p_sender    VARCHAR2,
          p_reply_to    VARCHAR2,
          p_cover_letter_id    NUMBER,
          p_table_of_content_flag    VARCHAR2,
          p_trigger_code    VARCHAR2,
          p_enabled_flag    VARCHAR2,
	  p_subject         VARCHAR2,
	  p_sender_display_name    VARCHAR2,--anchaudh
	  p_delivery_mode  VARCHAR2);--prageorg

PROCEDURE ADD_LANGUAGE;

END AMS_CONTENT_RULES_B_PKG;

 

/
