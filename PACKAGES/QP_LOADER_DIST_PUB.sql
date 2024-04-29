--------------------------------------------------------
--  DDL for Package QP_LOADER_DIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_LOADER_DIST_PUB" AUTHID CURRENT_USER as
/* $Header: QPXPLDDS.pls 120.0 2005/06/02 01:22:45 appldev noship $ */

procedure qp_prc_contexts_translate_row (
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_seeded_flag in varchar2,
	x_enabled_flag in varchar2,
	x_application_id in varchar2,
	x_seeded_prc_context_name in varchar2,
	x_seeded_description in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
);

procedure qp_prc_contexts_load_row (
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_seeded_flag in varchar2,
	x_enabled_flag in varchar2,
	x_application_id in varchar2,
	x_seeded_prc_context_name in varchar2,
	x_seeded_description in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
);

procedure qp_segments_translate_row (
	x_segment_code in varchar2,
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_availability_in_basic in varchar2,
	x_application_id in varchar2,
	x_segment_mapping_column in varchar2,
	x_seeded_flag in varchar2,
	x_seeded_precedence in varchar2,
	x_flex_value_set_name in varchar2,
	x_seeded_format_type in varchar2,
	x_seeded_segment_name in varchar2,
	x_seeded_description in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
);

procedure qp_segments_load_row (
	x_segment_code in varchar2,
	x_prc_context_code in varchar2,
	x_prc_context_type in varchar2,
	x_availability_in_basic in varchar2,
	x_application_id in varchar2,
	x_segment_mapping_column in varchar2,
	x_seeded_flag in varchar2,
	x_seeded_precedence in varchar2,
	x_flex_value_set_name in varchar2,
	x_seeded_format_type in varchar2,
	x_seeded_segment_name in varchar2,
	x_seeded_description in varchar2,
	x_required_flag in varchar2,
	x_custom_mode in varchar2,
	x_last_update_date in varchar2,
	x_owner in varchar2
);

end QP_LOADER_DIST_PUB;

 

/
