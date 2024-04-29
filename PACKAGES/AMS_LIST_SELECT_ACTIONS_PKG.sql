--------------------------------------------------------
--  DDL for Package AMS_LIST_SELECT_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SELECT_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: amstlsas.pls 120.0 2005/05/31 22:45:12 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_LIST_SELECT_ACTIONS_PKG
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

PROCEDURE Insert_Row(
          px_list_select_action_id   IN OUT NOCOPY NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          px_object_version_number   IN OUT NOCOPY NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER);

PROCEDURE Update_Row(
          p_list_select_action_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER);

PROCEDURE Delete_Row(
    p_LIST_SELECT_ACTION_ID  NUMBER);
PROCEDURE Lock_Row(
          p_list_select_action_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER);

PROCEDURE LOAD_ROW(
          p_owner                    varchar2,
          p_list_select_action_id    NUMBER,
          p_last_update_date    DATE,
          p_last_updated_by    NUMBER,
          p_creation_date    DATE,
          p_created_by    NUMBER,
          p_last_update_login    NUMBER,
          p_object_version_number    NUMBER,
          p_list_header_id    NUMBER,
          p_order_number    NUMBER,
          p_list_action_type    VARCHAR2,
          p_incl_object_name    VARCHAR2,
          p_arc_incl_object_from    VARCHAR2,
          p_incl_object_id    NUMBER,
          p_incl_object_wb_sheet    VARCHAR2,
          p_incl_object_wb_owner    NUMBER,
          p_incl_object_cell_code    VARCHAR2,
          p_rank    NUMBER,
          p_no_of_rows_available    NUMBER,
          p_no_of_rows_requested    NUMBER,
          p_no_of_rows_used    NUMBER,
          p_distribution_pct    NUMBER,
          p_result_text    VARCHAR2,
          p_description    VARCHAR2,
          p_arc_action_used_by    VARCHAR2,
          p_action_used_by_id    NUMBER,
          p_incl_control_group    VARCHAR2,
          p_no_of_rows_targeted    NUMBER,
	  p_custom_mode    VARCHAR2
          );

END AMS_LIST_SELECT_ACTIONS_PKG;

 

/
