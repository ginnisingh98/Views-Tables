--------------------------------------------------------
--  DDL for Package HXC_FF_DICT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_FF_DICT" AUTHID CURRENT_USER as
/* $Header: hxcffpkg.pkh 120.1 2005/07/27 13:43:55 gpaytonm noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Global Definitions                                   |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hxc_ff_dict';  -- Global package name
--
-- ----------------------------------------------------------------------------

TYPE r_param IS RECORD (
  param1_value	hxc_time_entry_rules.attribute1%TYPE,
  param1	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param2_value	hxc_time_entry_rules.attribute1%TYPE,
  param2	fnd_descr_flex_column_usages.end_user_column_name%TYPE,  param3_value	hxc_time_entry_rules.attribute1%TYPE,
  param3	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param4_value	hxc_time_entry_rules.attribute1%TYPE,  param4	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param5_value	hxc_time_entry_rules.attribute1%TYPE,
  param5	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param6_value	hxc_time_entry_rules.attribute1%TYPE,
  param6	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param7_value	hxc_time_entry_rules.attribute1%TYPE,
  param7	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param8_value	hxc_time_entry_rules.attribute1%TYPE,
  param8	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param9_value	hxc_time_entry_rules.attribute1%TYPE,
  param9	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param10_value	hxc_time_entry_rules.attribute1%TYPE,
  param10	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param11_value	hxc_time_entry_rules.attribute1%TYPE,
  param11	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param12_value	hxc_time_entry_rules.attribute1%TYPE,
  param12	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param13_value	hxc_time_entry_rules.attribute1%TYPE,
  param13	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param14_value	hxc_time_entry_rules.attribute1%TYPE,
  param14	fnd_descr_flex_column_usages.end_user_column_name%TYPE,
  param15_value	hxc_time_entry_rules.attribute1%TYPE,
  param15	fnd_descr_flex_column_usages.end_user_column_name%TYPE );
--
function formula(
		 p_formula_id            in number
	,        p_resource_id           in number
	, 	 p_submission_date	 in date
	,	 p_ss_timecard_hours	 in number default null
	,        p_period_start_date     in date default null
	,        p_period_end_date       in date default null
	,	 p_db_pre_period_start	 in date default null
	,	 p_db_pre_period_end     in date default null
	,	 p_db_post_period_start	 in date default null
	,	 p_db_post_period_end    in date default null
	,	 p_db_ref_period_start	 in date default null
	,	 p_db_ref_period_end     in date default null
	,	 p_duration_in_days      in number default null
        ,        p_param_rec             in r_param )
    return ff_exec.outputs_t;

PROCEDURE decode_formula_segments (
		p_formula_name	  VARCHAR2
	,       p_rule_rec        hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
	,	p_param_rec	  IN OUT NOCOPY r_param
	,	p_period_value    IN OUT NOCOPY NUMBER
	,	p_reference_value IN OUT NOCOPY NUMBER
        ,       p_consider_zero_hours IN OUT NOCOPY VARCHAR2 );

FUNCTION execute_approval_formula (
		p_resource_id		NUMBER
	,	p_period_start_date	DATE
	,	p_period_end_date	DATE
	,	p_tc_period_start_date	DATE
	,	p_tc_period_end_date	DATE
	,	p_rule_rec		hxc_time_entry_rules_utils_pkg.csr_get_rules%rowtype
	,	p_message_table		IN OUT NOCOPY HXC_SELF_SERVICE_TIME_DEPOSIT.MESSAGE_TABLE )
RETURN varchar2;

FUNCTION get_formula_segment_value (
           p_param_rec r_param
 ,         p_param fnd_descr_flex_column_usages.end_user_column_name%TYPE ) RETURN hxc_time_entry_rules.attribute1%TYPE;

end hxc_ff_dict;

 

/
