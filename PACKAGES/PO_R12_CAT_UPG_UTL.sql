--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_UTL" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_UTL.pls 120.2 2006/02/20 11:07:24 pthapliy noship $ */

  g_SNAPSHOT_TOO_OLD EXCEPTION;
  PRAGMA EXCEPTION_INIT(g_SNAPSHOT_TOO_OLD, -1555);

PROCEDURE add_fatal_error
(
  p_interface_header_id IN NUMBER default NULL,
  p_interface_line_id IN NUMBER default NULL,
  p_interface_line_location_id IN NUMBER default NULL,
  p_interface_distribution_id IN NUMBER default NULL,
  p_price_diff_interface_id IN NUMBER default NULL,
  p_interface_attr_values_id IN NUMBER default NULL,
  p_interface_attr_values_tlp_id IN NUMBER default NULL,
  p_error_message_name IN VARCHAR2 default NULL,
  p_table_name IN VARCHAR2 default NULL,
  p_column_name IN VARCHAR2 default NULL,
  p_column_value IN VARCHAR2 default NULL,
  p_token1_name IN VARCHAR2 default NULL,
  p_token1_value IN VARCHAR2 default NULL,
  p_token2_name IN VARCHAR2 default NULL,
  p_token2_value IN VARCHAR2 default NULL,
  p_token3_name IN VARCHAR2 default NULL,
  p_token3_value IN VARCHAR2 default NULL,
  p_token4_name IN VARCHAR2 default NULL,
  p_token4_value IN VARCHAR2 default NULL,
  p_token5_name IN VARCHAR2 default NULL,
  p_token5_value IN VARCHAR2 default NULL,
  p_token6_name IN VARCHAR2 default NULL,
  p_token6_value IN VARCHAR2 default NULL
);

PROCEDURE reject_headers_intf
(
  p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
);

PROCEDURE reject_lines_intf
(
  p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER,
  p_cascade IN VARCHAR2
);

PROCEDURE reject_attr_values_intf
(
  p_id_param_type IN VARCHAR2,
  p_id_tbl        IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

PROCEDURE reject_attr_values_tlp_intf
(
  p_id_param_type IN VARCHAR2,
  p_id_tbl IN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER
);

FUNCTION construct_subscript_array
(
  p_size IN NUMBER
) RETURN PO_R12_CAT_UPG_TYPES.PO_TBL_NUMBER;

PROCEDURE assign_processing_id;

PROCEDURE init_startup_values
(
  p_commit IN VARCHAR2,
  p_selected_batch_id IN NUMBER,
  p_batch_size IN NUMBER,
  p_buyer_id IN NUMBER,
  p_document_type IN VARCHAR2,
  p_document_subtype IN VARCHAR2,
  p_create_items IN VARCHAR2,
  p_create_sourcing_rules_flag IN VARCHAR2,
  p_rel_gen_method IN VARCHAR2,
  p_approved_status IN VARCHAR2,
  p_process_code IN VARCHAR2,
  p_interface_header_id IN NUMBER,
  p_org_id IN NUMBER,
  p_ga_flag IN VARCHAR2,
  p_role IN VARCHAR2,
  p_error_threshold IN NUMBER,
  p_validate_only_mode IN VARCHAR2
);

FUNCTION get_base_lang RETURN VARCHAR2;

FUNCTION get_num_languages RETURN NUMBER;

END PO_R12_CAT_UPG_UTL;

 

/
