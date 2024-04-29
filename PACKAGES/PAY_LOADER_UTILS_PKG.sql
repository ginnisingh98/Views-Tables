--------------------------------------------------------
--  DDL for Package PAY_LOADER_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LOADER_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyldutil.pkh 120.3 2005/10/19 04:17 pgongada noship $ */

PROCEDURE  load_rfm_row
            ( p_report_type                in varchar2
             ,p_report_qualifier           in varchar2
             ,p_report_category            in varchar2
             ,p_effective_start_date       in date
             ,p_effective_end_date         in date
             ,p_legislation_code           in varchar2
             ,p_business_group_name        in varchar2
             ,p_range_code                 in varchar2
             ,p_assignment_action_code     in varchar2
             ,p_initialization_code        in varchar2
             ,p_archive_code               in varchar2
             ,p_magnetic_code              in varchar2
             ,p_report_format              in varchar2
             ,p_report_name                in varchar2
             ,p_sort_code                  in varchar2
             ,p_updatable_flag             in varchar2
             ,p_deinitialization_code      in varchar2
             ,p_temporary_action_flag      in varchar2
             ,p_display_name               in varchar2
             ,p_owner                      in varchar2
             ,p_eof                        in number   );

PROCEDURE  translate_rfm_row
            ( p_report_type                in varchar2
             ,p_report_qualifier           in varchar2
             ,p_report_category            in varchar2
             ,p_display_name               in varchar2 );

PROCEDURE  load_rfi_row
            ( p_report_type                in varchar2
             ,p_report_qualifier           in varchar2
             ,p_report_category            in varchar2
             ,p_user_entity_name           in varchar2
             ,p_legislation_code           in varchar2
             ,p_effective_start_date       in date
             ,p_effective_end_date         in date
             ,p_archive_type               in varchar2
             ,p_updatable_flag             in varchar2
             ,p_display_sequence           in number
             ,p_owner                      in varchar2
             ,p_eof                        in number   );

PROCEDURE load_rfp_row
            ( p_report_type                in varchar2
             ,p_report_qualifier           in varchar2
             ,p_report_category            in varchar2
             ,p_parameter_name             in varchar2
             ,p_parameter_value            in varchar2
             ,p_owner                      in varchar2 );

PROCEDURE  load_mgb_row
            ( p_block_name                 in varchar2
             ,p_report_format              in varchar2
             ,p_main_block_flag            in varchar2
             ,p_cursor_name                in varchar2
             ,p_no_column_returned         in number   );

PROCEDURE load_mgr_row
            ( p_block_name                 in varchar2
             ,p_report_format              in varchar2
             ,p_sequence                   in number
             ,p_formula_type_name          in varchar2
             ,p_formula_name               in varchar2
             ,p_legislation_code           in varchar2
             ,p_next_block_name            in varchar2
             ,p_next_report_format         in varchar2
             ,p_overflow_mode              in varchar2
             ,p_frequency                  in number
             ,p_last_run_executed_mode     in varchar2
             ,p_action_level               in varchar2 default null
             ,p_block_label                in varchar2 default null
             ,p_block_row_label            in varchar2 default null
             ,p_xml_proc_name              in varchar2 default null );

PROCEDURE load_egu_row
            ( p_evg_name          in  varchar2
             ,p_evg_leg_code      in  varchar2
             ,p_evg_bus_grp_name  in  varchar2
             ,p_els_name          in  varchar2
             ,p_els_leg_code      in  varchar2
             ,p_els_bus_grp_name  in  varchar2
             ,p_egu_leg_code      in  varchar2
             ,p_egu_bus_grp_name  in  varchar2
             ,p_owner             in  varchar2 );

PROCEDURE load_ecu_row
	    ( p_usage_id		in	number
	     ,p_rt_name			in	varchar2
	     ,p_rt_effective_start_date	in	date
	     ,p_rt_effective_end_date	in	date
	     ,p_rt_business_group_name	in	varchar2
	     ,p_rt_legislation_code	in	varchar2
	     ,p_rt_shortname		in	varchar2
	     ,p_ec_classification_name	in	varchar2
	     ,p_ec_business_group_name	in	varchar2
	     ,p_ec_legislation_code	in	varchar2
             ,p_effective_start_date	in	date
             ,p_effective_end_date	in	date
             ,p_business_group_name	in	varchar2
             ,p_legislation_code	in	varchar2
	     ,p_owner			in	varchar2
             ,p_eof_number		in	number);

END PAY_LOADER_UTILS_PKG;


 

/
