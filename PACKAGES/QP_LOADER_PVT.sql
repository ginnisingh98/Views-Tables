--------------------------------------------------------
--  DDL for Package QP_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LOADER_PVT" AUTHID CURRENT_USER as
/* $Header: QPXVLDQS.pls 120.1 2005/06/08 17:08:56 appldev  $ */

TYPE who_type IS RECORD
  (
   created_by        NUMBER,
   creation_date     DATE,
   last_updated_by   NUMBER,
   last_update_date  DATE,
   last_update_login NUMBER
   );

Procedure qp_pte_source_sys_load_row (
        x_pte_code in varchar2,
        x_application_short_name in varchar2,
        x_enabled_flag in varchar2,
        x_custom_mode in varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2
);

Procedure qp_pte_ss_fn_area_load_row (
        x_pte_code in varchar2,
        x_application_short_name in varchar2,
        x_functional_area_id in varchar2,
        x_enabled_flag in varchar2,
        x_seeded_flag in varchar2,
        x_custom_mode in varchar2,
        x_last_update_date in varchar2,
        x_owner in varchar2
);

procedure qp_pte_req_types_translate_row (
	x_pte_code in varchar2,
	x_request_type_code in varchar2,
	x_order_level_global_struct in varchar2,
	x_line_level_global_struct in varchar2,
	x_order_level_view_name in varchar2,
	x_line_level_view_name in varchar2,
	x_enabled_flag in varchar2,
	x_request_type_desc in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
);

procedure qp_pte_req_types_load_row (
	x_pte_code in varchar2,
	x_request_type_code in varchar2,
	x_order_level_global_struct in varchar2,
	x_line_level_global_struct in varchar2,
	x_order_level_view_name in varchar2,
	x_line_level_view_name in varchar2,
	x_enabled_flag in varchar2,
	x_request_type_desc in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
);

end QP_LOADER_PVT;

 

/
