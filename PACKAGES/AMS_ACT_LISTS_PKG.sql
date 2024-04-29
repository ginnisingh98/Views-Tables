--------------------------------------------------------
--  DDL for Package AMS_ACT_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACT_LISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstalss.pls 115.7 2003/05/08 20:55:40 jieli ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ACT_LISTS_PKG
-- Purpose
-- History
-- NOTE
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_act_list_header_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_last_update_login    NUMBER,
          p_list_header_id    NUMBER,
          p_group_code        VARCHAR2,
          p_list_used_by_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_act_type   VARCHAR2,
          p_list_action_type   VARCHAR2,
  	  p_order_number   NUMBER
          );

PROCEDURE Update_Row(
          p_act_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_login    NUMBER,
          p_list_header_id    NUMBER,
          p_group_code        VARCHAR2,
          p_list_used_by_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_act_type   VARCHAR2,
	  p_list_action_type   VARCHAR2,
  	  p_order_number   NUMBER
          );

PROCEDURE Delete_Row(
    p_ACT_LIST_HEADER_ID  NUMBER);
PROCEDURE Lock_Row(
          p_act_list_header_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_object_version_number    NUMBER,
          p_last_update_login    NUMBER,
          p_list_header_id    NUMBER,
          p_group_code        VARCHAR2,
          p_list_used_by_id    NUMBER,
          p_list_used_by    VARCHAR2,
          p_list_act_type   VARCHAR2,
	  p_list_action_type   VARCHAR2,
	  p_order_number   NUMBER
          );

END AMS_ACT_LISTS_PKG;

 

/
